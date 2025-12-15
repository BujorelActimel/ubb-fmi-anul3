package com.traillogger.domain.usecase

import com.traillogger.domain.repository.TrailRepository
import javax.inject.Inject

class DeleteTrailUseCase @Inject constructor(
    private val trailRepository: TrailRepository
) {
    suspend operator fun invoke(id: Int): Result<Unit> {
        return trailRepository.deleteTrail(id)
    }
}
