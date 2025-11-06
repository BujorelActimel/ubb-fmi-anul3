class GraphVisualizer {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        this.svg = null;
        this.automaton = null;
        this.nodePositions = {};
        this.nodeElements = {};
        this.edgeElements = [];

        // Edit mode support
        this.mode = 'VIEW'; // 'VIEW' or 'EDIT'
        this.selectedState = null;
        this.dragState = null;
        this.dragStartPos = null;
        this.stateCounter = 0;

        // Store zoom/pan state
        this.scale = 1;
        this.translateX = 0;
        this.translateY = 0;
    }

    drawAutomaton(automaton) {
        console.log('Drawing automaton with custom SVG');
        this.automaton = automaton;

        this.container.innerHTML = '';

        const width = this.container.offsetWidth || 800;
        const height = this.container.offsetHeight || 600;

        this.svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        this.svg.setAttribute('width', '100%');
        this.svg.setAttribute('height', '100%');
        this.svg.setAttribute('viewBox', `0 0 ${width} ${height}`);
        this.svg.style.background = 'var(--bg-primary)';

        const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
        g.setAttribute('id', 'main-group');
        this.svg.appendChild(g);
        this.mainGroup = g;

        this.container.appendChild(this.svg);

        this.calculateNodePositions(width, height);
        this.drawEdges();
        this.drawNodes();

        this.setupZoomPan();

        // Enable dragging if in edit mode
        if (this.mode === 'EDIT') {
            this.makeNodesDraggable();
        }

        console.log('Graph drawn successfully');
    }

    setupZoomPan() {
        let isPanning = false;
        let startX, startY;

        this.svg.addEventListener('wheel', (e) => {
            e.preventDefault();
            const delta = e.deltaY > 0 ? 0.98 : 1.02;
            this.scale *= delta;
            this.scale = Math.min(Math.max(this.scale, 0.3), 3);
            this.mainGroup.setAttribute('transform', `translate(${this.translateX}, ${this.translateY}) scale(${this.scale})`);
        });

        this.svg.addEventListener('mousedown', (e) => {
            // Only pan if we're in VIEW mode or not clicking on a state
            if (this.mode === 'VIEW' || !e.target.closest('.node')) {
                isPanning = true;
                startX = e.clientX - this.translateX;
                startY = e.clientY - this.translateY;
                this.svg.style.cursor = 'grabbing';
            }
        });

        this.svg.addEventListener('mousemove', (e) => {
            if (!isPanning) return;
            this.translateX = e.clientX - startX;
            this.translateY = e.clientY - startY;
            this.mainGroup.setAttribute('transform', `translate(${this.translateX}, ${this.translateY}) scale(${this.scale})`);
        });

        this.svg.addEventListener('mouseup', () => {
            isPanning = false;
            this.svg.style.cursor = this.mode === 'EDIT' ? 'default' : 'grab';
        });

        this.svg.addEventListener('mouseleave', () => {
            isPanning = false;
            this.svg.style.cursor = 'default';
        });

        this.svg.style.cursor = this.mode === 'EDIT' ? 'default' : 'grab';
    }

    calculateNodePositions(width, height) {
        // Check if we have manual positions in the automaton data
        if (this.automaton.positions && Object.keys(this.automaton.positions).length > 0) {
            // Use manual positions
            this.nodePositions = { ...this.automaton.positions };
            return;
        }

        // Otherwise, use auto-layout (BFS-based hierarchical layout)
        const states = this.automaton.states;
        const numStates = states.length;

        // Handle empty automaton
        if (numStates === 0) {
            this.nodePositions = {};
            return;
        }

        const levels = {};
        const visited = new Set();

        // Only do BFS if we have an initial state
        let maxLevel = 0;
        if (this.automaton.initialState && states.includes(this.automaton.initialState)) {
            const queue = [[this.automaton.initialState, 0]];
            visited.add(this.automaton.initialState);
            levels[this.automaton.initialState] = 0;

            while (queue.length > 0) {
                const [state, level] = queue.shift();
                maxLevel = Math.max(maxLevel, level);

                const transitions = this.automaton.transitions[state] || {};
                for (const [symbol, toStates] of Object.entries(transitions)) {
                    for (const toState of toStates) {
                        if (!visited.has(toState)) {
                            visited.add(toState);
                            levels[toState] = level + 1;
                            queue.push([toState, level + 1]);
                        }
                    }
                }
            }
        }

        // Place any unvisited states
        for (const state of states) {
            if (levels[state] === undefined) {
                maxLevel++;
                levels[state] = maxLevel;
            }
        }

        const levelCounts = {};
        for (const [state, level] of Object.entries(levels)) {
            levelCounts[level] = (levelCounts[level] || 0) + 1;
        }

        const levelIndices = {};
        for (const level of Object.keys(levelCounts)) {
            levelIndices[level] = 0;
        }

        const marginX = 100;
        const marginY = 80;
        const levelWidth = (width - 2 * marginX) / (maxLevel || 1);

        for (const state of states) {
            const level = levels[state];
            const countAtLevel = levelCounts[level];
            const index = levelIndices[level]++;

            const x = marginX + level * levelWidth;
            const ySpacing = countAtLevel > 1 ? (height - 2 * marginY) / (countAtLevel - 1) : 0;
            const y = countAtLevel === 1 ? height / 2 : marginY + index * ySpacing;

            this.nodePositions[state] = { x, y };
        }
    }

    drawEdges() {
        const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');

        const marker = document.createElementNS('http://www.w3.org/2000/svg', 'marker');
        marker.setAttribute('id', 'arrowhead');
        marker.setAttribute('markerWidth', '10');
        marker.setAttribute('markerHeight', '10');
        marker.setAttribute('refX', '9');
        marker.setAttribute('refY', '3');
        marker.setAttribute('orient', 'auto');
        const polygon = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
        polygon.setAttribute('points', '0 0, 10 3, 0 6');
        polygon.setAttribute('fill', '#30363d');
        marker.appendChild(polygon);
        defs.appendChild(marker);

        const markerBlue = document.createElementNS('http://www.w3.org/2000/svg', 'marker');
        markerBlue.setAttribute('id', 'arrowhead-blue');
        markerBlue.setAttribute('markerWidth', '10');
        markerBlue.setAttribute('markerHeight', '10');
        markerBlue.setAttribute('refX', '9');
        markerBlue.setAttribute('refY', '3');
        markerBlue.setAttribute('orient', 'auto');
        const polygonBlue = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
        polygonBlue.setAttribute('points', '0 0, 10 3, 0 6');
        polygonBlue.setAttribute('fill', '#58a6ff');
        markerBlue.appendChild(polygonBlue);
        defs.appendChild(markerBlue);

        this.mainGroup.appendChild(defs);

        const edgeMap = {};
        for (const [fromState, transitions] of Object.entries(this.automaton.transitions)) {
            for (const [symbol, toStates] of Object.entries(transitions)) {
                for (const toState of toStates) {
                    const key = `${fromState}->${toState}`;
                    if (!edgeMap[key]) {
                        edgeMap[key] = [];
                    }
                    edgeMap[key].push(symbol);
                }
            }
        }

        for (const [key, symbols] of Object.entries(edgeMap)) {
            const [from, to] = key.split('->');
            this.drawEdge(from, to, symbols);
        }
    }

    drawEdge(from, to, symbols) {
        const fromPos = this.nodePositions[from];
        const toPos = this.nodePositions[to];

        if (!fromPos || !toPos) return;

        let label;
        if (symbols.length > 3) {
            label = `${symbols[0]}, ${symbols[1]}, ${symbols[2]}, ...`;
        } else {
            label = symbols.join(', ');
        }
        const fullLabel = symbols.join(', ');

        const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
        g.classList.add('edge');
        g.dataset.from = from;
        g.dataset.to = to;
        g.dataset.symbols = JSON.stringify(symbols);

        if (from === to) {
            const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');

            const nodeRadius = 25;
            const loopHeight = 45;
            const loopWidth = 35;

            const startAngle = -135 * Math.PI / 180;
            const endAngle = -45 * Math.PI / 180;

            const startX = fromPos.x + nodeRadius * Math.cos(startAngle);
            const startY = fromPos.y + nodeRadius * Math.sin(startAngle);
            const endX = fromPos.x + nodeRadius * Math.cos(endAngle);
            const endY = fromPos.y + nodeRadius * Math.sin(endAngle);

            const peakY = fromPos.y - loopHeight;
            const ctrl1X = startX - loopWidth;
            const ctrl1Y = startY - loopHeight * 0.6;
            const ctrl2X = endX + loopWidth;
            const ctrl2Y = endY - loopHeight * 0.6;

            const d = `M ${startX} ${startY}
                       C ${ctrl1X} ${ctrl1Y}, ${ctrl1X} ${peakY}, ${fromPos.x} ${peakY}
                       C ${ctrl2X} ${peakY}, ${ctrl2X} ${ctrl2Y}, ${endX} ${endY}`;

            path.setAttribute('d', d);
            path.setAttribute('fill', 'none');
            path.setAttribute('stroke', '#30363d');
            path.setAttribute('stroke-width', '2');
            path.setAttribute('marker-end', 'url(#arrowhead)');
            g.appendChild(path);

            const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
            text.setAttribute('x', fromPos.x);
            text.setAttribute('y', peakY - 8);
            text.setAttribute('text-anchor', 'middle');
            text.setAttribute('fill', '#8b949e');
            text.setAttribute('font-family', 'Courier New');
            text.setAttribute('font-size', '14');
            text.textContent = label;

            if (symbols.length > 3) {
                const title = document.createElementNS('http://www.w3.org/2000/svg', 'title');
                title.textContent = fullLabel;
                text.appendChild(title);
            }

            g.appendChild(text);
        } else {
            const dx = toPos.x - fromPos.x;
            const dy = toPos.y - fromPos.y;
            const dist = Math.sqrt(dx * dx + dy * dy);
            const offsetX = (dx / dist) * 25;
            const offsetY = (dy / dist) * 25;

            const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
            line.setAttribute('x1', fromPos.x + offsetX);
            line.setAttribute('y1', fromPos.y + offsetY);
            line.setAttribute('x2', toPos.x - offsetX);
            line.setAttribute('y2', toPos.y - offsetY);
            line.setAttribute('stroke', '#30363d');
            line.setAttribute('stroke-width', '2');
            line.setAttribute('marker-end', 'url(#arrowhead)');
            g.appendChild(line);

            const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
            text.setAttribute('x', (fromPos.x + toPos.x) / 2);
            text.setAttribute('y', (fromPos.y + toPos.y) / 2 - 5);
            text.setAttribute('text-anchor', 'middle');
            text.setAttribute('fill', '#8b949e');
            text.setAttribute('font-family', 'Courier New');
            text.setAttribute('font-size', '14');
            text.textContent = label;

            if (symbols.length > 3) {
                const title = document.createElementNS('http://www.w3.org/2000/svg', 'title');
                title.textContent = fullLabel;
                text.appendChild(title);
            }

            g.appendChild(text);
        }

        this.edgeElements.push(g);
        this.mainGroup.appendChild(g);
    }

    drawInitialArrow(pos) {
        const arrowLength = 40;
        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', pos.x - arrowLength - 25);
        line.setAttribute('y1', pos.y);
        line.setAttribute('x2', pos.x - 25);
        line.setAttribute('y2', pos.y);
        line.setAttribute('stroke', '#58a6ff');
        line.setAttribute('stroke-width', '2');
        line.setAttribute('marker-end', 'url(#arrowhead-blue)');
        this.mainGroup.appendChild(line);
    }

    drawNodes() {
        for (const state of this.automaton.states) {
            const pos = this.nodePositions[state];
            const isFinal = this.automaton.finalStates.includes(state);
            const isInitial = state === this.automaton.initialState;

            if (isInitial) {
                this.drawInitialArrow(pos);
            }

            const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
            g.classList.add('node');
            g.dataset.state = state;

            const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
            circle.setAttribute('cx', pos.x);
            circle.setAttribute('cy', pos.y);
            circle.setAttribute('r', '25');
            circle.setAttribute('fill', '#1a1f29');
            circle.setAttribute('stroke', isFinal ? '#58a6ff' : '#30363d');
            circle.setAttribute('stroke-width', isFinal ? '3' : '2');
            g.appendChild(circle);

            if (isFinal) {
                const innerCircle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
                innerCircle.setAttribute('cx', pos.x);
                innerCircle.setAttribute('cy', pos.y);
                innerCircle.setAttribute('r', '20');
                innerCircle.setAttribute('fill', 'none');
                innerCircle.setAttribute('stroke', '#58a6ff');
                innerCircle.setAttribute('stroke-width', '2');
                g.appendChild(innerCircle);
            }

            const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
            text.setAttribute('x', pos.x);
            text.setAttribute('y', pos.y + 5);
            text.setAttribute('text-anchor', 'middle');
            text.setAttribute('fill', '#e6edf3');
            text.setAttribute('font-family', 'Courier New');
            text.setAttribute('font-size', '14');
            text.setAttribute('font-weight', 'bold');
            text.textContent = state;
            g.appendChild(text);

            this.nodeElements[state] = g;
            this.mainGroup.appendChild(g);
        }
    }

    highlightStates(states) {
        for (const [state, g] of Object.entries(this.nodeElements)) {
            const circle = g.querySelector('circle');
            if (states.includes(state)) {
                circle.setAttribute('fill', '#d29922');
                circle.setAttribute('stroke', '#d29922');
            } else {
                const isFinal = this.automaton.finalStates.includes(state);
                circle.setAttribute('fill', '#1a1f29');
                circle.setAttribute('stroke', isFinal ? '#58a6ff' : '#30363d');
            }
        }
    }

    highlightTransitions(transitions) {
        this.edgeElements.forEach(edgeG => {
            const line = edgeG.querySelector('line, path');
            const symbols = JSON.parse(edgeG.dataset.symbols);
            const isActive = transitions.some(t =>
                edgeG.dataset.from === t.from &&
                edgeG.dataset.to === t.to &&
                symbols.includes(t.symbol)
            );

            if (line) {
                line.setAttribute('stroke', isActive ? '#d29922' : '#30363d');
                line.setAttribute('stroke-width', isActive ? '3' : '2');
            }
        });
    }

    reset() {
        this.highlightStates([]);
        this.highlightTransitions([]);
    }

    // Mode management methods
    enableEditMode() {
        this.mode = 'EDIT';
        this.svg.style.cursor = 'default';
        this.attachEditListeners();
    }

    disableEditMode() {
        this.mode = 'VIEW';
        this.svg.style.cursor = 'grab';
        this.selectedState = null;
        this.removeEditListeners();
        this.clearSelection();
    }

    attachEditListeners() {
        // Double-click to add state
        this.svg.addEventListener('dblclick', this.onCanvasDoubleClick.bind(this));

        // Keyboard listener for delete
        document.addEventListener('keydown', this.onKeyDown.bind(this));
    }

    removeEditListeners() {
        this.svg.removeEventListener('dblclick', this.onCanvasDoubleClick.bind(this));
        document.removeEventListener('keydown', this.onKeyDown.bind(this));
    }

    onCanvasDoubleClick(e) {
        if (this.mode !== 'EDIT') return;

        // Don't add state if clicking on an existing state
        if (e.target.closest('.node')) return;

        // Get click position relative to the SVG
        const rect = this.svg.getBoundingClientRect();
        const x = (e.clientX - rect.left - this.translateX) / this.scale;
        const y = (e.clientY - rect.top - this.translateY) / this.scale;

        // Generate new state name
        const newStateName = this.generateStateName();

        // Trigger callback to add state
        if (this.onStateAdded) {
            this.onStateAdded(newStateName, x, y);
        }
    }

    onKeyDown(e) {
        if (this.mode !== 'EDIT') return;

        if ((e.key === 'Delete' || e.key === 'Backspace') && this.selectedState) {
            e.preventDefault();
            if (this.onStateDeleted) {
                this.onStateDeleted(this.selectedState);
            }
        }
    }

    generateStateName() {
        // Find the next available q[n] name
        let name;
        do {
            name = `q${this.stateCounter++}`;
        } while (this.automaton && this.automaton.states.includes(name));
        return name;
    }

    selectState(stateName) {
        this.clearSelection();
        this.selectedState = stateName;
        const g = this.nodeElements[stateName];
        if (g) {
            const circle = g.querySelector('circle');
            circle.setAttribute('stroke', '#f0883e');
            circle.setAttribute('stroke-width', '3');
        }
    }

    clearSelection() {
        if (this.selectedState && this.nodeElements[this.selectedState]) {
            const g = this.nodeElements[this.selectedState];
            const circle = g.querySelector('circle');
            const isFinal = this.automaton.finalStates.includes(this.selectedState);
            circle.setAttribute('stroke', isFinal ? '#58a6ff' : '#30363d');
            circle.setAttribute('stroke-width', isFinal ? '3' : '2');
        }
        this.selectedState = null;
    }

    makeNodesDraggable() {
        for (const [state, g] of Object.entries(this.nodeElements)) {
            g.style.cursor = 'move';

            g.addEventListener('mousedown', (e) => {
                if (this.mode !== 'EDIT') return;
                e.stopPropagation();

                this.dragState = state;
                this.selectState(state);

                const pos = this.nodePositions[state];
                const rect = this.svg.getBoundingClientRect();
                this.dragStartPos = {
                    x: (e.clientX - rect.left - this.translateX) / this.scale - pos.x,
                    y: (e.clientY - rect.top - this.translateY) / this.scale - pos.y
                };
            });
        }

        this.svg.addEventListener('mousemove', (e) => {
            if (!this.dragState || this.mode !== 'EDIT') return;

            const rect = this.svg.getBoundingClientRect();
            const x = (e.clientX - rect.left - this.translateX) / this.scale - this.dragStartPos.x;
            const y = (e.clientY - rect.top - this.translateY) / this.scale - this.dragStartPos.y;

            this.updateStatePosition(this.dragState, x, y);
        });

        this.svg.addEventListener('mouseup', (e) => {
            if (this.dragState && this.mode === 'EDIT') {
                const state = this.dragState;
                const pos = this.nodePositions[state];

                // Trigger callback to save position
                if (this.onStatePositionChanged) {
                    this.onStatePositionChanged(state, pos.x, pos.y);
                }

                this.dragState = null;
                this.dragStartPos = null;
            }
        });
    }

    updateStatePosition(state, x, y) {
        this.nodePositions[state] = { x, y };

        // Update node position
        const g = this.nodeElements[state];
        if (g) {
            const circles = g.querySelectorAll('circle');
            circles.forEach(circle => {
                circle.setAttribute('cx', x);
                circle.setAttribute('cy', y);
            });
            const text = g.querySelector('text');
            if (text) {
                text.setAttribute('x', x);
                text.setAttribute('y', y + 5);
            }
        }

        // Update connected edges
        this.updateEdgesForState(state);
    }

    updateEdgesForState(state) {
        // Redraw all edges connected to this state
        this.edgeElements.forEach((edgeG, index) => {
            if (edgeG.dataset.from === state || edgeG.dataset.to === state) {
                const from = edgeG.dataset.from;
                const to = edgeG.dataset.to;
                const symbols = JSON.parse(edgeG.dataset.symbols);

                // Remove old edge
                edgeG.remove();

                // Redraw edge with new positions
                this.drawEdge(from, to, symbols);
            }
        });

        // Update edge elements array (filter out removed elements)
        this.edgeElements = Array.from(this.mainGroup.querySelectorAll('.edge'));

        // Redraw initial arrow if this is the initial state
        if (state === this.automaton.initialState) {
            const oldArrow = this.mainGroup.querySelector('line[marker-end="url(#arrowhead-blue)"]');
            if (oldArrow) oldArrow.remove();
            this.drawInitialArrow(this.nodePositions[state]);
        }
    }

    clearLayout() {
        // Clear all manual positions and recalculate layout
        this.automaton.positions = {};
        const width = this.container.offsetWidth || 800;
        const height = this.container.offsetHeight || 600;
        this.calculateNodePositions(width, height);
        this.drawAutomaton(this.automaton);
    }

    loadAutomaton(automaton) {
        this.automaton = automaton;
        this.drawAutomaton(automaton);

        // Make nodes draggable if in edit mode
        if (this.mode === 'EDIT') {
            this.makeNodesDraggable();
        }
    }
}
