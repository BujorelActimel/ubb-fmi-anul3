package com.traillogger.data.repository

import com.traillogger.data.local.TokenManager
import com.traillogger.data.remote.TrailApiService
import com.traillogger.data.remote.dto.LoginRequest
import com.traillogger.domain.model.User
import com.traillogger.domain.repository.AuthRepository
import kotlinx.coroutines.flow.first
import javax.inject.Inject

class AuthRepositoryImpl @Inject constructor(
    private val api: TrailApiService,
    private val tokenManager: TokenManager
) : AuthRepository {

    override suspend fun login(email: String, password: String): Result<User> {
        return try {
            val response = api.login(LoginRequest(email, password))
            tokenManager.saveToken(response.token)
            Result.success(
                User(
                    id = response.user.id,
                    username = response.user.username,
                    email = response.user.email
                )
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun logout() {
        tokenManager.clearToken()
    }

    override suspend fun isLoggedIn(): Boolean {
        return tokenManager.token.first() != null
    }
}
