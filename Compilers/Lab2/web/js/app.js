let currentAutomaton = null;
let currentAutomatonJSON = null;
let visualizer = null;
let simulator = null;

document.addEventListener('DOMContentLoaded', async () => {
    await wasmAutomaton.ensureReady();

    visualizer = new GraphVisualizer('network');
    simulator = new Simulator(visualizer);

    setupEventListeners();
});

function setupEventListeners() {
    document.getElementById('file-upload').addEventListener('change', handleFileUpload);
    document.getElementById('parse-json-btn').addEventListener('click', parseManualJSON);

    document.getElementById('play-btn').addEventListener('click', handlePlay);
    document.getElementById('pause-btn').addEventListener('click', handlePause);
    document.getElementById('reset-btn').addEventListener('click', handleReset);

    document.getElementById('speed-slider').addEventListener('input', (e) => {
        const speed = parseInt(e.target.value);
        document.getElementById('speed-label').textContent = `${speed}ms`;
        simulator.setSpeed(speed);
    });

    document.getElementById('sequence-input').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            handlePlay();
        }
    });
}

async function handleFileUpload(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = async (event) => {
        try {
            await loadAutomaton(event.target.result);
        } catch (error) {
            alert('Eroare la încărcarea fișierului: ' + error.message);
        }
    };
    reader.readAsText(file);
}

async function parseManualJSON() {
    const jsonInput = document.getElementById('json-input').value.trim();
    if (!jsonInput) {
        alert('Introduceți JSON mai întâi!');
        return;
    }

    try {
        await loadAutomaton(jsonInput);
    } catch (error) {
        alert('Eroare la parsarea JSON: ' + error.message);
    }
}

async function loadAutomaton(jsonStr) {
    try {
        console.log('Loading automaton...');
        currentAutomatonJSON = jsonStr;
        currentAutomaton = JSON.parse(jsonStr);
        console.log('Parsed automaton:', currentAutomaton);

        const validation = await wasmAutomaton.parseAutomaton(jsonStr);
        console.log('WASM validation:', validation);
        if (validation.error) {
            throw new Error(validation.error);
        }

        console.log('Drawing graph...');
        visualizer.drawAutomaton(currentAutomaton);

        document.getElementById('no-automaton-message').classList.add('hidden');
        document.getElementById('main-view').classList.remove('hidden');

        displayAutomatonInfo(currentAutomaton, validation);

        document.getElementById('automaton-info').classList.remove('hidden');
        document.getElementById('simulation-controls').classList.remove('hidden');
        document.getElementById('play-btn').disabled = false;

        console.log('Automaton loaded successfully');
    } catch (error) {
        console.error('Error loading automaton:', error);
        throw error;
    }
}

function displayAutomatonInfo(automaton, validation) {
    document.getElementById('info-type').textContent = validation.type;
    document.getElementById('info-states').textContent = `{${automaton.states.join(', ')}}`;
    document.getElementById('info-alphabet-display').textContent = `{${automaton.alphabet.join(', ')}}`;
    document.getElementById('info-initial').textContent = automaton.initialState;
    document.getElementById('info-final').textContent = `{${automaton.finalStates.join(', ')}}`;
}

async function handlePlay() {
    if (!currentAutomaton || !currentAutomatonJSON) {
        alert('Încărcați mai întâi un automat!');
        return;
    }

    const sequence = document.getElementById('sequence-input').value;
    // Allow empty string (epsilon sequence)

    if (simulator.isPlaying) {
        return;
    }

    if (simulator.sequence !== sequence || simulator.currentStep === -1) {
        try {
            const result = await wasmAutomaton.simulateSequence(currentAutomatonJSON, sequence);
            console.log('WASM simulation result:', result);
            simulator.loadSimulation(sequence, result);
            simulator.renderSequence(-1, false);
        } catch (error) {
            console.error('Simulation error:', error);
            alert('Eroare la simulare: ' + error.message);
            return;
        }
    }

    document.getElementById('result-display').classList.add('hidden');

    simulator.play();
    document.getElementById('play-btn').classList.add('hidden');
    document.getElementById('pause-btn').classList.remove('hidden');
}

function handlePause() {
    simulator.pause();
    document.getElementById('play-btn').classList.remove('hidden');
    document.getElementById('pause-btn').classList.add('hidden');
}

function handleReset() {
    simulator.reset();
    document.getElementById('result-display').classList.add('hidden');
    document.getElementById('play-btn').classList.remove('hidden');
    document.getElementById('pause-btn').classList.add('hidden');
}
