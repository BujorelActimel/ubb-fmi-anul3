class GraphVisualizer {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        this.svg = null;
        this.automaton = null;
        this.nodePositions = {};
        this.nodeElements = {};
        this.edgeElements = [];
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

        console.log('Graph drawn successfully');
    }

    setupZoomPan() {
        let scale = 1;
        let translateX = 0;
        let translateY = 0;
        let isDragging = false;
        let startX, startY;

        this.svg.addEventListener('wheel', (e) => {
            e.preventDefault();
            const delta = e.deltaY > 0 ? 0.9 : 1.1;
            scale *= delta;
            scale = Math.min(Math.max(scale, 0.3), 3);
            this.mainGroup.setAttribute('transform', `translate(${translateX}, ${translateY}) scale(${scale})`);
        });

        this.svg.addEventListener('mousedown', (e) => {
            isDragging = true;
            startX = e.clientX - translateX;
            startY = e.clientY - translateY;
            this.svg.style.cursor = 'grabbing';
        });

        this.svg.addEventListener('mousemove', (e) => {
            if (!isDragging) return;
            translateX = e.clientX - startX;
            translateY = e.clientY - startY;
            this.mainGroup.setAttribute('transform', `translate(${translateX}, ${translateY}) scale(${scale})`);
        });

        this.svg.addEventListener('mouseup', () => {
            isDragging = false;
            this.svg.style.cursor = 'grab';
        });

        this.svg.addEventListener('mouseleave', () => {
            isDragging = false;
            this.svg.style.cursor = 'default';
        });

        this.svg.style.cursor = 'grab';
    }

    calculateNodePositions(width, height) {
        const states = this.automaton.states;
        const numStates = states.length;

        const centerX = width / 2;
        const centerY = height / 2;
        const radius = Math.min(width, height) * 0.35;

        states.forEach((state, i) => {
            const angle = (2 * Math.PI * i) / numStates - Math.PI / 2;
            this.nodePositions[state] = {
                x: centerX + radius * Math.cos(angle),
                y: centerY + radius * Math.sin(angle)
            };
        });
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
        if (symbols.length > 4) {
            label = `${symbols[0]}, ..., ${symbols[symbols.length - 1]}`;
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

            if (symbols.length > 4) {
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

            if (symbols.length > 4) {
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
}
