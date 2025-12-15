package com.traillogger.di

import com.traillogger.data.repository.AuthRepositoryImpl
import com.traillogger.data.repository.TrailRepositoryImpl
import com.traillogger.domain.repository.AuthRepository
import com.traillogger.domain.repository.TrailRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindAuthRepository(
        authRepositoryImpl: AuthRepositoryImpl
    ): AuthRepository

    @Binds
    @Singleton
    abstract fun bindTrailRepository(
        trailRepositoryImpl: TrailRepositoryImpl
    ): TrailRepository
}
