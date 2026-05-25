package com.example.android.handlandmarker

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.View
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import kotlin.math.max

class HandLandmarkerOverlay @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    private var handResult: HandLandmarkerResult? = null
    private var poseResult: PoseLandmarkerResult? = null
    private var scaleFactor: Float = 1f
    private var offsetX: Float = 0f
    private var offsetY: Float = 0f
    private var imageWidth: Int = 1
    private var imageHeight: Int = 1
    private val linePaint = Paint().apply {
        color = Color.parseColor("#00FF00")
        strokeWidth = LANDMARK_STROKE_WIDTH
        style = Paint.Style.STROKE
    }

    private val pointPaint = Paint().apply {
        color = Color.YELLOW
        strokeWidth = LANDMARK_STROKE_WIDTH
        style = Paint.Style.FILL
    }

    private val poseLinePaint = Paint().apply {
        color = Color.parseColor("#FF6B6B")
        strokeWidth = POSE_STROKE_WIDTH
        style = Paint.Style.STROKE
    }

    private val posePointPaint = Paint().apply {
        color = Color.CYAN
        strokeWidth = POSE_POINT_RADIUS
        style = Paint.Style.FILL
    }

    fun clear() {
        handResult = null
        poseResult = null
        invalidate()
    }

    fun setResults(
        handResult: HandLandmarkerResult,
        poseResult: PoseLandmarkerResult,
        imageHeight: Int,
        imageWidth: Int
    ) {
        this.handResult = handResult
        this.poseResult = poseResult
        this.imageHeight = imageHeight
        this.imageWidth = imageWidth

        val scale = max(width * 1f / imageWidth, height * 1f / imageHeight)
        scaleFactor = scale
        offsetX = (width - imageWidth * scale) / 2f
        offsetY = (height - imageHeight * scale) / 2f
        invalidate()
    }

    override fun draw(canvas: Canvas) {
        super.draw(canvas)

        poseResult?.let { drawPose(canvas, it) }
        handResult?.let { drawHands(canvas, it) }
    }

    private fun drawPose(canvas: Canvas, result: PoseLandmarkerResult) {
        for (landmarkList in result.landmarks()) {
            for (i in poseLandmarkIndices) {
                val lm = landmarkList[i]
                canvas.drawCircle(
                    lm.x() * imageWidth * scaleFactor + offsetX,
                    lm.y() * imageHeight * scaleFactor + offsetY,
                    POSE_POINT_RADIUS,
                    posePointPaint
                )
            }

            for (connection in POSE_CONNECTIONS) {
                val startLm = landmarkList[connection.first]
                val endLm = landmarkList[connection.second]
                canvas.drawLine(
                    startLm.x() * imageWidth * scaleFactor + offsetX,
                    startLm.y() * imageHeight * scaleFactor + offsetY,
                    endLm.x() * imageWidth * scaleFactor + offsetX,
                    endLm.y() * imageHeight * scaleFactor + offsetY,
                    poseLinePaint
                )
            }
        }
    }

    private fun drawHands(canvas: Canvas, result: HandLandmarkerResult) {
        for (landmark in result.landmarks()) {
            for (normalizedLandmark in landmark) {
                canvas.drawPoint(
                    normalizedLandmark.x() * imageWidth * scaleFactor + offsetX,
                    normalizedLandmark.y() * imageHeight * scaleFactor + offsetY,
                    pointPaint
                )
            }

            HandLandmarker.HAND_CONNECTIONS.forEach { conn ->
                conn?.let {
                    canvas.drawLine(
                        landmark[it.start()].x() * imageWidth * scaleFactor + offsetX,
                        landmark[it.start()].y() * imageHeight * scaleFactor + offsetY,
                        landmark[it.end()].x() * imageWidth * scaleFactor + offsetX,
                        landmark[it.end()].y() * imageHeight * scaleFactor + offsetY,
                        linePaint
                    )
                }
            }
        }
    }

    companion object {
        private const val LANDMARK_STROKE_WIDTH = 6F
        private const val POSE_STROKE_WIDTH = 4F
        private const val POSE_POINT_RADIUS = 6F

        private val poseLandmarkIndices = listOf(0, 11, 12, 13, 14, 15, 16, 23, 24)

        private val POSE_CONNECTIONS = listOf(
            Pair(11, 12),
            Pair(11, 13),
            Pair(13, 15),
            Pair(12, 14),
            Pair(14, 16),
            Pair(11, 23),
            Pair(12, 24),
            Pair(23, 24),
            Pair(0, 11),
            Pair(0, 12)
        )
    }
}
