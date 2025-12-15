package com.traillogger.domain.repository

import com.traillogger.domain.model.Trail

interface TrailRepository {
    suspend fun getTrails(): Result<List<Trail>>
    suspend fun getTrail(id: Int): Result<Trail>
    suspend fun updateTrail(
        id: Int,
        name: String? = null,
        description: String? = null,
        difficulty: String? = null,
        distance: Double? = null,
        elevationGain: Int? = null
    ): Result<Trail>
    suspend fun deleteTrail(id: Int): Result<Unit>
}
