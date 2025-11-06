class WasmAutomaton {
    constructor() {
        this.ready = false;
        this.initPromise = this.init();
    }

    async init() {
        const go = new Go();

        try {
            const result = await WebAssembly.instantiateStreaming(
                fetch('core.wasm'),
                go.importObject
            );

            go.run(result.instance);
            this.ready = true;
            console.log('WASM loaded successfully');
        } catch (error) {
            console.error('Failed to load WASM:', error);
            throw error;
        }
    }

    async ensureReady() {
        await this.initPromise;
        if (!this.ready) {
            throw new Error('WASM not ready');
        }
    }

    async parseAutomaton(jsonStr) {
        await this.ensureReady();
        return parseAutomaton(jsonStr);
    }

    async simulateSequence(automatonJSON, sequence) {
        await this.ensureReady();
        return simulateSequence(automatonJSON, sequence);
    }

    async findLongestPrefix(automatonJSON, sequence) {
        await this.ensureReady();
        return findLongestPrefix(automatonJSON, sequence);
    }

    // Edit operations
    async addState(automatonJSON, stateName) {
        await this.ensureReady();
        return addState(automatonJSON, stateName);
    }

    async removeState(automatonJSON, stateName) {
        await this.ensureReady();
        return removeState(automatonJSON, stateName);
    }

    async renameState(automatonJSON, oldName, newName) {
        await this.ensureReady();
        return renameState(automatonJSON, oldName, newName);
    }

    async setInitialState(automatonJSON, stateName) {
        await this.ensureReady();
        return setInitialState(automatonJSON, stateName);
    }

    async toggleFinalState(automatonJSON, stateName) {
        await this.ensureReady();
        return toggleFinalState(automatonJSON, stateName);
    }

    async setStatePosition(automatonJSON, stateName, x, y) {
        await this.ensureReady();
        return setStatePosition(automatonJSON, stateName, x, y);
    }

    async addTransition(automatonJSON, from, symbol, to) {
        await this.ensureReady();
        return addTransition(automatonJSON, from, symbol, to);
    }

    async removeTransition(automatonJSON, from, symbol, to) {
        await this.ensureReady();
        return removeTransition(automatonJSON, from, symbol, to);
    }
}

const wasmAutomaton = new WasmAutomaton();
