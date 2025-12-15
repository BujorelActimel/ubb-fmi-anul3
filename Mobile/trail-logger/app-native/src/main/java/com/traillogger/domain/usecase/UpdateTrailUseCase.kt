package com.traillogger.domain.usecase

import com.traillogger.domain.model.Trail
import com.traillogger.domain.repository.TrailRepository
import javax.inject.Inject

class UpdateTrailUseCase @Inject constructor(
    private val trailRepository: TrailRepository
) {
    suspend operator fun invoke(
        id: Int,
        name: String?,
        description: String?,
        difficulty: String?,
        distance: Double?,
        elevationGain: Int?
    ): Result<Trail> {
        return trailRepository.updateTrail(id, name, description, difficulty, distance, elevationGain)
    }
}
