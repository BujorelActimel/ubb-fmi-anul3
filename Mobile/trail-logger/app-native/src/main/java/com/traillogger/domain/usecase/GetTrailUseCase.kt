package com.traillogger.domain.usecase

import com.traillogger.domain.model.Trail
import com.traillogger.domain.repository.TrailRepository
import javax.inject.Inject

class GetTrailUseCase @Inject constructor(
    private val trailRepository: TrailRepository
) {
    suspend operator fun invoke(id: Int): Result<Trail> {
        return trailRepository.getTrail(id)
    }
}
