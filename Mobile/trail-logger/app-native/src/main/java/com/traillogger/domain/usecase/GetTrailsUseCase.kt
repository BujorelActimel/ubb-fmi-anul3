package com.traillogger.domain.usecase

import com.traillogger.domain.model.Trail
import com.traillogger.domain.repository.TrailRepository
import javax.inject.Inject

class GetTrailsUseCase @Inject constructor(
    private val trailRepository: TrailRepository
) {
    suspend operator fun invoke(): Result<List<Trail>> {
        return trailRepository.getTrails()
    }
}
