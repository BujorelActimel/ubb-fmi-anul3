package com.traillogger.data.repository

import com.traillogger.data.remote.TrailApiService
import com.traillogger.data.remote.dto.UpdateTrailRequest
import com.traillogger.domain.model.Trail
import com.traillogger.domain.repository.TrailRepository
import javax.inject.Inject

class TrailRepositoryImpl @Inject constructor(
    private val api: TrailApiService
) : TrailRepository {

    override suspend fun getTrails(): Result<List<Trail>> {
        return try {
            val response = api.getTrails()
            Result.success(response.trails.map { it.toDomain() })
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getTrail(id: Int): Result<Trail> {
        return try {
            val response = api.getTrail(id)
            Result.success(
                Trail(
                    id = response.id,
                    userId = response.userId,
                    name = response.name,
                    description = response.description,
                    difficulty = response.difficulty,
                    distance = response.distance,
                    elevationGain = response.elevationGain,
                    startLat = response.startLat,
                    startLng = response.startLng,
                    endLat = response.endLat,
                    endLng = response.endLng,
                    status = response.status,
                    createdAt = response.createdAt,
                    updatedAt = response.updatedAt
                )
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun updateTrail(
        id: Int,
        name: String?,
        description: String?,
        difficulty: String?,
        distance: Double?,
        elevationGain: Int?
    ): Result<Trail> {
        return try {
            val request = UpdateTrailRequest(
                name = name,
                description = description,
                difficulty = difficulty,
                distance = distance,
                elevationGain = elevationGain
            )
            val response = api.updateTrail(id, request)
            Result.success(
                Trail(
                    id = response.id,
                    userId = response.userId,
                    name = response.name,
                    description = response.description,
                    difficulty = response.difficulty,
                    distance = response.distance,
                    elevationGain = response.elevationGain,
                    startLat = response.startLat,
                    startLng = response.startLng,
                    endLat = response.endLat,
                    endLng = response.endLng,
                    status = response.status,
                    createdAt = response.createdAt,
                    updatedAt = response.updatedAt
                )
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun deleteTrail(id: Int): Result<Unit> {
        return try {
            api.deleteTrail(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private fun com.traillogger.data.remote.dto.TrailDto.toDomain() = Trail(
        id = id,
        userId = userId,
        name = name,
        description = description,
        difficulty = difficulty,
        distance = distance,
        elevationGain = elevationGain,
        startLat = startLat,
        startLng = startLng,
        endLat = endLat,
        endLng = endLng,
        status = status,
        createdAt = createdAt,
        updatedAt = updatedAt
    )
}
