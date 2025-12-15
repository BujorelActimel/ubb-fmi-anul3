package com.traillogger.presentation.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.traillogger.domain.model.Trail
import com.traillogger.domain.usecase.DeleteTrailUseCase
import com.traillogger.domain.usecase.GetTrailUseCase
import com.traillogger.domain.usecase.UpdateTrailUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class TrailDetailViewModel @Inject constructor(
    private val getTrailUseCase: GetTrailUseCase,
    private val updateTrailUseCase: UpdateTrailUseCase,
    private val deleteTrailUseCase: DeleteTrailUseCase,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val trailId: Int = checkNotNull(savedStateHandle["trailId"])

    private val _uiState = MutableStateFlow<TrailDetailUiState>(TrailDetailUiState.Loading)
    val uiState: StateFlow<TrailDetailUiState> = _uiState.asStateFlow()

    private val _isEditMode = MutableStateFlow(false)
    val isEditMode: StateFlow<Boolean> = _isEditMode.asStateFlow()

    private val _editName = MutableStateFlow("")
    val editName: StateFlow<String> = _editName.asStateFlow()

    private val _editDescription = MutableStateFlow("")
    val editDescription: StateFlow<String> = _editDescription.asStateFlow()

    private val _editDifficulty = MutableStateFlow("easy")
    val editDifficulty: StateFlow<String> = _editDifficulty.asStateFlow()

    private val _editDistance = MutableStateFlow("")
    val editDistance: StateFlow<String> = _editDistance.asStateFlow()

    private val _editElevationGain = MutableStateFlow("")
    val editElevationGain: StateFlow<String> = _editElevationGain.asStateFlow()

    private val _saveState = MutableStateFlow<SaveState>(SaveState.Idle)
    val saveState: StateFlow<SaveState> = _saveState.asStateFlow()

    private var currentTrail: Trail? = null

    init {
        loadTrail()
    }

    fun loadTrail() {
        viewModelScope.launch {
            _uiState.value = TrailDetailUiState.Loading
            val result = getTrailUseCase(trailId)

            result.fold(
                onSuccess = { trail ->
                    currentTrail = trail
                    _editName.value = trail.name
                    _editDescription.value = trail.description ?: ""
                    _editDifficulty.value = trail.difficulty
                    _editDistance.value = trail.distance.toString()
                    _editElevationGain.value = trail.elevationGain?.toString() ?: ""
                    _uiState.value = TrailDetailUiState.Success(trail)
                },
                onFailure = { error ->
                    _uiState.value = TrailDetailUiState.Error(
                        error.message ?: "Failed to load trail"
                    )
                }
            )
        }
    }

    fun toggleEditMode() {
        _isEditMode.value = !_isEditMode.value
        if (!_isEditMode.value) {
            // Reset fields if canceling edit
            currentTrail?.let { trail ->
                _editName.value = trail.name
                _editDescription.value = trail.description ?: ""
                _editDifficulty.value = trail.difficulty
                _editDistance.value = trail.distance.toString()
                _editElevationGain.value = trail.elevationGain?.toString() ?: ""
            }
        }
    }

    fun onNameChange(name: String) {
        _editName.value = name
    }

    fun onDescriptionChange(description: String) {
        _editDescription.value = description
    }

    fun onDifficultyChange(difficulty: String) {
        _editDifficulty.value = difficulty
    }

    fun onDistanceChange(distance: String) {
        _editDistance.value = distance
    }

    fun onElevationGainChange(elevation: String) {
        _editElevationGain.value = elevation
    }

    fun saveChanges() {
        viewModelScope.launch {
            _saveState.value = SaveState.Saving

            val distance = _editDistance.value.toDoubleOrNull()
            val elevation = _editElevationGain.value.toIntOrNull()

            if (distance == null) {
                _saveState.value = SaveState.Error("Invalid distance value")
                return@launch
            }

            val result = updateTrailUseCase(
                id = trailId,
                name = _editName.value,
                description = _editDescription.value.ifBlank { null },
                difficulty = _editDifficulty.value,
                distance = distance,
                elevationGain = elevation
            )

            result.fold(
                onSuccess = { trail ->
                    currentTrail = trail
                    _uiState.value = TrailDetailUiState.Success(trail)
                    _isEditMode.value = false
                    _saveState.value = SaveState.Success
                },
                onFailure = { error ->
                    _saveState.value = SaveState.Error(
                        error.message ?: "Failed to save changes"
                    )
                }
            )
        }
    }

    fun deleteTrail(onDeleteSuccess: () -> Unit) {
        viewModelScope.launch {
            val result = deleteTrailUseCase(trailId)

            result.fold(
                onSuccess = {
                    onDeleteSuccess()
                },
                onFailure = { error ->
                    _saveState.value = SaveState.Error(
                        error.message ?: "Failed to delete trail"
                    )
                }
            )
        }
    }

    fun resetSaveState() {
        _saveState.value = SaveState.Idle
    }
}

sealed class TrailDetailUiState {
    object Loading : TrailDetailUiState()
    data class Success(val trail: Trail) : TrailDetailUiState()
    data class Error(val message: String) : TrailDetailUiState()
}

sealed class SaveState {
    object Idle : SaveState()
    object Saving : SaveState()
    object Success : SaveState()
    data class Error(val message: String) : SaveState()
}
