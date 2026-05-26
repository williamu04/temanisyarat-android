package com.example.android.handlandmarker

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.SystemClock
import android.util.Log
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import androidx.core.graphics.createBitmap
import java.util.concurrent.ConcurrentHashMap

class HandLandmarkerHelper(
    var minHandDetectionConfidence: Float = DEFAULT_HAND_DETECTION_CONFIDENCE,
    var minHandTrackingConfidence: Float = DEFAULT_HAND_TRACKING_CONFIDENCE,
    var minHandPresenceConfidence: Float = DEFAULT_HAND_PRESENCE_CONFIDENCE,
    var minPoseDetectionConfidence: Float = DEFAULT_POSE_DETECTION_CONFIDENCE,
    var minPoseTrackingConfidence: Float = DEFAULT_POSE_TRACKING_CONFIDENCE,
    var minPosePresenceConfidence: Float = DEFAULT_POSE_PRESENCE_CONFIDENCE,
    var maxNumHands: Int = DEFAULT_NUM_HANDS,
    var currentDelegate: Int = DELEGATE_GPU,
    val context: Context,
    val landmarkerListener: LandmarkerListener? = null
) {
    private var handLandmarker: HandLandmarker? = null
    private var poseLandmarker: PoseLandmarker? = null

    @Volatile
    private var isShutdown = false

    private val runningMode = RunningMode.LIVE_STREAM

    private class PendingFrame(
        var handResult: HandLandmarkerResult? = null,
        var poseResult: PoseLandmarkerResult? = null,
        var imageHeight: Int = 0,
        var imageWidth: Int = 0
    )

    private val pendingFrames = ConcurrentHashMap<Long, PendingFrame>()

    init {
        setupHandLandmarker()
        setupPoseLandmarker()
    }

    fun shutdown() {
        isShutdown = true
    }

    fun clear() {
        shutdown()
        pendingFrames.clear()
        handLandmarker?.close()
        handLandmarker = null
        poseLandmarker?.close()
        poseLandmarker = null
    }

    fun isClosed(): Boolean = handLandmarker == null && poseLandmarker == null

    private fun setupHandLandmarker() {
        val delegates = if (currentDelegate == DELEGATE_GPU) {
            listOf(DELEGATE_GPU, DELEGATE_CPU)
        } else {
            listOf(DELEGATE_CPU)
        }
        for (delegate in delegates) {
            if (setupHandLandmarkerWithDelegate(delegate)) break
        }
    }

    private fun setupHandLandmarkerWithDelegate(delegate: Int): Boolean {
        val baseOptionBuilder = BaseOptions.builder()
        when (delegate) {
            DELEGATE_CPU -> baseOptionBuilder.setDelegate(Delegate.CPU)
            DELEGATE_GPU -> baseOptionBuilder.setDelegate(Delegate.GPU)
        }
        baseOptionBuilder.setModelAssetPath(MP_HAND_LANDMARKER_TASK)

        try {
            val optionsBuilder = HandLandmarker.HandLandmarkerOptions.builder()
                .setBaseOptions(baseOptionBuilder.build())
                .setMinHandDetectionConfidence(minHandDetectionConfidence)
                .setMinTrackingConfidence(minHandTrackingConfidence)
                .setMinHandPresenceConfidence(minHandPresenceConfidence)
                .setNumHands(maxNumHands)
                .setRunningMode(runningMode)

            if (runningMode == RunningMode.LIVE_STREAM) {
                optionsBuilder
                    .setResultListener(this::returnHandLivestreamResult)
                    .setErrorListener(this::returnLivestreamError)
            }

            handLandmarker = HandLandmarker.createFromOptions(context, optionsBuilder.build())
            currentDelegate = delegate
            return true
        } catch (e: Exception) {
            if (delegate == DELEGATE_GPU) {
                Log.w(TAG, "Hand Landmarker GPU init failed, retrying with CPU", e)
            } else {
                landmarkerListener?.onError("Hand Landmarker init failed: ${e.message}")
                Log.e(TAG, "Hand Landmarker init failed", e)
            }
            return false
        }
    }

    private fun setupPoseLandmarker() {
        val delegates = if (currentDelegate == DELEGATE_GPU) {
            listOf(DELEGATE_GPU, DELEGATE_CPU)
        } else {
            listOf(DELEGATE_CPU)
        }
        for (delegate in delegates) {
            if (setupPoseLandmarkerWithDelegate(delegate)) break
        }
    }

    private fun setupPoseLandmarkerWithDelegate(delegate: Int): Boolean {
        val baseOptionBuilder = BaseOptions.builder()
        when (delegate) {
            DELEGATE_CPU -> baseOptionBuilder.setDelegate(Delegate.CPU)
            DELEGATE_GPU -> baseOptionBuilder.setDelegate(Delegate.GPU)
        }
        baseOptionBuilder.setModelAssetPath(MP_POSE_LANDMARKER_TASK)

        try {
            val optionsBuilder = PoseLandmarker.PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptionBuilder.build())
                .setMinPoseDetectionConfidence(minPoseDetectionConfidence)
                .setMinTrackingConfidence(minPoseTrackingConfidence)
                .setMinPosePresenceConfidence(minPosePresenceConfidence)
                .setRunningMode(runningMode)
                .setNumPoses(1)

            if (runningMode == RunningMode.LIVE_STREAM) {
                optionsBuilder
                    .setResultListener(this::returnPoseLivestreamResult)
                    .setErrorListener(this::returnLivestreamError)
            }

            poseLandmarker = PoseLandmarker.createFromOptions(context, optionsBuilder.build())
            return true
        } catch (e: Exception) {
            if (delegate == DELEGATE_GPU) {
                Log.w(TAG, "Pose Landmarker GPU init failed, retrying with CPU", e)
            } else {
                landmarkerListener?.onError("Pose Landmarker init failed: ${e.message}")
                Log.e(TAG, "Pose Landmarker init failed", e)
            }
            return false
        }
    }

    fun detectLiveStream(imageProxy: ImageProxy, isFrontCamera: Boolean) {
        if (isShutdown) {
            imageProxy.close()
            return
        }

        val frameTime = SystemClock.uptimeMillis()

        val bitmapBuffer = createBitmap(imageProxy.width, imageProxy.height)
        imageProxy.use { bitmapBuffer.copyPixelsFromBuffer(imageProxy.planes[0].buffer) }
        imageProxy.close()

        val matrix = Matrix().apply {
            postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
            if (isFrontCamera) {
                postScale(-1f, 1f, imageProxy.width.toFloat() / 2f, imageProxy.height.toFloat() / 2f)
            }
        }
        val rotatedBitmap = Bitmap.createBitmap(
            bitmapBuffer, 0, 0, bitmapBuffer.width, bitmapBuffer.height, matrix, true
        )

        val mpImage = BitmapImageBuilder(rotatedBitmap).build()

        if (pendingFrames.size > MAX_PENDING_FRAMES) {
            val oldest = pendingFrames.keys.minOrNull()
            if (oldest != null) pendingFrames.remove(oldest)
        }
        pendingFrames[frameTime] = PendingFrame(
            imageHeight = rotatedBitmap.height,
            imageWidth = rotatedBitmap.width
        )

        handLandmarker?.detectAsync(mpImage, frameTime)
        poseLandmarker?.detectAsync(mpImage, frameTime)
    }

    private fun returnHandLivestreamResult(result: HandLandmarkerResult, input: MPImage) {
        val frameTime = result.timestampMs()
        tryEmit(frameTime) { it.handResult = result }
    }

    private fun returnPoseLivestreamResult(result: PoseLandmarkerResult, input: MPImage) {
        val frameTime = result.timestampMs()
        tryEmit(frameTime) { it.poseResult = result }
    }

    private fun tryEmit(frameTime: Long, store: (PendingFrame) -> Unit) {
        val bundle = mutableListOf<CombinedResultBundle>()
        pendingFrames.computeIfPresent(frameTime) { _, frame ->
            store(frame)
            if (frame.handResult != null && frame.poseResult != null) {
                bundle.add(
                    CombinedResultBundle(
                        handResult = frame.handResult!!,
                        poseResult = frame.poseResult!!,
                        inferenceTime = SystemClock.uptimeMillis() - frameTime,
                        imageHeight = frame.imageHeight,
                        imageWidth = frame.imageWidth
                    )
                )
                null
            } else {
                frame
            }
        }
        bundle.firstOrNull()?.let { landmarkerListener?.onResults(it) }
    }

    private fun returnLivestreamError(error: RuntimeException) {
        landmarkerListener?.onError(error.message ?: "Unknown error")
    }

    companion object {
        const val TAG = "HandLandmarkerHelper"
        private const val MP_HAND_LANDMARKER_TASK = "hand_landmarker.task"
        private const val MP_POSE_LANDMARKER_TASK = "pose_landmarker_lite.task"

        const val DELEGATE_CPU = 0
        const val DELEGATE_GPU = 1
        const val DEFAULT_HAND_DETECTION_CONFIDENCE = 0.5F
        const val DEFAULT_HAND_TRACKING_CONFIDENCE = 0.5F
        const val DEFAULT_HAND_PRESENCE_CONFIDENCE = 0.5F
        const val DEFAULT_POSE_DETECTION_CONFIDENCE = 0.5F
        const val DEFAULT_POSE_TRACKING_CONFIDENCE = 0.5F
        const val DEFAULT_POSE_PRESENCE_CONFIDENCE = 0.5F
        const val DEFAULT_NUM_HANDS = 2
        private const val MAX_PENDING_FRAMES = 10
        const val OTHER_ERROR = 0
    }

    data class CombinedResultBundle(
        val handResult: HandLandmarkerResult,
        val poseResult: PoseLandmarkerResult,
        val inferenceTime: Long,
        val imageHeight: Int,
        val imageWidth: Int
    )

    interface LandmarkerListener {
        fun onError(error: String, errorCode: Int = OTHER_ERROR)
        fun onResults(resultBundle: CombinedResultBundle)
    }
}
