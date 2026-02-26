// ============================================================================
// CAPITOLUL 13: EXERCIȚII DE EXAMEN REZOLVATE
// ============================================================================

#import "../lib/template.typ": *

= Exerciții de Examen Rezolvate

Acest capitol conține bilete de examen rezolvate integral, organizate pe categorii de probleme.

== Bilet Model Complet

#block(stroke: 2pt + rgb("#1976d2"), inset: 12pt, radius: 8pt)[
  *BILET DE EXAMEN - MODEL*

  *(1p) oficiu*

  *1.* Dați definiția formală a unei gramatici. *(1p)*

  *2.* Fie $L$ - limbajul regular corespunzător expresiei regulare $a a^* b^*$. Fie $w = a b b$. Puteți identifica două descompuneri $w = x y z$, cu $y != epsilon$, astfel încât $x y^i z in L$ pentru orice $i >= 0$? (Justificați!) *(1.5p)*

  *3.* Dați un exemplu de AF cu 2 stări care acceptă limbajul corespunzător expresiei regulare $a^*$. *(1p)*

  *4.* Data fiind următoarea gramatică:
  - $S -> a b c$
  - $S -> a S B c$
  - $c B -> B c$
  - $b B -> b b$

  Specificați valoarea de adevăr a afirmațiilor. Justificați!
  - a) gramatica este independentă de context
  - b) gramatica este dependentă de context
  - c) gramatica este monotonă *(1.5p)*

  *5.* Fie gramatica cu regulile de producție:
  - $S -> a S | b S | c$

  Construiți tabelul de analiză LR(1). Gramatica dată este LR(1)? *(2p)*

  *6.* Fie următoarea instrucțiune Pascal:
  ```
  if a > b then max := a else max := b
  ```
  a) Dați o gramatică independentă de context care descrie sintaxa instrucțiunilor.
  b) Traduceți în cod intermediar cu 3 adrese, reprezentare cvadruple. *(2p)*

  *Timp de lucru: 120 minute*
]

#pagebreak()

== Rezolvare Bilet Model

=== Problema 1: Definiția formală a unei gramatici (1p)

#rezolvare[
  O *gramatică* este un cvadruplu $G = (V_N, V_T, P, S)$ unde:

  - $V_N$ este o mulțime finită, nevidă de simboluri numite *neterminale*
  - $V_T$ este o mulțime finită de simboluri numite *terminale*, cu $V_N inter V_T = emptyset$
  - $P$ este o mulțime finită de *producții* (reguli de rescriere) de forma $alpha -> beta$ unde $alpha, beta in (V_N union V_T)^*$ și $alpha$ conține cel puțin un neterminal
  - $S in V_N$ este *simbolul de start* (axioma)
]

=== Problema 2: Lema de pompare (1.5p)

#rezolvare[
  Expresia regulară $a a^* b^*$ generează limbajul $L = {a^n b^m | n >= 1, m >= 0}$.

  Cuvântul $w = a b b$ are lungimea 3 și aparține lui $L$ (un $a$ și doi $b$).

  *Descompunerea 1:* $x = epsilon$, $y = a$, $z = b b$
  - Verificare: $x y^i z = a^i b b$
  - Pentru $i = 0$: $b b in.not L$ (nu are niciun $a$)
  - *Nu funcționează!*

  *Descompunerea 2:* $x = a$, $y = b$, $z = b$
  - Verificare: $x y^i z = a b^i b = a b^(i+1)$
  - Pentru orice $i >= 0$: $a b^(i+1) in L$ (un $a$, $i+1$ de $b$)
  - *Funcționează!* $checkmark$

  *Descompunerea 3:* $x = a b$, $y = b$, $z = epsilon$
  - Verificare: $x y^i z = a b b^i = a b^(i+1)$
  - Pentru orice $i >= 0$: $a b^(i+1) in L$
  - *Funcționează!* $checkmark$

  *Concluzie:* Descompunerile $(x = a, y = b, z = b)$ și $(x = a b, y = b, z = epsilon)$ satisfac cerințele.
]

=== Problema 3: AF cu 2 stări pentru $a^*$ (1p)

#rezolvare[
  $M = ({q_0, q_1}, {a, b}, delta, q_0, {q_0})$

  Tranziții:
  - $delta(q_0, a) = q_0$ (citim $a$, rămânem în starea de acceptare)
  - $delta(q_0, b) = q_1$ (citim $b$, mergem în starea de eroare)
  - $delta(q_1, a) = q_1$ (starea de eroare este absorbantă)
  - $delta(q_1, b) = q_1$

  *Diagramă:*
  - $q_0$ (stare inițială și finală, cerc dublu): buclă pe $a$, arc către $q_1$ pe $b$
  - $q_1$ (stare de eroare): bucle pe $a$ și $b$

  Automatul acceptă cuvintele formate doar din $a$ (inclusiv $epsilon$).
]

=== Problema 4: Tipul gramaticii (1.5p)

#rezolvare[
  Analizăm producțiile:
  - $S -> a b c$ : parte stângă = neterminal singur $checkmark$
  - $S -> a S B c$ : parte stângă = neterminal singur $checkmark$
  - $c B -> B c$ : parte stângă = $c B$ (terminal + neterminal) $times$
  - $b B -> b b$ : parte stângă = $b B$ (terminal + neterminal) $times$

  *a) Gramatica este independentă de context?*

  *FALS.* O gramatică este independentă de context dacă toate producțiile au forma $A -> alpha$ (un singur neterminal în stânga). Producțiile $c B -> B c$ și $b B -> b b$ au mai mult de un simbol în partea stângă.

  *b) Gramatica este dependentă de context?*

  *FALS.* O gramatică este dependentă de context dacă producțiile au forma $alpha A beta -> alpha gamma beta$ cu $|gamma| >= 1$ (contextul $alpha$ și $beta$ trebuie păstrat pe ambele părți).

  Producția $c B -> B c$ NU se potrivește acestei forme:
  - Dacă $alpha = c$, $A = B$, $beta = epsilon$, atunci ar trebui $alpha gamma beta = c gamma = B c$
  - Dar $B c$ nu începe cu $c$ (contextul nu e păstrat în dreapta)
  - Această producție este o permutare, nu o producție dependentă de context

  *Concluzie:* Gramatica este de *tip 0* (fără restricții), NU dependentă de context.

  *Notă:* Gramatica este totuși *monotonă* ($|alpha| <= |beta|$ pentru toate producțiile), dar monoton $!=$ dependent de context

  *c) Gramatica este monotonă?*

  *ADEVĂRAT.* O gramatică este monotonă dacă pentru orice producție $alpha -> beta$, avem $|alpha| <= |beta|$ (partea dreaptă nu e mai scurtă). Toate producțiile satisfac această condiție.
]

=== Problema 5: Tabelul LR(1) (2p)

#rezolvare[
  Gramatica:
  - (0) $S' -> S$
  - (1) $S -> a S$
  - (2) $S -> b S$
  - (3) $S -> c$

  *Colecția canonică LR(1):*

  $I_0 = "CLOSURE"({[S' -> . S, dollar]})$:
  - $[S' -> . S, dollar]$
  - $[S -> . a S, dollar]$
  - $[S -> . b S, dollar]$
  - $[S -> . c, dollar]$

  $I_1 = "GOTO"(I_0, S)$: $[S' -> S ., dollar]$

  $I_2 = "GOTO"(I_0, a)$:
  - $[S -> a . S, dollar]$
  - $[S -> . a S, dollar]$
  - $[S -> . b S, dollar]$
  - $[S -> . c, dollar]$

  $I_3 = "GOTO"(I_0, b)$:
  - $[S -> b . S, dollar]$
  - $[S -> . a S, dollar]$
  - $[S -> . b S, dollar]$
  - $[S -> . c, dollar]$

  $I_4 = "GOTO"(I_0, c)$: $[S -> c ., dollar]$

  $I_5 = "GOTO"(I_2, S)$: $[S -> a S ., dollar]$

  $I_6 = "GOTO"(I_3, S)$: $[S -> b S ., dollar]$

  (GOTO(I_2, a) = I_2, GOTO(I_2, b) = I_3, GOTO(I_2, c) = I_4)
  (GOTO(I_3, a) = I_2, GOTO(I_3, b) = I_3, GOTO(I_3, c) = I_4)

  *Tabelul LR(1):*

  #table(
    columns: (auto, auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 or x == 0 { rgb("#e3f2fd") } else { white },
    [], [*a*], [*b*], [*c*], [*\$*], [*S*],
    [$I_0$], [s2], [s3], [s4], [], [1],
    [$I_1$], [], [], [], [acc], [],
    [$I_2$], [s2], [s3], [s4], [], [5],
    [$I_3$], [s2], [s3], [s4], [], [6],
    [$I_4$], [], [], [], [r3], [],
    [$I_5$], [], [], [], [r1], [],
    [$I_6$], [], [], [], [r2], [],
  )

  *Gramatica este LR(1)?* *DA*, nu există conflicte în tabel.
]

=== Problema 6: Cod intermediar (2p)

#rezolvare[
  *a) Gramatica pentru if-then-else:*

  - $"Stmt" -> "if" "Cond" "then" "Stmt" "else" "Stmt"$
  - $"Stmt" -> "id" := "Expr"$
  - $"Cond" -> "Expr" "relop" "Expr"$
  - $"Expr" -> "id"$
  - $"relop" -> > | < | = | ...$

  *b) Cod intermediar cu cvadruple:*

  Instrucțiunea: `if a > b then max := a else max := b`

  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Nr*], [*op*], [*arg1*], [*arg2*], [*result*],
    [0], [>], [a], [b], [t1],
    [1], [jmpt], [t1], [-], [3],
    [2], [jmp], [-], [-], [5],
    [3], [:=], [a], [-], [max],
    [4], [jmp], [-], [-], [6],
    [5], [:=], [b], [-], [max],
    [6], [], [], [], [],
  )

  *Explicație:*
  - (0): evaluăm condiția $a > b$, rezultatul în t1
  - (1): dacă t1 este true, salt la (3) - ramura then
  - (2): altfel, salt la (5) - ramura else
  - (3): max := a
  - (4): salt la sfârșitul if-ului
  - (5): max := b
  - (6): continuarea programului
]

#pagebreak()

== Alte Exerciții Tip Examen

=== Exercițiu: FIRST și FOLLOW

#exercitiu(1)[
  Fie gramatica:
  - $S -> a b A$
  - $S -> epsilon$
  - $A -> S a a$
  - $A -> b$

  Calculați FIRST și FOLLOW pentru toate neterminalele.
]

#rezolvare[
  *FIRST:*

  $"FIRST"(S)$:
  - Din $S -> a b A$: $a in "FIRST"(S)$
  - Din $S -> epsilon$: $epsilon in "FIRST"(S)$
  - $"FIRST"(S) = {a, epsilon}$

  $"FIRST"(A)$:
  - Din $A -> S a a$: $"FIRST"(S) - {epsilon} = {a} subset "FIRST"(A)$
  - Deoarece $epsilon in "FIRST"(S)$, continuăm cu $a$: $a in "FIRST"(A)$
  - Din $A -> b$: $b in "FIRST"(A)$
  - $"FIRST"(A) = {a, b}$

  *FOLLOW:*

  $"FOLLOW"(S)$:
  - $S$ este simbol de start: $dollar in "FOLLOW"(S)$
  - Din $A -> S a a$: $a in "FOLLOW"(S)$
  - $"FOLLOW"(S) = {a, dollar}$

  $"FOLLOW"(A)$:
  - Din $S -> a b A$: $A$ e la final, deci $"FOLLOW"(S) subset "FOLLOW"(A)$
  - $"FOLLOW"(A) = {a, dollar}$
]

=== Exercițiu: Demonstrație ambiguitate

#exercitiu(2)[
  Demonstrați că gramatica:
  - $S -> a S b S$
  - $S -> a S$
  - $S -> c$

  este ambiguă.
]

#rezolvare[
  Găsim un cuvânt cu două derivări stânga diferite.

  Cuvântul $w = a a c b c$:

  *Derivarea 1:*
  $S =>_L a S b S =>_L a a S b S b S =>_L a a c b S b S =>_L a a c b c b S$... nu merge.

  Cuvântul $w = a c b a c$:

  *Derivarea 1:* (folosind $S -> a S b S$ apoi $S -> c$ și $S -> a S$)
  $S =>_L a S b S =>_L a c b S =>_L a c b a S =>_L a c b a c$

  *Derivarea 2:* (folosind $S -> a S$ apoi $S -> c b a c$... )
  Trebuie să găsim o altă derivare.

  Fie $w = a a c c$:
  - $S => a S => a a S => a a c$... generează $a a c$, nu $a a c c$.

  Fie $w = a c b c$:

  *Derivarea 1:*
  $S => a S b S => a c b S => a c b c$

  *Derivarea 2:*
  $S => a S => a S b S => a c b S => a c b c$

  Ambele derivări produc $a c b c$, dar sunt diferite!

  *Concluzie:* Gramatica este ambiguă deoarece $a c b c$ are două derivări stânga distincte.
]

=== Exercițiu: Verificare secvență cu LL(1)

#exercitiu(3)[
  Fie gramatica:
  - $E -> T E'$
  - $E' -> + T E' | epsilon$
  - $T -> "id"$

  Și tabelul LL(1):
  #table(
    columns: (auto, auto, auto, auto),
    stroke: 0.5pt,
    [], [*id*], [*+*], [*\$*],
    [*E*], [$E -> T E'$], [], [],
    [*E'*], [], [$E' -> + T E'$], [$E' -> epsilon$],
    [*T*], [$T -> "id"$], [], [],
  )

  Verificați dacă secvența $"id" + "id"$ aparține $L(G)$.
]

#rezolvare[
  #table(
    columns: (auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Stiva*], [*Intrare*], [*Acțiune*],
    [$dollar E$], [id + id \$], [$E -> T E'$],
    [$dollar E' T$], [id + id \$], [$T -> "id"$],
    [$dollar E' "id"$], [id + id \$], [match id],
    [$dollar E'$], [+ id \$], [$E' -> + T E'$],
    [$dollar E' T +$], [+ id \$], [match +],
    [$dollar E' T$], [id \$], [$T -> "id"$],
    [$dollar E' "id"$], [id \$], [match id],
    [$dollar E'$], [\$], [$E' -> epsilon$],
    [$dollar$], [\$], [*ACCEPT*],
  )

  *Rezultat:* $"id" + "id" in L(G)$ $checkmark$
]

=== Exercițiu: Factorizare la stânga

#exercitiu(4)[
  Pentru următoarea gramatică independentă de context aplicați factorizare la stânga:
  - $E -> T + E$
  - $E -> T$
  - $T -> F ast.op T$
  - $T -> F$
  - $F -> (E)$
  - $F -> a$

  Dați gramatica obținută!
]

#rezolvare[
  *Pas 1:* Identificăm producțiile cu prefix comun:
  - $E -> T + E | T$ - prefixul comun este $T$
  - $T -> F ast.op T | F$ - prefixul comun este $F$
  - $F -> (E) | a$ - nu au prefix comun

  *Pas 2:* Aplicăm factorizarea:

  Pentru $E -> T + E | T$:
  - Factor comun: $T$
  - Sufixe: $+ E$ și $epsilon$
  - Rezultat: $E -> T E'$ și $E' -> + E | epsilon$

  Pentru $T -> F ast.op T | F$:
  - Factor comun: $F$
  - Sufixe: $ast.op T$ și $epsilon$
  - Rezultat: $T -> F T'$ și $T' -> ast.op T | epsilon$

  *Gramatica finală (factorizată):*
  - $E -> T E'$
  - $E' -> + E | epsilon$
  - $T -> F T'$
  - $T' -> ast.op T | epsilon$
  - $F -> (E) | a$
]

=== Exercițiu: Lema de pompare pentru GIC

#exercitiu(4)[
  a) Enunțați Lema de pompare pentru limbaje independente de context.

  b) Fie gramatica:
  - $S -> 0 A 1$
  - $A -> 0 S$
  - $A -> a$

  și secvența $0 0 0 a 1 1$.

  Puteți să dați o descompunere a secvenței date care să poată fi "pompată" conform descrierii din lema de pompare?
]

#rezolvare[
  *a) Lema de pompare pentru LIC:*

  Fie $L$ un limbaj independent de context. Atunci există o constantă $n >= 1$ astfel încât pentru orice cuvânt $w in L$ cu $|w| >= n$, există o descompunere $w = u v x y z$ cu:

  1. $|v x y| <= n$
  2. $|v y| >= 1$ (adică $v != epsilon$ sau $y != epsilon$)
  3. Pentru orice $i >= 0$: $u v^i x y^i z in L$

  *b) Descompunere pentru $w = 0 0 0 a 1 1$:*

  Mai întâi verificăm că $0 0 0 a 1 1 in L(G)$:
  - $S => 0 A 1 => 0 0 S 1 => 0 0 0 A 1 1 => 0 0 0 a 1 1$ ✓

  Limbajul generat este $L = {0^n a 1^n | n >= 1}$.

  Descompunerea: $w = u v x y z$ cu $u = 0$, $v = 0$, $x = 0 a 1$, $y = 1$, $z = epsilon$

  Verificare:
  - $|v x y| = |0 dot 0 a 1 dot 1| = 5 <= n$ (dacă $n >= 5$)
  - $|v y| = |0 1| = 2 >= 1$ ✓
  - $u v^i x y^i z = 0 dot 0^i dot 0 a 1 dot 1^i = 0^(i+1) 0 a 1 1^i = 0^(i+2) a 1^(i+1)$

  Pentru $i = 0$: $0^2 a 1^1 = 0 0 a 1 in L$ ✓
  Pentru $i = 2$: $0^4 a 1^3 = 00 0 0 a 1 11 in L$ ✓

  *Altă descompunere validă:* $u = epsilon$, $v = 0$, $x = 0 0 a 1$, $y = 1$, $z = epsilon$
]

=== Exercițiu: Proprietăți expresii regulare

#exercitiu(5)[
  Fie $r$ o expresie regulară oarecare. Care este valoarea de adevăr a următoarelor afirmații?

  a) $(r^*)^* = r^*$
  b) $(r^+)^* = r^*$
  c) $r^* r^* = r^*$
  d) $r^* + epsilon = r^*$
]

#rezolvare[
  a) *ADEVĂRAT.* $(L^*)^* = L^*$ deoarece concatenarea de zero-sau-mai-multe repetări tot zero-sau-mai-multe repetări dă.

  b) *ADEVĂRAT.* $(L^+)^* = L^*$ deoarece $L^+ = L L^*$, și $(L L^*)^* = L^*$.

  c) *ADEVĂRAT.* $L^* dot L^* = L^*$ deoarece ambele părți reprezintă "zero sau mai multe din $L$".

  d) *ADEVĂRAT.* $L^* union {epsilon} = L^*$ deoarece $epsilon in L^*$ oricum (prin definiție, $L^0 = {epsilon} subset L^*$).
]

#pagebreak()
