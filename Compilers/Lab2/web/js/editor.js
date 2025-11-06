class AutomatonEditor {
    constructor(containerId) {
        this.modalResolve = null;
        this.selectedNode = null;
        this.selectedEdge = null;
        this.transitionMode = false;
        this.transitionSourceNode = null;

        this.cy = cytoscape({
            container: document.getElementById(containerId),

            userPanningEnabled: true,
            userZoomingEnabled: true,
            boxSelectionEnabled: false,
            autounselectify: false,
            autoungrabify: false,

            style: [
                {
                    selector: 'node',
                    style: {
                        'background-color': '#1a1f29',
                        'border-color': '#30363d',
                        'border-width': 2,
                        'label': 'data(id)',
                        'color': '#e6edf3',
                        'text-valign': 'center',
                        'text-halign': 'center',
                        'font-size': '14px',
                        'font-family': 'Courier New',
                        'width': 50,
                        'height': 50
                    }
                },
                {
                    selector: 'node.final',
                    style: {
                        'border-color': '#58a6ff',
                        'border-width': 4
                    }
                },
                {
                    selector: 'node.selected',
                    style: {
                        'border-color': '#f0883e',
                        'border-width': 4
                    }
                },
                {
                    selector: 'node.temp-selected',
                    style: {
                        'border-color': '#d29922',
                        'border-width': 4,
                        'background-color': 'rgba(210, 153, 34, 0.2)'
                    }
                },
                {
                    selector: 'node.active',
                    style: {
                        'background-color': '#d29922',
                        'border-color': '#d29922'
                    }
                },
                {
                    selector: 'edge',
                    style: {
                        'width': 2,
                        'line-color': '#30363d',
                        'target-arrow-color': '#30363d',
                        'target-arrow-shape': 'triangle',
                        'curve-style': 'bezier',
                        'label': 'data(displayLabel)',
                        'color': '#8b949e',
                        'font-size': '12px',
                        'text-rotation': 'autorotate',
                        'text-margin-y': -10
                    }
                },
                {
                    selector: 'edge.selected',
                    style: {
                        'line-color': '#f0883e',
                        'target-arrow-color': '#f0883e',
                        'width': 4
                    }
                },
                {
                    selector: 'edge.active',
                    style: {
                        'line-color': '#d29922',
                        'target-arrow-color': '#d29922',
                        'width': 3
                    }
                },
                // Initial state arrow (fake edge)
                {
                    selector: 'edge.initial-arrow',
                    style: {
                        'width': 4,
                        'line-color': '#58a6ff',
                        'target-arrow-color': '#58a6ff',
                        'target-arrow-shape': 'triangle',
                        'target-arrow-size': 2,
                        'curve-style': 'bezier',
                        'opacity': 1
                    }
                },
                {
                    selector: 'node.helper-node',
                    style: {
                        'opacity': 0,
                        'width': 1,
                        'height': 1
                    }
                }
            ],

            layout: {
                name: 'preset'
            }
        });

        this.stateCounter = 0;
        this.setupInteractions();
    }

    setupInteractions() {
        // Click on canvas to add state
        this.cy.on('tap', (e) => {
            if (e.target === this.cy) {
                // Check if click is on a button (ignore if so)
                const originalEvent = e.originalEvent;
                if (originalEvent && originalEvent.target) {
                    const target = originalEvent.target;
                    if (target.closest('.editor-btn')) {
                        return; // Ignore clicks on editor buttons
                    }
                }

                const pos = e.position;
                this.addStateWithDialog(pos);
                this.deselectNode();
                this.deselectEdge();
                this.exitTransitionMode();
            }
        });

        // Click on node - select or create transition
        this.cy.on('tap', 'node', async (e) => {
            const node = e.target;

            if (this.transitionMode && this.transitionSourceNode) {
                // In transition mode - create transition to clicked node
                const from = this.transitionSourceNode.id();
                const to = node.id();
                const renderedPos = node.renderedPosition();

                const result = await this.showModal('Adaugă Tranziție', [
                    { type: 'text', name: 'symbols', label: 'Simboluri (separate prin virgulă):', value: '' }
                ], { x: renderedPos.x + 40, y: renderedPos.y - 20 });

                if (result && result.symbols) {
                    result.symbols.split(',').forEach(s => {
                        const symbol = s.trim();
                        if (symbol) {
                            this.addTransition(from, to, symbol);
                        }
                    });
                    if (this.onUpdate) this.onUpdate();
                }

                this.exitTransitionMode();
            } else {
                // Regular click - select node
                this.selectNode(node);
            }
        });

        // Click on edge to select
        this.cy.on('tap', 'edge', (e) => {
            if (!e.target.hasClass('initial-arrow')) {
                this.selectEdge(e.target);
            }
        });

        // Right-click on edge to delete
        this.cy.on('cxttap', 'edge', async (e) => {
            if (!e.target.hasClass('initial-arrow')) {
                const edge = e.target;
                const midpoint = edge.renderedMidpoint();

                const confirmed = await this.showConfirm('Șterge Tranziție',
                    'Șterge tranziția?',
                    { x: midpoint.x + 20, y: midpoint.y });

                if (confirmed) {
                    edge.remove();
                    if (this.onUpdate) this.onUpdate();
                }
            }
        });

        // Update initial arrow when nodes are moved
        this.cy.on('position', 'node', () => {
            this.updateInitialArrow();
        });

        // Tooltip for edge labels on hover
        let tooltip = null;
        this.cy.on('mouseover', 'edge', (e) => {
            const edge = e.target;
            if (edge.hasClass('initial-arrow')) return;

            const fullLabel = edge.data('fullLabel');
            if (!fullLabel) return;

            // Create tooltip
            tooltip = document.createElement('div');
            tooltip.className = 'edge-tooltip';
            tooltip.textContent = fullLabel;
            document.body.appendChild(tooltip);

            // Position tooltip near mouse
            const updateTooltipPosition = (event) => {
                if (tooltip) {
                    tooltip.style.left = event.pageX + 10 + 'px';
                    tooltip.style.top = event.pageY + 10 + 'px';
                }
            };

            updateTooltipPosition(e.originalEvent);
            this.cy.on('mousemove', updateTooltipPosition);
        });

        this.cy.on('mouseout', 'edge', () => {
            if (tooltip) {
                tooltip.remove();
                tooltip = null;
                this.cy.off('mousemove');
            }
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
                return; // Don't trigger shortcuts when typing in inputs
            }

            if (this.selectedNode) {
                if (e.key === 'n') {
                    // Enter transition mode
                    this.enterTransitionMode();
                } else if (e.key === 'd') {
                    // Delete selected node
                    this.deleteSelectedNode();
                } else if (e.key === 'e') {
                    // Edit selected node
                    this.editNode(this.selectedNode);
                } else if (e.key === 'Escape') {
                    // Deselect or exit transition mode
                    if (this.transitionMode) {
                        this.exitTransitionMode();
                    } else {
                        this.deselectNode();
                    }
                }
            } else if (this.selectedEdge) {
                if (e.key === 'd') {
                    // Delete selected edge
                    this.deleteSelectedEdge();
                } else if (e.key === 'e') {
                    // Edit selected edge
                    this.editEdge(this.selectedEdge);
                } else if (e.key === 'Escape') {
                    // Deselect edge
                    this.deselectEdge();
                }
            }
        });
    }

    selectNode(node) {
        this.deselectNode();
        this.deselectEdge();
        this.selectedNode = node;
        node.addClass('selected');
    }

    deselectNode() {
        if (this.selectedNode) {
            this.selectedNode.removeClass('selected');
            this.selectedNode = null;
        }
    }

    selectEdge(edge) {
        this.deselectNode();
        this.deselectEdge();
        this.selectedEdge = edge;
        edge.addClass('selected');
    }

    deselectEdge() {
        if (this.selectedEdge) {
            this.selectedEdge.removeClass('selected');
            this.selectedEdge = null;
        }
    }

    enterTransitionMode() {
        if (!this.selectedNode) return;
        this.transitionMode = true;
        this.transitionSourceNode = this.selectedNode;
        this.transitionSourceNode.addClass('temp-selected');
    }

    exitTransitionMode() {
        this.transitionMode = false;
        if (this.transitionSourceNode) {
            this.transitionSourceNode.removeClass('temp-selected');
            this.transitionSourceNode = null;
        }
    }

    async deleteSelectedNode() {
        if (!this.selectedNode) return;

        const node = this.selectedNode;
        const renderedPos = node.renderedPosition();

        const confirmed = await this.showConfirm('Șterge Stare',
            `Șterge starea "${node.id()}"?`,
            { x: renderedPos.x + 40, y: renderedPos.y - 20 });

        if (confirmed) {
            this.deselectNode();
            node.remove();
            this.updateInitialArrow();
            if (this.onUpdate) this.onUpdate();
        }
    }

    async deleteSelectedEdge() {
        if (!this.selectedEdge) return;

        const edge = this.selectedEdge;
        const midpoint = edge.renderedMidpoint();

        const confirmed = await this.showConfirm('Șterge Tranziție',
            'Șterge tranziția?',
            { x: midpoint.x + 10, y: midpoint.y - 10 });

        if (confirmed) {
            this.deselectEdge();
            edge.remove();
            if (this.onUpdate) this.onUpdate();
        }
    }

    async addStateWithDialog(position) {
        // Create a temporary invisible node to get rendered position
        const tempId = 'temp-position-node-' + Date.now();
        this.cy.add({
            group: 'nodes',
            data: { id: tempId },
            position: position,
            style: { 'opacity': 0 }
        });

        const tempNode = this.cy.getElementById(tempId);
        const renderedPos = tempNode.renderedPosition();
        tempNode.remove();

        const result = await this.showModal('Adaugă Stare', [
            { type: 'text', name: 'name', label: 'Nume stare:', value: `q${this.stateCounter}` },
            { type: 'checkbox', name: 'isFinal', label: 'Stare finală?', value: false }
        ], { x: renderedPos.x + 40, y: renderedPos.y - 20 });

        if (!result || !result.name) return;

        this.cy.add({
            group: 'nodes',
            data: { id: result.name },
            position: position || { x: 200, y: 200 }
        });

        const node = this.cy.getElementById(result.name);

        // If first state, make it initial
        if (this.cy.nodes().filter(n => !n.hasClass('helper-node')).length === 1) {
            node.addClass('initial');
            this.updateInitialArrow();
        }

        if (result.isFinal) {
            node.addClass('final');
        }

        this.stateCounter++;

        if (this.onUpdate) this.onUpdate();
    }

    async editNode(node) {
        const currentName = node.id();
        const renderedPos = node.renderedPosition();

        const result = await this.showModal('Editează Stare', [
            { type: 'text', name: 'name', label: 'Nume stare:', value: currentName },
            { type: 'checkbox', name: 'isInitial', label: 'Stare inițială?', value: node.hasClass('initial') },
            { type: 'checkbox', name: 'isFinal', label: 'Stare finală?', value: node.hasClass('final') }
        ], { x: renderedPos.x + 40, y: renderedPos.y - 20 });

        if (!result) return;

        const newName = result.name;

        if (newName && newName !== currentName) {
            // Update all edges that reference this node
            this.cy.edges().forEach(edge => {
                if (edge.source().id() === currentName) {
                    edge.move({ source: newName });
                }
                if (edge.target().id() === currentName) {
                    edge.move({ target: newName });
                }
            });

            node.data('id', newName);
        }

        if (result.isInitial) {
            this.cy.nodes().removeClass('initial');
            node.addClass('initial');
            this.updateInitialArrow();
        } else {
            node.removeClass('initial');
            if (this.cy.nodes('.initial').length === 0) {
                this.updateInitialArrow();
            }
        }

        if (result.isFinal) {
            node.addClass('final');
        } else {
            node.removeClass('final');
        }

        this.deselectNode(); // Auto-deselect after edit
        if (this.onUpdate) this.onUpdate();
    }

    async editEdge(edge) {
        const fullLabel = edge.data('fullLabel') || edge.data('displayLabel') || '';
        const midpoint = edge.renderedMidpoint();

        const result = await this.showModal('Editează Tranziție', [
            { type: 'text', name: 'symbols', label: 'Simboluri (separate prin virgulă):', value: fullLabel }
        ], { x: midpoint.x + 10, y: midpoint.y - 10 });

        if (result === null) return;

        const symbols = result.symbols;
        if (symbols.trim() === '') {
            edge.remove();
        } else {
            const symbolList = symbols.split(',').map(s => s.trim()).filter(s => s);
            this.updateEdgeLabel(edge, symbolList);
        }
        this.deselectEdge(); // Auto-deselect after edit
        if (this.onUpdate) this.onUpdate();
    }

    updateEdgeLabel(edge, symbols) {
        const fullLabel = symbols.join(', ');
        let displayLabel;

        if (symbols.length > 3) {
            displayLabel = `${symbols[0]}, ..., ${symbols[symbols.length - 1]}`;
        } else {
            displayLabel = fullLabel;
        }

        edge.data('fullLabel', fullLabel);
        edge.data('displayLabel', displayLabel);
    }

    addTransition(from, to, symbol) {
        const existingEdge = this.cy.edges(`[source = "${from}"][target = "${to}"]`).filter(e => !e.hasClass('initial-arrow'));

        if (existingEdge.length > 0) {
            // Add to existing edge
            const fullLabel = existingEdge.data('fullLabel') || existingEdge.data('displayLabel') || '';
            const symbols = fullLabel.split(',').map(s => s.trim()).filter(s => s);

            if (!symbols.includes(symbol)) {
                symbols.push(symbol);
                this.updateEdgeLabel(existingEdge, symbols);
            }
        } else {
            // Create new edge
            const edge = this.cy.add({
                group: 'edges',
                data: {
                    id: `${from}-${to}-${Date.now()}`,
                    source: from,
                    target: to,
                    fullLabel: symbol,
                    displayLabel: symbol
                }
            });
        }
    }

    updateInitialArrow() {
        // Remove old arrow and helper
        this.cy.nodes('[id *= "initial-helper"]').remove();
        this.cy.edges('.initial-arrow').remove();

        const initialNode = this.cy.nodes('.initial').first();
        if (initialNode.length === 0) return;

        const pos = initialNode.position();

        // Create invisible helper node (locked in place)
        const helperId = 'initial-helper-' + Date.now();
        this.cy.add({
            group: 'nodes',
            data: { id: helperId },
            position: { x: pos.x - 70, y: pos.y },
            classes: 'helper-node'
        });

        const helperNode = this.cy.getElementById(helperId);
        helperNode.lock();
        helperNode.ungrabify();
        helperNode.unselectify();

        // Create arrow from helper to initial node
        this.cy.add({
            group: 'edges',
            data: {
                id: 'initial-arrow-edge-' + Date.now(),
                source: helperId,
                target: initialNode.id()
            },
            selectable: false,
            classes: 'initial-arrow'
        });
    }

    autoLayout() {
        // Get all nodes and find initial node
        const initialNode = this.cy.nodes('.initial').first();
        if (!initialNode || initialNode.length === 0) return;

        // Use BFS to arrange nodes horizontally
        const visited = new Set();
        const positions = new Map();
        const queue = [{node: initialNode, level: 0, index: 0}];
        const levelCounts = new Map();

        // BFS to calculate positions
        while (queue.length > 0) {
            const {node, level, index} = queue.shift();
            const nodeId = node.id();

            if (visited.has(nodeId)) continue;
            visited.add(nodeId);

            // Track how many nodes at this level
            if (!levelCounts.has(level)) {
                levelCounts.set(level, 0);
            }
            const yIndex = levelCounts.get(level);
            levelCounts.set(level, yIndex + 1);

            // Position: x based on level (horizontal), y based on index at level
            positions.set(nodeId, {
                x: 100 + level * 200,
                y: 100 + yIndex * 120
            });

            // Find outgoing edges
            const outgoingEdges = node.connectedEdges().filter(e =>
                e.source().id() === nodeId && !e.hasClass('initial-arrow')
            );

            outgoingEdges.forEach(edge => {
                const targetNode = edge.target();
                if (!visited.has(targetNode.id())) {
                    queue.push({node: targetNode, level: level + 1, index: 0});
                }
            });
        }

        // Apply positions
        this.cy.nodes().filter(n => !n.hasClass('helper-node')).forEach(node => {
            const pos = positions.get(node.id());
            if (pos) {
                node.position(pos);
            }
        });

        this.updateInitialArrow();
    }

    loadAutomaton(automaton) {
        this.cy.elements().remove();

        if (!automaton || !automaton.states) return;

        // Add states
        automaton.states.forEach((state, index) => {
            const pos = automaton.positions && automaton.positions[state]
                ? automaton.positions[state]
                : { x: 100 + index * 100, y: 200 };

            this.cy.add({
                group: 'nodes',
                data: { id: state },
                position: pos
            });
        });

        // Mark initial state
        if (automaton.initialState) {
            this.cy.getElementById(automaton.initialState).addClass('initial');
        }

        // Mark final states
        if (automaton.finalStates) {
            automaton.finalStates.forEach(state => {
                this.cy.getElementById(state).addClass('final');
            });
        }

        // Add transitions
        if (automaton.transitions) {
            Object.entries(automaton.transitions).forEach(([from, transitions]) => {
                Object.entries(transitions).forEach(([symbol, toStates]) => {
                    toStates.forEach(to => {
                        this.addTransition(from, to, symbol);
                    });
                });
            });
        }

        // Update counter
        const maxNum = Math.max(...automaton.states.map(s => {
            const match = s.match(/q(\d+)/);
            return match ? parseInt(match[1]) : -1;
        }), -1);
        this.stateCounter = maxNum + 1;

        // Auto-layout if no positions
        if (!automaton.positions || Object.keys(automaton.positions).length === 0) {
            this.autoLayout();
        } else {
            this.updateInitialArrow();
        }
    }

    toAutomaton() {
        const states = this.cy.nodes().filter(n => !n.id().includes('helper')).map(n => n.id());
        const initialState = this.cy.nodes('.initial').first().id() || '';
        const finalStates = this.cy.nodes('.final').map(n => n.id());

        const positions = {};
        this.cy.nodes().filter(n => !n.id().includes('helper')).forEach(node => {
            positions[node.id()] = node.position();
        });

        const transitions = {};
        const alphabetSet = new Set();

        this.cy.edges().filter(e => !e.hasClass('initial-arrow')).forEach(edge => {
            const from = edge.source().id();
            const to = edge.target().id();
            const fullLabel = edge.data('fullLabel') || edge.data('displayLabel') || '';
            const symbols = fullLabel.split(',').map(s => s.trim()).filter(s => s);

            if (!transitions[from]) {
                transitions[from] = {};
            }

            symbols.forEach(symbol => {
                alphabetSet.add(symbol);

                if (!transitions[from][symbol]) {
                    transitions[from][symbol] = [];
                }
                if (!transitions[from][symbol].includes(to)) {
                    transitions[from][symbol].push(to);
                }
            });
        });

        const alphabet = Array.from(alphabetSet).sort();

        return {
            states,
            alphabet: alphabet.length > 0 ? alphabet : ['0', '1'],
            transitions,
            initialState,
            finalStates,
            positions
        };
    }

    highlightStates(states) {
        this.cy.nodes().removeClass('active');
        states.forEach(state => {
            this.cy.getElementById(state).addClass('active');
        });
    }

    highlightTransitions(transitions) {
        this.cy.edges().filter(e => !e.hasClass('initial-arrow')).removeClass('active');
        transitions.forEach(t => {
            const edges = this.cy.edges().filter(e =>
                e.source().id() === t.from &&
                e.target().id() === t.to &&
                !e.hasClass('initial-arrow')
            );
            edges.addClass('active');
        });
    }

    reset() {
        this.cy.elements().removeClass('active');
    }

    async showModal(title, fields, position) {
        return new Promise((resolve) => {
            this.modalResolve = resolve;

            const modal = document.getElementById('custom-modal');
            const modalTitle = document.getElementById('modal-title');
            const modalBody = document.getElementById('modal-body');

            modalTitle.textContent = title;
            modalBody.innerHTML = '';

            // Create form fields
            const formData = {};
            fields.forEach(field => {
                if (field.type === 'text') {
                    const label = document.createElement('label');
                    label.textContent = field.label;
                    const input = document.createElement('input');
                    input.type = 'text';
                    input.value = field.value || '';
                    input.id = 'modal-field-' + field.name;
                    modalBody.appendChild(label);
                    modalBody.appendChild(input);
                    formData[field.name] = input;

                    // Auto-focus first field
                    if (fields.indexOf(field) === 0) {
                        setTimeout(() => input.focus(), 50);
                    }
                } else if (field.type === 'checkbox') {
                    const checkboxDiv = document.createElement('div');
                    checkboxDiv.className = 'checkbox-wrapper';
                    const input = document.createElement('input');
                    input.type = 'checkbox';
                    input.checked = field.value || false;
                    input.id = 'modal-field-' + field.name;
                    const label = document.createElement('label');
                    label.textContent = field.label;
                    label.htmlFor = input.id;
                    checkboxDiv.appendChild(input);
                    checkboxDiv.appendChild(label);
                    modalBody.appendChild(checkboxDiv);
                    formData[field.name] = input;
                }
            });

            // Position modal near the node/edge
            if (position) {
                modal.style.left = position.x + 'px';
                modal.style.top = position.y + 'px';
            } else {
                // Center on screen
                modal.style.left = '50%';
                modal.style.top = '50%';
                modal.style.transform = 'translate(-50%, -50%)';
            }

            modal.classList.remove('hidden');

            // Handle OK button
            const okBtn = document.getElementById('modal-ok');
            const cancelBtn = document.getElementById('modal-cancel');

            const handleOk = () => {
                const result = {};
                fields.forEach(field => {
                    const input = formData[field.name];
                    result[field.name] = field.type === 'checkbox' ? input.checked : input.value;
                });
                this.hideModal();
                this.modalResolve(result);
            };

            const handleCancel = () => {
                this.hideModal();
                this.modalResolve(null);
            };

            okBtn.onclick = handleOk;
            cancelBtn.onclick = handleCancel;

            // Handle Enter key
            const handleKeyPress = (e) => {
                if (e.key === 'Enter') {
                    handleOk();
                } else if (e.key === 'Escape') {
                    handleCancel();
                }
            };

            modalBody.querySelectorAll('input[type="text"]').forEach(input => {
                input.addEventListener('keypress', handleKeyPress);
            });
        });
    }

    async showConfirm(title, message, position) {
        return new Promise((resolve) => {
            this.modalResolve = resolve;

            const modal = document.getElementById('custom-modal');
            const modalTitle = document.getElementById('modal-title');
            const modalBody = document.getElementById('modal-body');

            modalTitle.textContent = title;
            modalBody.innerHTML = `<p style="color: var(--text-primary);">${message}</p>`;

            // Position modal
            if (position) {
                modal.style.left = position.x + 'px';
                modal.style.top = position.y + 'px';
            } else {
                modal.style.left = '50%';
                modal.style.top = '50%';
                modal.style.transform = 'translate(-50%, -50%)';
            }

            modal.classList.remove('hidden');

            const okBtn = document.getElementById('modal-ok');
            const cancelBtn = document.getElementById('modal-cancel');

            okBtn.onclick = () => {
                this.hideModal();
                this.modalResolve(true);
            };

            cancelBtn.onclick = () => {
                this.hideModal();
                this.modalResolve(false);
            };
        });
    }

    hideModal() {
        const modal = document.getElementById('custom-modal');
        modal.classList.add('hidden');
        modal.style.transform = '';
    }
}
