package com.example.android.handlandmarker

import android.annotation.SuppressLint
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import org.tensorflow.lite.Interpreter
import java.io.File
import java.io.FileInputStream
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import android.util.Size
import kotlin.math.exp

class HandLandmarkerView(
    private val context: Context,
    messenger: BinaryMessenger,
    id: Int,
    private val lifecycleProvider: () -> LifecycleOwner
) : PlatformView, MethodChannel.MethodCallHandler, HandLandmarkerHelper.LandmarkerListener {

    private val rootView: FrameLayout = FrameLayout(context)
    private val previewView: PreviewView = PreviewView(context).apply {
        implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        scaleType = PreviewView.ScaleType.FILL_CENTER
    }
    private val overlayView: HandLandmarkerOverlay = HandLandmarkerOverlay(context)
    private val methodChannel: MethodChannel = MethodChannel(messenger, "temanisyarat/hand_landmarker_$id")
    private val mainHandler: Handler = Handler(Looper.getMainLooper())

    private var cameraProvider: ProcessCameraProvider? = null
    private var camera: Camera? = null
    private var preview: Preview? = null
    private var imageAnalyzer: ImageAnalysis? = null
    private var cameraFacing = CameraSelector.LENS_FACING_FRONT

    private lateinit var backgroundExecutor: ExecutorService
    private lateinit var inferenceExecutor: ExecutorService
    private var handLandmarkerHelper: HandLandmarkerHelper? = null
    private var isStarted = false

    private var interpreter: Interpreter? = null
    private val modelLock = Any()
    private val bufferLock = Any()

    private val frameBuffer = FloatArray(MAX_FRAMES * FRAME_DIM)
    private var frameCount = 0
    private var modelLoaded = false

    private val inferenceInput = Array(1) { Array(MAX_FRAMES) { FloatArray(FRAME_DIM) } }
    private val inferenceOutput = Array(1) { FloatArray(NUM_CLASSES) }

    private var inferenceTick = 0

    private val predictionHistory = mutableListOf<Int>()
    private var previousPrediction: String? = null

    init {
        rootView.addView(previewView)
        overlayView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        rootView.addView(overlayView)

        methodChannel.setMethodCallHandler(this)

        backgroundExecutor = Executors.newSingleThreadExecutor()
        inferenceExecutor = Executors.newSingleThreadExecutor()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startCamera" -> startCamera(result)
            "stopCamera" -> stopCamera(result)
            "switchCamera" -> switchCamera(result)
            "updateSettings" -> updateSettings(call, result)
            else -> result.notImplemented()
        }
    }

    private fun startCamera(result: MethodChannel.Result) {
        if (isStarted) {
            result.success(true)
            return
        }

        initModel()

        backgroundExecutor.execute {
            handLandmarkerHelper = HandLandmarkerHelper(
                context = context,
                landmarkerListener = this
            )
        }

        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                cameraProvider = cameraProviderFuture.get()
                bindCameraUseCases()
                isStarted = true
                mainHandler.post {
                    methodChannel.invokeMethod(
                        "onModelReady",
                        hashMapOf("loaded" to modelLoaded)
                    )
                }
                result.success(true)
            } catch (e: Exception) {
                result.error("CAMERA_ERROR", e.message, null)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun initModel() {
        try {
            val modelFile = File(context.cacheDir, "model_raw.tflite")
            if (!modelFile.exists()) {
                context.assets.open("models/model_raw.tflite").use { input ->
                    modelFile.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
            }
            val model: MappedByteBuffer = FileInputStream(modelFile).channel.map(
                FileChannel.MapMode.READ_ONLY, 0, modelFile.length()
            )
            synchronized(modelLock) {
                interpreter = Interpreter(model, Interpreter.Options().apply {
                    setUseXNNPACK(false)
                })
            }
            modelLoaded = true
            Log.i(TAG, "Model loaded successfully")
        } catch (e: Exception) {
            modelLoaded = false
            Log.e(TAG, "Failed to load model", e)
        }
    }

    private fun stopCamera(result: MethodChannel.Result) {
        try {
            handLandmarkerHelper?.shutdown()
            cameraProvider?.unbindAll()
            isStarted = false
            overlayView.clear()
            handLandmarkerHelper?.clear()
            resetBuffer()
            result.success(true)
        } catch (e: Exception) {
            try { result.error("STOP_ERROR", e.message, null) } catch (_: Exception) {}
        }
    }

    private fun switchCamera(result: MethodChannel.Result) {
        cameraFacing = if (cameraFacing == CameraSelector.LENS_FACING_FRONT) {
            CameraSelector.LENS_FACING_BACK
        } else {
            CameraSelector.LENS_FACING_FRONT
        }
        bindCameraUseCases()
        result.success(true)
    }

    private fun updateSettings(call: MethodCall, result: MethodChannel.Result) {
        val maxHands = call.argument<Int>("maxHands") ?: 2
        val detectionConfidence = call.argument<Double>("detectionConfidence")?.toFloat() ?: 0.5f
        val trackingConfidence = call.argument<Double>("trackingConfidence")?.toFloat() ?: 0.5f
        val delegate = call.argument<Int>("delegate") ?: 0

        backgroundExecutor.execute {
            handLandmarkerHelper?.clear()
            handLandmarkerHelper = HandLandmarkerHelper(
                maxNumHands = maxHands,
                minHandDetectionConfidence = detectionConfidence,
                minHandTrackingConfidence = trackingConfidence,
                currentDelegate = delegate,
                context = context,
                landmarkerListener = this
            )
        }
        result.success(true)
    }

    @SuppressLint("UnsafeOptInUsageError")
    private fun bindCameraUseCases() {
        val cameraProvider = cameraProvider ?: return

        val cameraSelector = CameraSelector.Builder()
            .requireLensFacing(cameraFacing)
            .build()

        preview = Preview.Builder()
            .setTargetResolution(Size(640, 480))
            .setTargetRotation(previewView.display.rotation)
            .build()

        imageAnalyzer = ImageAnalysis.Builder()
            .setTargetResolution(Size(640, 480))
            .setTargetRotation(previewView.display.rotation)
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
            .build()
            .also {
                it.setAnalyzer(backgroundExecutor) { imageProxy ->
                    handLandmarkerHelper?.detectLiveStream(
                        imageProxy = imageProxy,
                        isFrontCamera = cameraFacing == CameraSelector.LENS_FACING_FRONT
                    )
                }
            }

        cameraProvider.unbindAll()

        try {
            camera = cameraProvider.bindToLifecycle(
                lifecycleProvider(),
                cameraSelector,
                preview,
                imageAnalyzer
            )
            preview?.setSurfaceProvider(previewView.surfaceProvider)
        } catch (e: Exception) {
            Log.e(TAG, "Use case binding failed", e)
        }
    }

    override fun onResults(resultBundle: HandLandmarkerHelper.CombinedResultBundle) {
        val isFront = cameraFacing == CameraSelector.LENS_FACING_FRONT
        overlayView.setResults(
            handResult = resultBundle.handResult,
            poseResult = resultBundle.poseResult,
            imageHeight = resultBundle.imageHeight,
            imageWidth = resultBundle.imageWidth
        )

        val handLandmarks = resultBundle.handResult.landmarks()
        val handedness = resultBundle.handResult.handedness()

        var leftHand: List<List<Float>>? = null
        var rightHand: List<List<Float>>? = null

        for (i in handLandmarks.indices) {
            val landmarks = handLandmarks[i]
            val handed = handedness[i]
            val category = handed.firstOrNull()
            val handName = category?.displayName() ?: category?.categoryName() ?: "right"

            val landmarkList = landmarks.map { lm ->
                listOf(
                    if (isFront) 1f - lm.x() else lm.x(),
                    lm.y(),
                    lm.z()
                )
            }

            if (handName.equals("left", ignoreCase = true)) {
                rightHand = landmarkList
            } else {
                leftHand = landmarkList
            }
        }

        val pose = resultBundle.poseResult.landmarks().firstOrNull()?.map { lm ->
            listOf(
                if (isFront) 1f - lm.x() else lm.x(),
                lm.y(),
                lm.z()
            )
        }

        val (frame, nanCount) = assembleFrame(pose, leftHand, rightHand)

        if (nanCount > FRAME_DIM / 2) {
            val args = hashMapOf<String, Any?>()
            args["prediction"] = null
            args["hasLandmarks"] = false
            mainHandler.post { methodChannel.invokeMethod("onLandmarks", args) }
            return
        }

        val canInfer: Boolean
        synchronized(bufferLock) {
            val offset = frameCount % MAX_FRAMES
            System.arraycopy(frame, 0, frameBuffer, offset * FRAME_DIM, FRAME_DIM)
            frameCount++
            canInfer = frameCount >= EARLY_INFERENCE_FRAMES && modelLoaded
        }

        if (canInfer) {
            inferenceTick++
            if (inferenceTick % INFERENCE_INTERVAL == 0) {
                inferenceExecutor.execute { runInference() }
            }
            val args = hashMapOf<String, Any?>()
            args["prediction"] = previousPrediction
            args["bufferCount"] = frameCount.coerceAtMost(MAX_FRAMES)
            args["bufferReady"] = true
            args["writeOffset"] = frameCount % MAX_FRAMES
            args["totalFrames"] = frameCount
            mainHandler.post { methodChannel.invokeMethod("onLandmarks", args) }
        } else {
            val args = hashMapOf<String, Any?>()
            args["prediction"] = null
            args["bufferCount"] = frameCount.coerceAtMost(MAX_FRAMES)
            args["bufferReady"] = false
            args["writeOffset"] = frameCount % MAX_FRAMES
            args["totalFrames"] = frameCount
            mainHandler.post { methodChannel.invokeMethod("onLandmarks", args) }
        }
    }

    private fun runInference() {
        val currentCount: Int
        synchronized(bufferLock) {
            currentCount = frameCount
            val startIdx = if (currentCount >= MAX_FRAMES) currentCount % MAX_FRAMES else 0
            val fillCount = minOf(currentCount, MAX_FRAMES)
            for (i in 0 until fillCount) {
                val srcIdx = (startIdx + i) % MAX_FRAMES
                System.arraycopy(frameBuffer, srcIdx * FRAME_DIM, inferenceInput[0][i], 0, FRAME_DIM)
            }
        }

        synchronized(modelLock) {
            try {
                interpreter?.run(inferenceInput, inferenceOutput)
            } catch (e: Exception) {
                Log.e(TAG, "Inference failed", e)
                return
            }
        }

        val logits = inferenceOutput[0]
        val maxVal = logits.maxOrNull() ?: return
        val expSum = logits.sumOf { exp((it - maxVal).toDouble()) }.toFloat()
        val probs = logits.map { exp((it - maxVal).toDouble()).toFloat() / expSum }
        val bestProb = probs.maxOrNull() ?: return
        val logitsStr = logits.joinToString(limit = 5) { String.format("%.3f", it) }
        Log.d(TAG, "Logits (first 5): $logitsStr | bestProb=%.4f | offset=%d | total=%d".format(bestProb, currentCount % MAX_FRAMES, currentCount))
        val prediction: String? = if (bestProb >= CONFIDENCE_THRESHOLD) {
            val predIdx = probs.indexOf(bestProb)
            predictionHistory.add(predIdx)
            if (predictionHistory.size > HISTORY_SIZE) predictionHistory.removeAt(0)

            val counts = predictionHistory.groupingBy { it }.eachCount()
            val bestEntry = counts.maxByOrNull { it.value }
            if (bestEntry != null && bestEntry.value >= (HISTORY_SIZE * MAJORITY_THRESHOLD).toInt()) {
                CLASS_LABELS.getOrNull(bestEntry.key).also { previousPrediction = it }
            } else {
                null
            }
        } else {
            null
        }

        val args = hashMapOf<String, Any?>()
        args["prediction"] = prediction
        args["bufferCount"] = currentCount.coerceAtMost(MAX_FRAMES)
        args["bufferReady"] = true
        args["writeOffset"] = currentCount % MAX_FRAMES
        args["totalFrames"] = currentCount
        mainHandler.post { methodChannel.invokeMethod("onLandmarks", args) }
    }

    private fun assembleFrame(
        pose: List<List<Float>>?,
        leftHand: List<List<Float>>?,
        rightHand: List<List<Float>>?
    ): FrameResult {
        val frame = FloatArray(FRAME_DIM)
        var idx = 0
        var nanCount = 0
        val poseIndices = listOf(0, 11, 12, 13, 14, 15, 16, 23, 24)

        if (pose != null && pose.isNotEmpty()) {
            val pose9 = extractPose9(pose)
            for (pi in poseIndices) {
                if (pi < pose9.size) {
                    val lm = pose9[pi]
                    frame[idx++] = lm[0]
                    frame[idx++] = lm[1]
                    frame[idx++] = lm[2]
                } else {
                    frame[idx++] = 0f; frame[idx++] = 0f; frame[idx++] = 0f
                }
            }
        } else {
            for (i in 0 until 9) {
                frame[idx++] = Float.NaN; frame[idx++] = Float.NaN; frame[idx++] = Float.NaN
                nanCount += 3
            }
        }

        if (leftHand != null && leftHand.size >= 21) {
            for (h in 0 until 21) {
                val lm = leftHand[h]
                frame[idx++] = lm[0]; frame[idx++] = lm[1]; frame[idx++] = lm[2]
            }
        } else {
            for (i in 0 until 63) {
                frame[idx++] = Float.NaN
                nanCount++
            }
        }

        if (rightHand != null && rightHand.size >= 21) {
            for (h in 0 until 21) {
                val lm = rightHand[h]
                frame[idx++] = lm[0]; frame[idx++] = lm[1]; frame[idx++] = lm[2]
            }
        } else {
            for (i in 0 until 63) {
                frame[idx++] = Float.NaN
                nanCount++
            }
        }

        return FrameResult(frame, nanCount)
    }

    private data class FrameResult(val frame: FloatArray, val nanCount: Int)

    private fun extractPose9(fullPose: List<List<Float>>): List<List<Float>> {
        if (fullPose.size < 25) {
            if (fullPose.isNotEmpty()) return listOf(fullPose[0])
            return listOf(listOf(0f, 0f, 0f))
        }
        return listOf(
            fullPose[0], fullPose[11], fullPose[12],
            fullPose[13], fullPose[14], fullPose[15],
            fullPose[16], fullPose[23], fullPose[24]
        )
    }

    private fun resetBuffer() {
        synchronized(bufferLock) {
            frameBuffer.fill(0f)
            frameCount = 0
            predictionHistory.clear()
            previousPrediction = null
        }
    }

    override fun onError(error: String, errorCode: Int) {
        mainHandler.post { methodChannel.invokeMethod("onError", hashMapOf("message" to error, "code" to errorCode)) }
    }

    override fun getView(): View = rootView

    override fun dispose() {
        handLandmarkerHelper?.shutdown()
        handLandmarkerHelper?.clear()
        try {
            backgroundExecutor.shutdown()
            inferenceExecutor.shutdown()
        } catch (_: Exception) {}
        cameraProvider?.unbindAll()
        interpreter?.close()
        methodChannel.setMethodCallHandler(null)
    }

    companion object {
        private const val TAG = "HandLandmarkerView"
        private const val MAX_FRAMES = 110
        private const val EARLY_INFERENCE_FRAMES = 10
        private const val INFERENCE_INTERVAL = 1
        private const val FRAME_DIM = 153
        private const val NUM_CLASSES = 20
        private const val CONFIDENCE_THRESHOLD = 0.5f
        private const val HISTORY_SIZE = 2
        private const val MAJORITY_THRESHOLD = 0.4f

        private val CLASS_LABELS = listOf(
            "aku", "apel", "ayah", "besok", "buku",
            "dia", "dua", "hari ini", "ibu", "kamu",
            "kuning", "maaf", "merah", "nama", "pisang",
            "salam", "satu", "teman", "terima kasih", "tiga"
        )
    }
}
