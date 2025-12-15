package com.traillogger.domain.repository

import com.traillogger.domain.model.User

interface AuthRepository {
    suspend fun login(email: String, password: String): Result<User>
    suspend fun logout()
    suspend fun isLoggedIn(): Boolean
}
