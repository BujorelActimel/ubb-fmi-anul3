package com.traillogger.data.remote

import com.traillogger.data.remote.dto.*
import retrofit2.http.*

interface TrailApiService {

    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): LoginResponse

    @GET("api/trails")
    suspend fun getTrails(
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 100
    ): TrailsResponse

    @GET("api/trail")
    suspend fun getTrail(@Query("id") id: Int): TrailDetailResponse

    @PUT("api/trail")
    suspend fun updateTrail(
        @Query("id") id: Int,
        @Body request: UpdateTrailRequest
    ): TrailDetailResponse

    @DELETE("api/trail")
    suspend fun deleteTrail(@Query("id") id: Int)
}
