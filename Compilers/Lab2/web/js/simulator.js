class Simulator {
    constructor(visualizer) {
        this.visualizer = visualizer;
        this.currentStep = -1;
        this.subStep = 0;
        this.steps = [];
        this.sequence = '';
        this.isPlaying = false;
        this.animationInterval = null;
        this.speed = 800;
        this.result = null;
    }

    loadSimulation(sequence, result) {
        this.sequence = sequence;
        this.result = result;
        this.steps = result.steps || [];
        this.currentStep = -1;
        this.isPlaying = false;
        this.clearAnimation();
    }

    play() {
        if (this.isPlaying) return;
        this.isPlaying = true;
        this.subStep = 0;

        this.animationInterval = setInterval(() => {
            if (this.currentStep < this.steps.length - 1 || this.subStep < 3) {
                if (this.subStep === 0) {
                    this.currentStep++;
                }
                this.renderStep();
                this.subStep++;
                if (this.subStep > 3) {
                    this.subStep = 0;
                }
            } else {
                this.pause();
                this.showFinalResult();
            }
        }, this.speed / 4);
    }

    pause() {
        this.isPlaying = false;
        if (this.animationInterval) {
            clearInterval(this.animationInterval);
            this.animationInterval = null;
        }
    }

    reset() {
        this.pause();
        this.currentStep = -1;
        this.visualizer.reset();
        this.renderSequence(-1, false);
        this.updateActiveStates([]);
    }

    setSpeed(speed) {
        this.speed = speed;
        if (this.isPlaying) {
            this.pause();
            this.play();
        }
    }

    renderStep() {
        if (this.currentStep < 0 || this.currentStep >= this.steps.length) return;

        const step = this.steps[this.currentStep];
        const prevStep = this.currentStep > 0 ? this.steps[this.currentStep - 1] : null;

        this.renderSequence(step.charIndex, this.result.error && this.result.error.position === step.charIndex);

        if (this.subStep === 0) {
            const fromStates = prevStep ? prevStep.activeStates : [this.visualizer.automaton.initialState];
            this.visualizer.highlightStates(fromStates);
            this.visualizer.highlightTransitions([]);
            this.updateActiveStates(fromStates);
        } else if (this.subStep === 1) {
            const fromStates = prevStep ? prevStep.activeStates : [this.visualizer.automaton.initialState];
            this.visualizer.highlightStates(fromStates);
            this.visualizer.highlightTransitions(step.transitions);
            this.updateActiveStates(fromStates);
        } else if (this.subStep === 2) {
            this.visualizer.highlightStates(step.activeStates);
            this.visualizer.highlightTransitions(step.transitions);
            this.updateActiveStates(step.activeStates);
        } else {
            this.visualizer.highlightStates(step.activeStates);
            this.visualizer.highlightTransitions([]);
            this.updateActiveStates(step.activeStates);
        }
    }

    renderSequence(currentIndex, isError) {
        const container = document.getElementById('sequence-display');
        if (!container) return;

        container.classList.add('active');

        const chars = Array.from(this.sequence);
        const html = chars.map((char, i) => {
            let className = 'remaining';
            if (i < currentIndex) {
                className = 'processed';
            } else if (i === currentIndex) {
                className = isError ? 'error-char' : 'current';
            }
            return `<span class="${className}">${char}</span>`;
        }).join('');

        container.innerHTML = html;
    }

    updateActiveStates(states) {
        const container = document.getElementById('active-states-display');
        if (!container) return;

        if (states.length > 1) {
            container.classList.remove('hidden');
            container.innerHTML = `<strong>Stări active:</strong> {${states.join(', ')}}`;
        } else if (states.length === 1) {
            container.classList.remove('hidden');
            container.innerHTML = `<strong>Stare curentă:</strong> ${states[0]}`;
        } else {
            container.classList.add('hidden');
        }
    }

    showFinalResult() {
        const resultDiv = document.getElementById('result-display');
        const seqDiv = document.getElementById('sequence-display');

        if (!resultDiv) return;

        resultDiv.classList.remove('hidden', 'success', 'error', 'warning');

        if (this.result.error) {
            switch (this.result.error.type) {
                case 'invalid_char':
                    resultDiv.classList.add('error');
                    resultDiv.innerHTML = `
                        <strong>CARACTER INVALID</strong><br>
                        ${this.result.error.message}
                    `;
                    if (seqDiv) {
                        seqDiv.innerHTML = `<span style="color: var(--error); font-size: 18px;">✗ CARACTER INVALID</span>`;
                    }
                    break;
                case 'no_transition':
                    resultDiv.classList.add('warning');
                    resultDiv.innerHTML = `
                        <strong>TRANZIȚIE LIPSĂ</strong><br>
                        ${this.result.error.message}
                    `;
                    if (seqDiv) {
                        seqDiv.innerHTML = `<span style="color: var(--warning); font-size: 18px;">⚠ TRANZIȚIE LIPSĂ</span>`;
                    }
                    break;
                case 'not_final':
                    resultDiv.classList.add('error');
                    resultDiv.innerHTML = `
                        <strong>RESPINS</strong><br>
                        ${this.result.error.message}
                    `;
                    if (seqDiv) {
                        seqDiv.innerHTML = `<span style="color: var(--error); font-size: 18px;">✗ RESPINS</span>`;
                    }
                    break;
            }
        } else {
            resultDiv.classList.add('success');
            resultDiv.innerHTML = `
                <strong>ACCEPTAT</strong><br>
                Secvența a fost acceptată de automat.
            `;
            if (seqDiv) {
                seqDiv.innerHTML = `<span style="color: var(--success); font-size: 18px;">✓ ACCEPTAT</span>`;
            }
        }
    }

    clearAnimation() {
        this.pause();
        if (this.animationInterval) {
            clearInterval(this.animationInterval);
            this.animationInterval = null;
        }
    }
}
