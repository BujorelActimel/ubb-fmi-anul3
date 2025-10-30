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
}

const wasmAutomaton = new WasmAutomaton();
