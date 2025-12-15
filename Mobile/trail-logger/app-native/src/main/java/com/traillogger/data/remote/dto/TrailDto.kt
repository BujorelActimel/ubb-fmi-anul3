package com.traillogger.data.remote.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class TrailDto(
    val id: Int,
    @SerialName("user_id")
    val userId: Int,
    val name: String,
    val description: String? = null,
    val difficulty: String,
    val distance: Double,
    @SerialName("elevation_gain")
    val elevationGain: Int? = null,
    @SerialName("start_lat")
    val startLat: Double,
    @SerialName("start_lng")
    val startLng: Double,
    @SerialName("end_lat")
    val endLat: Double? = null,
    @SerialName("end_lng")
    val endLng: Double? = null,
    val status: String,
    @SerialName("created_at")
    val createdAt: String,
    @SerialName("updated_at")
    val updatedAt: String
)

@Serializable
data class TrailsResponse(
    val trails: List<TrailDto>,
    val total: Int,
    val page: Int,
    val limit: Int
)

@Serializable
data class TrailDetailResponse(
    val id: Int,
    @SerialName("user_id")
    val userId: Int,
    val name: String,
    val description: String? = null,
    val difficulty: String,
    val distance: Double,
    @SerialName("elevation_gain")
    val elevationGain: Int? = null,
    @SerialName("start_lat")
    val startLat: Double,
    @SerialName("start_lng")
    val startLng: Double,
    @SerialName("end_lat")
    val endLat: Double? = null,
    @SerialName("end_lng")
    val endLng: Double? = null,
    val status: String,
    @SerialName("created_at")
    val createdAt: String,
    @SerialName("updated_at")
    val updatedAt: String
)

@Serializable
data class UpdateTrailRequest(
    val name: String? = null,
    val description: String? = null,
    val difficulty: String? = null,
    val distance: Double? = null,
    @SerialName("elevation_gain")
    val elevationGain: Int? = null,
    val status: String? = null
)
