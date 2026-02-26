// ============================================================================
// CAPITOLUL 4: GRAMATICI REGULARE
// ============================================================================

#import "../lib/template.typ": *

= Gramatici Regulare

== Definiție și Tipuri

#definitie(title: "Gramatică Regulară")[
  O gramatică $G = (V_N, V_T, P, S)$ este *regulară* dacă toate producțiile au una din formele:

  *Liniară la dreapta:*
  - $A -> a B$ (terminal urmat de neterminal)
  - $A -> a$ (doar terminal)
  - $A -> epsilon$ (cuvântul vid)

  *Liniară la stânga:*
  - $A -> B a$ (neterminal urmat de terminal)
  - $A -> a$ (doar terminal)
  - $A -> epsilon$ (cuvântul vid)

  unde $A, B in V_N$ și $a in V_T$.
]

#atentie[
  O gramatică regulară trebuie să fie *fie* liniară la dreapta, *fie* liniară la stânga - nu amândouă în același timp!

  *Greșit:* $S -> a B$, $B -> C b$ (amestec de liniaritate)
]

#teorema(title: "Echivalența gramaticilor regulare și AF")[
  Un limbaj este generat de o gramatică regulară dacă și numai dacă este acceptat de un automat finit.

  Clasa limbajelor generate de gramatici regulare = Clasa limbajelor acceptate de automate finite
]

== Conversia Gramatică Regulară → AF

#algoritm(title: "GR → NFA")[
  *Input:* Gramatică regulară liniară la dreapta $G = (V_N, V_T, P, S)$

  *Output:* NFA $M = (Q, Sigma, delta, q_0, F)$

  *Construcție:*
  - $Q = V_N union {q_f}$ (o stare pentru fiecare neterminal + stare finală)
  - $Sigma = V_T$
  - $q_0 = S$
  - $F = {q_f}$ sau $F = {q_f} union {S}$ dacă $S -> epsilon in P$

  *Tranziții:*
  - Pentru $A -> a B$: adăugăm $B in delta(A, a)$
  - Pentru $A -> a$: adăugăm $q_f in delta(A, a)$
  - Pentru $A -> epsilon$: $A$ devine stare finală
]

#exemplu(title: "Conversie GR → NFA")[
  Gramatica:
  - $S -> a A | b S$
  - $A -> a A | b$

  Automatul NFA:
  - Stări: ${S, A, q_f}$
  - Stare inițială: $S$
  - Stări finale: ${q_f}$

  Tranziții:
  - $delta(S, a) = {A}$ (din $S -> a A$)
  - $delta(S, b) = {S}$ (din $S -> b S$)
  - $delta(A, a) = {A}$ (din $A -> a A$)
  - $delta(A, b) = {q_f}$ (din $A -> b$)
]

== Conversia AF → Gramatică Regulară

#algoritm(title: "AF → GR (liniară la dreapta)")[
  *Input:* DFA $M = (Q, Sigma, delta, q_0, F)$

  *Output:* Gramatică regulară $G = (V_N, V_T, P, S)$

  *Construcție:*
  - $V_N = Q$ (fiecare stare devine neterminal)
  - $V_T = Sigma$
  - $S = q_0$

  *Producții:*
  - Pentru fiecare $delta(q, a) = p$: adăugăm $q -> a p$
  - Pentru fiecare $q in F$: adăugăm $q -> epsilon$
]

== Eliminarea $epsilon$-producțiilor

#algoritm(title: "Eliminarea producțiilor $epsilon$")[
  *Pasul 1:* Găsim mulțimea $N_epsilon$ a neterminalelor care pot genera $epsilon$:
  - Dacă $A -> epsilon in P$, atunci $A in N_epsilon$
  - Dacă $A -> B_1 B_2 ... B_k$ cu toți $B_i in N_epsilon$, atunci $A in N_epsilon$
  - Repetăm până nu se mai adaugă nimic

  *Pasul 2:* Construim noi producții:
  - Pentru fiecare producție $A -> alpha$
  - Adăugăm toate variantele în care neterminalele din $N_epsilon$ sunt sau nu prezente

  *Pasul 3:* Eliminăm producțiile $epsilon$ (cu excepția $S -> epsilon$ dacă $epsilon in L(G)$)
]

#exemplu(title: "Eliminarea $epsilon$-producțiilor")[
  Gramatica:
  - $S -> a B A$
  - $A -> a A | epsilon$
  - $B -> b B | epsilon$

  *Pasul 1:* $N_epsilon = {A, B}$

  *Pasul 2:* Noi producții:
  - Din $S -> a B A$: $S -> a B A | a B | a A | a$
  - Din $A -> a A$: $A -> a A | a$
  - Din $B -> b B$: $B -> b B | b$

  *Rezultat:*
  - $S -> a B A | a B | a A | a$
  - $A -> a A | a$
  - $B -> b B | b$
]

== Lema de Pompare pentru Limbaje Regulare

#teorema(title: "Lema de Pompare (Pumping Lemma)")[
  Fie $L$ un limbaj regular. Atunci există o constantă $n >= 1$ astfel încât pentru orice cuvânt $w in L$ cu $|w| >= n$, există o descompunere $w = x y z$ cu:

  1. $|x y| <= n$
  2. $|y| >= 1$ (adică $y != epsilon$)
  3. Pentru orice $i >= 0$: $x y^i z in L$

  Altfel spus, partea $y$ poate fi "pompată" (repetată) de oricâte ori și cuvântul rămâne în limbaj.
]

#atentie[
  *Lema de pompare se folosește pentru a demonstra că un limbaj NU este regular!*

  Schema demonstrației prin contradicție:
  1. Presupunem că $L$ este regular
  2. Fie $n$ constanta din lema de pompare
  3. Alegem un cuvânt $w in L$ cu $|w| >= n$
  4. Arătăm că pentru *orice* descompunere $w = x y z$ cu $|x y| <= n$, $y != epsilon$
  5. Există un $i$ astfel încât $x y^i z in.not L$ → contradicție!
  6. Deci $L$ nu este regular
]

#exemplu(title: "Demonstrație: $L = {a^n b^n | n >= 0}$ nu este regular")[
  *Demonstrație prin contradicție:*

  1. Presupunem că $L$ este regular. Fie $n$ constanta din lema de pompare.

  2. Alegem $w = a^n b^n in L$ (are lungimea $2n >= n$).

  3. Fie $w = x y z$ o descompunere oarecare cu $|x y| <= n$ și $|y| >= 1$.

  4. Deoarece $|x y| <= n$, iar primele $n$ caractere din $w$ sunt toate $a$, rezultă că $y = a^k$ pentru un $k >= 1$.

  5. Considerăm $i = 0$: $x y^0 z = x z = a^(n-k) b^n$.

  6. Dar $n - k != n$ (deoarece $k >= 1$), deci $a^(n-k) b^n in.not L$.

  7. Contradicție! Deci $L$ nu este regular. $square$
]

#exemplu(title: "Demonstrație: $L = {a^(n^2) | n >= 0}$ nu este regular")[
  *Demonstrație prin contradicție:*

  1. Presupunem că $L$ este regular. Fie $p$ constanta din lema de pompare.

  2. Alegem $w = a^(p^2) in L$.

  3. Fie $w = x y z$ cu $|x y| <= p$ și $|y| = k >= 1$.

  4. Atunci $|x y^2 z| = p^2 + k$.

  5. Avem $p^2 < p^2 + k <= p^2 + p < p^2 + 2p + 1 = (p+1)^2$.

  6. Deci $p^2 + k$ este strict între două pătrate perfecte consecutive, deci nu e pătrat perfect.

  7. Astfel $x y^2 z = a^(p^2 + k) in.not L$. Contradicție! $square$
]

#truc[
  *Strategii pentru alegerea cuvântului $w$:*

  - Pentru $L = {a^n b^n}$: alege $w = a^n b^n$
  - Pentru $L = {w w | w in Sigma^*}$: alege $w = a^n b a^n b$
  - Pentru $L = {a^p | p "prim"}$: alege $w = a^p$ pentru $p$ prim $>= n$
  - Pentru $L = {a^(n^2)}$: alege $w = a^(n^2)$

  Ideea: alege un cuvânt care "se strică" când pompezi partea $y$.
]

== Exerciții Rezolvate

=== Exerciții cu Lema de Pompare - Descompuneri (Tip Examen)

#exercitiu(0)[
  Fie $L$ limbajul regular corespunzător expresiei regulate $a a^* b^*$. Fie $w = a b b$.

  Puteți identifica două descompuneri $w = x y z$, cu $y != epsilon$, astfel încât $x y^i z in L$ pentru orice $i >= 0$? Justificați!
]

#rezolvare[
  *Limbajul:* $L = {a^n b^m | n >= 1, m >= 0}$ (cel puțin un $a$, zero sau mai multe $b$).

  *Cuvântul:* $w = a b b$ aparține lui $L$ ($n = 1$, $m = 2$).

  *Căutăm descompuneri $w = x y z$ cu $y != epsilon$ și $x y^i z in L$ pentru orice $i >= 0$:*

  *Descompunerea 1:* $x = epsilon$, $y = a$, $z = b b$
  - $x y^0 z = b b in.not L$ (nu are niciun $a$!)
  - *NU funcționează!*

  *Descompunerea 2:* $x = a$, $y = b$, $z = b$
  - $x y^i z = a b^i b = a b^(i+1)$
  - Pentru orice $i >= 0$: $a b^(i+1) in L$ ✓ (un $a$, $i+1$ de $b$)
  - *Funcționează!*

  *Descompunerea 3:* $x = a b$, $y = b$, $z = epsilon$
  - $x y^i z = a b b^i = a b^(i+1)$
  - Pentru orice $i >= 0$: $a b^(i+1) in L$ ✓
  - *Funcționează!*

  *Răspuns:* $(x = a, y = b, z = b)$ și $(x = a b, y = b, z = epsilon)$ sunt două descompuneri valide.
]

#atentie[
  *Strategii pentru descompuneri pompabile:*

  1. *Nu pompați partea obligatorie* - dacă limbajul cere cel puțin un $a$, nu alegeți $y = a$ cu $x = epsilon$
  2. *Pompați partea repetabilă* - dacă limbajul permite $b^*$, pomparea lui $b$ funcționează
  3. *Verificați cazul $i = 0$* - acesta este cel mai restrictiv!
]

#exercitiu(1)[
  Construiți o gramatică regulară pentru limbajul $L = {a^n b^m | n >= 1, m >= 0}$.
]

#rezolvare[
  Limbajul: cel puțin un $a$, urmat de zero sau mai multe $b$.

  *Gramatica (liniară la dreapta):*
  - $S -> a A$ (trebuie cel puțin un $a$)
  - $A -> a A | B$ (mai multe $a$ sau trecem la $b$)
  - $B -> b B | epsilon$ (zero sau mai multe $b$)

  Sau mai simplu:
  - $S -> a A$
  - $A -> a A | b A | epsilon$
]

#exercitiu(2)[
  Demonstrați că limbajul $L = {a^n b^n c^n | n >= 0}$ nu este regular.
]

#rezolvare[
  *Demonstrație prin contradicție:*

  1. Presupunem că $L$ este regular. Fie $p$ constanta din lema de pompare.

  2. Alegem $w = a^p b^p c^p in L$ (cu $|w| = 3p >= p$).

  3. Fie $w = x y z$ cu $|x y| <= p$ și $|y| >= 1$.

  4. Deoarece $|x y| <= p$ și primele $p$ caractere sunt $a$, avem $y = a^k$ cu $k >= 1$.

  5. Pompăm cu $i = 2$: $x y^2 z = a^(p+k) b^p c^p$.

  6. Dar $p + k != p$, deci cuvântul nu mai are același număr de $a$, $b$ și $c$.

  7. Deci $x y^2 z in.not L$. Contradicție! $square$

  *Observație:* Acest limbaj nu este nici măcar independent de context!
]

#exercitiu(3)[
  Fie gramatica:
  - $S -> a b A$
  - $S -> epsilon$
  - $A -> S a a$
  - $A -> b$

  Determinați FIRST și FOLLOW pentru toate neterminalele.
]

#rezolvare[
  *Calculul FIRST:*

  $"FIRST"(S)$: Din $S -> a b A$, avem $a in "FIRST"(S)$. Din $S -> epsilon$, avem $epsilon in "FIRST"(S)$.

  $"FIRST"(S) = {a, epsilon}$

  $"FIRST"(A)$: Din $A -> S a a$, luăm $"FIRST"(S) - {epsilon} = {a}$. Dar $epsilon in "FIRST"(S)$, deci continuăm cu $a$, obținem $a$. Din $A -> b$, avem $b$.

  $"FIRST"(A) = {a, b}$

  *Calculul FOLLOW:*

  $"FOLLOW"(S)$: $S$ este simbolul de start, deci $dollar in "FOLLOW"(S)$.
  Din $A -> S a a$, după $S$ urmează $a$, deci $a in "FOLLOW"(S)$.

  $"FOLLOW"(S) = {dollar, a}$

  $"FOLLOW"(A)$: Din $S -> a b A$, $A$ este la final, deci $"FOLLOW"(S) subset.eq "FOLLOW"(A)$.

  $"FOLLOW"(A) = {dollar, a}$
]

#pagebreak()
