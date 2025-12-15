package com.traillogger.domain.model

data class Trail(
    val id: Int,
    val userId: Int,
    val name: String,
    val description: String?,
    val difficulty: String,
    val distance: Double,
    val elevationGain: Int?,
    val startLat: Double,
    val startLng: Double,
    val endLat: Double?,
    val endLng: Double?,
    val status: String,
    val createdAt: String,
    val updatedAt: String
) {
    fun getDifficultyColor(): androidx.compose.ui.graphics.Color {
        return when (difficulty.lowercase()) {
            "easy" -> androidx.compose.ui.graphics.Color(0xFF4CAF50)
            "moderate" -> androidx.compose.ui.graphics.Color(0xFFFF9800)
            "hard" -> androidx.compose.ui.graphics.Color(0xFFF44336)
            else -> androidx.compose.ui.graphics.Color.Gray
        }
    }

    fun getFormattedDistance(): String {
        return String.format("%.1f km", distance)
    }
}
