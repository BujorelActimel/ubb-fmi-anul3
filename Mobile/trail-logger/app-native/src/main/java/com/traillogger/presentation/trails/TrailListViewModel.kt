package com.traillogger.presentation.trails

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.traillogger.domain.model.Trail
import com.traillogger.domain.usecase.GetTrailsUseCase
import com.traillogger.domain.usecase.LogoutUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class TrailListViewModel @Inject constructor(
    private val getTrailsUseCase: GetTrailsUseCase,
    private val logoutUseCase: LogoutUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow<TrailListUiState>(TrailListUiState.Loading)
    val uiState: StateFlow<TrailListUiState> = _uiState.asStateFlow()

    init {
        loadTrails()
    }

    fun loadTrails() {
        viewModelScope.launch {
            _uiState.value = TrailListUiState.Loading
            val result = getTrailsUseCase()

            result.fold(
                onSuccess = { trails ->
                    _uiState.value = TrailListUiState.Success(trails)
                },
                onFailure = { error ->
                    _uiState.value = TrailListUiState.Error(
                        error.message ?: "Failed to load trails"
                    )
                }
            )
        }
    }

    fun logout(onLogoutComplete: () -> Unit) {
        viewModelScope.launch {
            logoutUseCase()
            onLogoutComplete()
        }
    }
}

sealed class TrailListUiState {
    object Loading : TrailListUiState()
    data class Success(val trails: List<Trail>) : TrailListUiState()
    data class Error(val message: String) : TrailListUiState()
}
