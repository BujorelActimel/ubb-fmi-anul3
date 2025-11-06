let currentAutomaton = null;
let editor = null;
let isPlaying = false;
let currentStep = -1;
let simulationResult = null;
let animationTimer = null;
let speed = 800;
let sequence = '';

document.addEventListener('DOMContentLoaded', async () => {
    await wasmAutomaton.ensureReady();

    editor = new AutomatonEditor('cy');

    editor.onUpdate = () => {
        updateAutomaton();
    };

    currentAutomaton = {
        states: [],
        alphabet: ['0', '1'],
        transitions: {},
        initialState: '',
        finalStates: [],
        positions: {}
    };

    setupEventListeners();
});

function setupEventListeners() {
    document.getElementById('clear-btn').addEventListener('click', (e) => {
        e.stopPropagation();
        handleNew();
    });
    document.getElementById('file-upload').addEventListener('change', handleFileUpload);
    document.getElementById('export-btn').addEventListener('click', handleExport);
    document.getElementById('auto-layout-btn').addEventListener('click', (e) => {
        e.stopPropagation();
        editor.autoLayout();
        updateAutomaton();
    });

    document.getElementById('play-btn').addEventListener('click', handlePlay);
    document.getElementById('pause-btn').addEventListener('click', handlePause);
    document.getElementById('reset-btn').addEventListener('click', handleReset);

    document.getElementById('speed-slider').addEventListener('input', (e) => {
        speed = parseInt(e.target.value);
        document.getElementById('speed-label').textContent = `${speed}ms`;
    });

    document.getElementById('sequence-input').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            handlePlay();
        }
    });

    // Sidebar toggle
    document.getElementById('sidebar-toggle').addEventListener('click', toggleSidebar);
    document.getElementById('sidebar-show').addEventListener('click', toggleSidebar);

    // Help button toggle
    document.getElementById('help-btn').addEventListener('click', (e) => {
        e.stopPropagation();
        toggleHelpPopup();
    });

    // Close help popup when clicking outside
    document.addEventListener('click', (e) => {
        const popup = document.getElementById('keyboard-help-popup');
        const helpBtn = document.getElementById('help-btn');
        if (!popup.contains(e.target) && e.target !== helpBtn && !helpBtn.contains(e.target)) {
            popup.classList.add('hidden');
        }
    });
}

function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const showBtn = document.getElementById('sidebar-show');

    sidebar.classList.toggle('collapsed');

    if (sidebar.classList.contains('collapsed')) {
        showBtn.classList.remove('hidden');
    } else {
        showBtn.classList.add('hidden');
    }
}

function toggleHelpPopup() {
    const popup = document.getElementById('keyboard-help-popup');
    popup.classList.toggle('hidden');
}

async function handleNew() {
    const confirmed = await editor.showConfirm('Automat Nou',
        'Șterge automatul curent?');

    if (confirmed) {
        currentAutomaton = {
            states: [],
            alphabet: ['0', '1'],
            transitions: {},
            initialState: '',
            finalStates: [],
            positions: {}
        };
        editor.loadAutomaton(currentAutomaton);
        hideStatus();
    }
}

async function handleFileUpload(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = async (event) => {
        try {
            const jsonStr = event.target.result;
            const automaton = JSON.parse(jsonStr);

            const validation = await wasmAutomaton.parseAutomaton(jsonStr);
            if (validation.error) {
                showStatus('error', 'Automat invalid: ' + validation.error);
                return;
            }

            currentAutomaton = automaton;
            editor.loadAutomaton(automaton);
            hideStatus();

            console.log('Automaton loaded successfully');
        } catch (error) {
            showStatus('error', 'Eroare la încărcarea fișierului: ' + error.message);
        }
    };
    reader.readAsText(file);
}

function handleExport() {
    updateAutomaton();

    const json = JSON.stringify(currentAutomaton, null, 2);
    const blob = new Blob([json], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'automaton.json';
    a.click();
    URL.revokeObjectURL(url);

    showStatus('success', 'Automaton exportat');
}

function updateAutomaton() {
    currentAutomaton = editor.toAutomaton();
}

async function handlePlay() {
    if (isPlaying) return;

    updateAutomaton();

    sequence = document.getElementById('sequence-input').value;

    try {
        const jsonStr = JSON.stringify(currentAutomaton);
        simulationResult = await wasmAutomaton.simulateSequence(jsonStr, sequence);

        console.log('Simulation result:', simulationResult);

        currentStep = -1;
        isPlaying = true;

        document.getElementById('play-btn').classList.add('hidden');
        document.getElementById('pause-btn').classList.remove('hidden');
        hideStatus();
        renderSequence(-1);

        playNextStep();
    } catch (error) {
        console.error('Simulation error:', error);
        showStatus('error', 'Eroare la simulare: ' + error.message);
    }
}

function renderSequence(charIndex) {
    const seqDiv = document.getElementById('sequence-display');

    if (!sequence) {
        seqDiv.innerHTML = '';
        return;
    }

    let html = '<div class="sequence-chars">';
    for (let i = 0; i < sequence.length; i++) {
        let className = 'seq-char';
        if (i < charIndex) {
            className += ' processed';
        } else if (i === charIndex) {
            className += ' current';
        }
        html += `<span class="${className}">${sequence[i]}</span>`;
    }
    html += '</div>';

    seqDiv.innerHTML = html;
}

function playNextStep() {
    if (!isPlaying || !simulationResult) return;

    currentStep++;

    if (currentStep >= simulationResult.steps.length) {
        finishSimulation();
        return;
    }

    const step = simulationResult.steps[currentStep];

    // Get source states (from transitions)
    const sourceStates = [...new Set(step.transitions.map(t => t.from))];

    // Animation: source state -> transition (with char) -> destination state
    // Step 1: Highlight source states (where we're coming from)
    editor.reset(); // Clear previous highlights
    editor.highlightStates(sourceStates);
    renderSequence(step.charIndex - 1); // No char highlighted yet

    setTimeout(() => {
        if (!isPlaying) return;

        // Step 2: Highlight transitions AND character being read
        editor.reset();
        editor.highlightTransitions(step.transitions);
        renderSequence(step.charIndex); // Highlight current character

        setTimeout(() => {
            if (!isPlaying) return;

            // Step 3: Highlight destination states (clear transitions first)
            editor.reset();
            editor.highlightStates(step.activeStates);

            // Schedule next step
            animationTimer = setTimeout(playNextStep, speed);
        }, speed / 3);
    }, speed / 3);
}

function finishSimulation() {
    isPlaying = false;

    document.getElementById('play-btn').classList.remove('hidden');
    document.getElementById('pause-btn').classList.add('hidden');

    editor.highlightStates(simulationResult.finalStates);
    renderSequence(sequence.length);

    if (simulationResult.accepted) {
        showStatus('success', 'Secvență acceptată');
    } else {
        if (simulationResult.error) {
            let errorMsg = 'Secvență respinsă: ';
            if (simulationResult.error.type === 'invalid_char') {
                errorMsg += 'Caracter invalid în alfabet';
            } else if (simulationResult.error.type === 'no_transition') {
                errorMsg += 'Lipsesc tranziții';
            } else if (simulationResult.error.type === 'not_final') {
                errorMsg += 'Nu s-a ajuns într-o stare finală';
            } else {
                errorMsg += simulationResult.error.message;
            }
            showStatus('error', errorMsg);
        } else {
            showStatus('error', 'Secvență respinsă');
        }
    }
}

function handlePause() {
    isPlaying = false;
    if (animationTimer) {
        clearTimeout(animationTimer);
        animationTimer = null;
    }

    document.getElementById('play-btn').classList.remove('hidden');
    document.getElementById('pause-btn').classList.add('hidden');
}

function handleReset() {
    handlePause();
    editor.reset();
    currentStep = -1;
    simulationResult = null;
    hideStatus();
    renderSequence(-1);
}

function showStatus(type, message) {
    const seqViewer = document.getElementById('sequence-display');
    seqViewer.innerHTML = `<div class="status-message status-${type}">${message}</div>`;
    seqViewer.classList.add('active');
}

function hideStatus() {
    const seqViewer = document.getElementById('sequence-display');
    seqViewer.innerHTML = '';
    seqViewer.classList.remove('active');
}
