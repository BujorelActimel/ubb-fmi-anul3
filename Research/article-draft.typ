#set document(
  title: "Unified Interactive Platform for Teaching Formal Languages and Automata Theory",
  author: "Bujor Mihai Alexandru",
)

#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  numbering: "1",
)

#set text(
  font: "Libertinus Serif",
  size: 11pt,
)

#set par(justify: true)

#align(center)[
  #text(17pt, weight: "bold")[
    A Unified Interactive Platform for Teaching \
    Formal Languages and Automata Theory

  ]

  #v(1em)

  Bujor Mihai Alexandru \
  #link("mailto:bujormihaialexandru@gmail.com") \
  Babeș-Bolyai University

  #v(1em)
]

= Paper Outline

== Abstract
Students struggle with formal languages theory due to abstract concepts and weak understanding of relationships between formalisms. We present a unified web-based platform supporting the entire Chomsky hierarchy with interactive construction, step-by-step simulation, and conversion algorithm visualization. A controlled experiment using exam performance evaluates whether comprehensive, visual, and interactive tooling improves learning outcomes compared to existing fragmented approaches.

== 1. Introduction
- *Problem:* Students memorize definitions but fail to understand connections (regex ↔ DFA ↔ grammar equivalence)
- *Current tools:* JFLAP comprehensive but dated UI and desktop-only; modern web tools limited in scope
- *Solution:* Unified platform combining: comprehensive coverage (DFA → Turing machines), interactive construction, animated execution, conversion visualization
- *Research question:* Does such a platform improve exam performance and conceptual understanding?
- *Contributions:* Empirical evaluation, design principles, open educational resource

== 2. Background and Related Work

=== 2.1 Pedagogical Challenges
Abstract formalism and weak relational understanding are major barriers @rodger2006increasing @du2010formal. Students struggle with execution tracing @lister2004relationship and connections between models @novak2006theory.

=== 2.2 Educational Technology
Active engagement crucial for visualization effectiveness @naps2002exploring @hundhausen2002meta @karavirta2006state. Interactive construction @papert1980mindstorms, worked examples @sweller1992worked, and immediate feedback @narciss2008feedback support learning. Multiple representations aid understanding @ainsworth2006deft but generic approaches have mixed results @sorva2013visual.

=== 2.3 Existing Tools
*JFLAP* @rodger2006jflap: Most comprehensive (DFA, NFA, PDA, TM, grammars, conversions) but Java desktop app with complex interface. *Web simulators* @borajek2015automaton: Simple, accessible but limited scope (typically DFA only). *Gap:* No modern tool combining comprehensiveness, usability, and pedagogical design.

=== 2.4 Cognitive Factors
Cognitive load theory @sweller1988cognitive suggests well-designed interfaces reduce extraneous load. Analogical reasoning @kumar2015analogical and cognitive technologies @pea1987cognitive enhance learning.

== 3. Research Questions

*RQ1:* Does the platform improve exam performance on automata theory topics?

*RQ2:* Does it improve understanding of relationships between formalisms (e.g., regex ↔ DFA equivalence)?

*RQ3:* Which features contribute most to learning: conversion visualization, interactive editor, or execution animation?

*RQ4:* What is the usability and perceived value of the platform?

== 4. Platform Design

=== 4.1 Coverage
*Type 3:* DFA, NFA, ε-NFA, regex, regular grammars \
*Type 2:* PDA, CFG, parsers \
*Type 1/0:* LBA, Turing machines \
*Conversions:* Regex ↔ NFA ↔ DFA ↔ Grammar, CFG ↔ PDA (step-by-step)

=== 4.2 Key Features
- *Interactive editor:* Drag-and-drop construction for all models
- *Animated simulation:* Synchronized state/input/stack/tape visualization
- *Conversion visualization:* Algorithm steps with correspondence highlighting
- *Type detection:* Automatic classification and validation
- *Example library:* Progressive complexity with real-world patterns
- *Immediate feedback:* Error explanations and hints

=== 4.3 Design Goals
Comprehensive (entire Chomsky hierarchy), accessible (web-based), visual (rich animations), interactive (construction-first), pedagogical (explicit relationships).

== 5. Evaluation

=== 5.1 Study Design
*Type:* Controlled experiment with exam as primary outcome

*Participants:* Students in formal languages course (hopefully N=80-100)

*Groups:* Random assignment to control (existing tools) vs treatment (unified platform)

*Duration:* 3-5 weeks before exam period

=== 5.2 Procedure

*Pre-Intervention:*
- Background survey (programming experience, prior knowledge)
- Random assignment stratified by experience

*Intervention (3-5 weeks):*
- Both groups: identical lecture content
- Control: existing tools (JFLAP, online regex testers, paper exercises)
- Treatment: unified platform exclusively
- Weekly: cognitive load surveys @hart1988development, usage analytics

*Assessment:*
- *Primary outcome:* Course exam performance (questions on execution, design, conversions, theory)
- *Secondary outcomes:*
  - Relational understanding tasks: "Explain regex ↔ DFA equivalence"
  - Conversion task: NFA → minimal DFA (timed)
  - Usability: SUS @brooke1996sus (treatment group)
  - Interviews: N=15 per group on learning experience

=== 5.3 Metrics
- Exam scores (overall and by question type: execution/design/conversions/theory)
- Relational understanding rubric (0-4 scale: none → deep explanation)
- Conversion accuracy and time
- Cognitive load (NASA-TLX)
- SUS score and feature usage patterns

=== 5.4 Analysis
- Primary: t-test comparing exam scores (control vs treatment)
- ANCOVA controlling for prior experience
- Subgroup analysis by question type
- Regression: feature usage → performance (treatment group)
- Qualitative: thematic analysis of interviews

== 6. Expected Results
- 15-25% higher exam scores (treatment group)
- Particularly strong on conversion and relational understanding questions
- High usability (SUS > 75)
- Qualitative: students report better grasp of connections
- Feature analysis: conversion visualization most correlated with performance

== 7. Discussion
Well-designed comprehensive tools can improve learning by making abstract concepts concrete and relationships explicit. Success factors: visual execution, interactive construction, conversion algorithm transparency, unified interface.

*Limitations:* Single institution, short duration, confounding factors (motivation, time-on-task).

*Implications:* Informs tool design for other abstract CS topics (compilers, verification).

== 8. Contributions

*C1:* Comprehensive platform (DFA → TM) with modern web-based design

*C2:* Empirical evidence using real exam performance (ecological validity)

*C3:* Design principles: comprehensiveness + usability + visualization + interactivity

*C4:* Open educational resource

#pagebreak()

= Bibliography

#bibliography("references-automata.bib", style: "ieee")

#pagebreak()

= Research Methodology

== Hypothesis
A comprehensive, interactive, visual platform improves exam performance on formal languages topics by 15-25% compared to existing tools, with strongest effects on relational understanding and conversion questions.

== Study Protocol

=== Preparation
- Complete platform implementation
- Prepare example library and tutorials
- Get ethics approval and course instructor agreement
- Design exam questions covering: execution tracing, automaton design, conversions, theory/proofs

=== Baseline (Week 0)
- Recruit participants from course (N=80-100)
- Background survey: prior CS courses, programming experience, learning preferences
- Informed consent
- Stratified random assignment (matched on experience)

=== Intervention (Weeks 1-5)

*Both Groups:*
- Attend same lectures (instructor teaches both, no differential treatment)
- Same homework problem sets
- Same conceptual material

*Control Group:*
- Use existing tools: JFLAP for construction/simulation, online regex testers, paper exercises
- Access to all standard resources

*Treatment Group:*
- Unified platform for all homework and practice
- Tutorial session (Week 1, 30 min)
- Encouraged to explore examples and conversion visualizations

*Data Collection:*
- Weekly cognitive load survey (after homework, 5 min)
- Usage logs: time spent, features used, errors encountered (treatment only)
- Weekly quiz scores (both groups, track progress)

=== Exam Assessment (Week 6)

*Exam Structure (designed with instructor):*
- Part A: Execution (trace DFA/NFA/PDA on inputs)
- Part B: Design (construct automaton for specified language)
- Part C: Conversions (NFA → DFA, regex ↔ automaton)
- Part D: Theory (proofs, closure properties, decidability)

*Supplemental Assessment (after exam):*
- Relational understanding: "Explain why every regex has equivalent DFA. Describe conversion process."
- Timed conversion: Standardized NFA → minimal DFA (20 min)
- SUS questionnaire (treatment)
- Interviews: 15 per group (stratified by exam performance: 5 high, 5 mid, 5 low)

=== Analysis

*Primary Analysis:*
- t-test: exam total scores (control vs treatment)
- Effect size: Cohen's d
- Check assumptions: normality (Shapiro-Wilk), equal variance (Levene)

*Secondary Analysis:*
- ANCOVA: exam score ~ group + prior_experience
- By question type: which parts show largest differences?
- Relational rubric scores: Mann-Whitney U test
- Conversion task: accuracy (chi-square), time (t-test)
- Cognitive load: NASA-TLX trajectory over weeks

*Feature Analysis (treatment only):*
- Regression: exam score ~ conversion_viz_time + editor_time + simulation_replays + ...
- Identify high-value features

*Qualitative:*
- Interview transcription and thematic coding
- Compare themes between high/low performers
- Triangulate with quantitative findings

=== Validity Considerations

*Internal:* Random assignment, blinded grading (exams coded before scoring), same instructor/content

*External:* Single institution limits generalizability; replication recommended

*Construct:* Exam designed to test multiple competencies (not just memorization)

*Ecological:* Using real course exam (not artificial lab test) increases relevance

== Original Approach

*Exam-based evaluation:* Most educational tools evaluated via separate tests. We use actual course exam for ecological validity and higher stakes.

*Multi-factor platform:* Not just addressing "fragmentation" but combining comprehensiveness, usability, visualization, interactivity in unified design.

*Conversion emphasis:* Explicit focus on algorithm visualization for learning relationships, not just simulation.

*Short realistic study:* 3-5 weeks feasible within semester constraints, not idealized full-semester intervention.

== Assessment Details

*Relational Understanding Rubric:*
- *Level 0:* No answer or incorrect
- *Level 1:* Vague ("they're related")
- *Level 2:* Correct claim without justification ("DFA and regex are equivalent")
- *Level 3:* Procedural knowledge ("Thompson's construction converts regex to NFA")
- *Level 4:* Deep explanation with correctness proof and examples

*Conversion Task:*
- Standardized 5-state NFA (multiple transitions per state)
- Must produce minimal DFA
- Scored: correct structure (3 pts), correct transitions (3 pts), minimal (2 pts), clear notation (2 pts)

*Interview Questions (selection):*
- How did you approach learning automata theory?
- Describe a moment when concepts "clicked" for you
- How did you understand relationships between DFA/NFA/regex?
- (Treatment): Which platform features were most/least helpful?
- What would improve the learning experience?

#pagebreak()

= Original Contribution

== Contributions

*C1: Comprehensive Educational Platform* \
Modern web-based tool spanning Chomsky hierarchy with focus on usability, visualization, and interactive learning (not just feature completeness).

*C2: Exam-Based Evaluation* \
Using real course assessment for ecological validity. Most tool studies use artificial lab tests.

*C3: Multi-Factor Design Principles* \
Platform combines: comprehensive coverage + modern UX + rich visualization + interactive construction + explicit relationships. Design principles for CS education tools.

*C4: Open Resource* \
Freely available tool with examples and tutorials for adoption by other institutions.

== Research Questions

*RQ1: Exam Performance?* \
Hypothesis: 15-25% improvement in treatment group. Measured by course exam (instructor-designed, covers full curriculum). Strongest effects expected on conversion and relational understanding questions.

*RQ2: Relational Understanding?* \
Measured by rubric-scored explanations. Expected: treatment group better articulates equivalences and conversion processes. Mechanism: explicit visualization of relationships + conversion algorithms.

*RQ3: Feature Value?* \
Regression analysis of usage logs on performance. Predicted ranking: (1) conversion visualization, (2) interactive editor, (3) execution animation. Identifies high-impact features for design prioritization.

*RQ4: Usability?* \
SUS > 75 indicates good usability. Qualitative feedback on learning experience. Assess adoption barriers and improvement opportunities.

== Differentiation

*vs. JFLAP Research:* \
Prior work measured satisfaction and adoption rates. We measure learning outcomes via exam performance. Modern web-based design vs desktop Java.

*vs. Educational Tool Studies:* \
Most use separate pre/post tests. We use actual course exam (ecological validity). Short realistic intervention (3-5 weeks) vs idealized semester-long.

*vs. Algorithm Visualization:* \
Domain-specific for formal languages with emphasis on conversions and relationships. Not generic algorithm viz.

== Impact

*Educational:* Direct benefit to students, free tool for instructors, evidence-based design guidance

*Research:* Methodology for tool evaluation, design principles, publications (SIGCSE, ITiCSE, ACM TOCE)

*Practical:* Reduces barriers to learning formal languages, potential for wide adoption (web-based, open-source)
