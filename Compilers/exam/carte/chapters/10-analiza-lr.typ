// ============================================================================
// CAPITOLUL 10: ANALIZA SINTACTICĂ LR
// ============================================================================

#import "../lib/template.typ": *

= Analiza Sintactică LR

#atentie[
  *CAPITOL CRITIC PENTRU EXAMEN!*

  Întrebări frecvente:
  - "Definiți funcția GOTO pentru LR(0)" (1p)
  - "Structuri de date pentru element LR(0), stare LR(0), colecție" (1p)
  - "Construiți tabelul SLR" (2p)
  - "Analizați secvența cu analizor LR" (1-2p)
]

== Principiul Analizei LR

#definitie(title: "Analiza LR(k)")[
  *LR(k)* înseamnă:
  - *L* = Left-to-right (citim de la stânga la dreapta)
  - *R* = Rightmost derivation (derivare dreapta, în ordine inversă)
  - *k* = numărul de simboluri lookahead

  Analiza LR este *bottom-up*: construiește arborele de la frunze către rădăcină.
]

== Elemente LR(0)

#definitie(title: "Element LR(0)")[
  Un *element LR(0)* (sau *item*) este o producție cu un punct (•) în partea dreaptă:

  $[A -> alpha . beta]$

  - $alpha$ = partea deja recunoscută (pe stivă)
  - $beta$ = partea care urmează să fie recunoscută
  - Punctul indică *poziția curentă* în procesul de recunoaștere
]

#exemplu[
  Pentru producția $A -> X Y Z$, elementele LR(0) sunt:
  - $[A -> . X Y Z]$ - nu am recunoscut nimic
  - $[A -> X . Y Z]$ - am recunoscut $X$
  - $[A -> X Y . Z]$ - am recunoscut $X Y$
  - $[A -> X Y Z .]$ - am recunoscut tot (element *complet*)
]

#truc[
  *La examen: Structura de date pentru element LR(0)*

  Un element $[A -> alpha . beta]$ poate fi reprezentat ca:
  - O pereche (producție, poziție) unde poziția ∈ {0, 1, ..., |α β|}
  - Sau explicit: (neterminal, partea stângă, partea dreaptă)
]

== Funcția CLOSURE

#definitie(title: "CLOSURE(I)")[
  Pentru o mulțime de elemente $I$, *CLOSURE(I)* este cea mai mică mulțime care:

  1. $I subset.eq "CLOSURE"(I)$

  2. Dacă $[A -> alpha . B beta] in "CLOSURE"(I)$ și $B -> gamma$ este o producție, atunci $[B -> . gamma] in "CLOSURE"(I)$

  Intuitiv: dacă așteptăm să recunoaștem $B$, adăugăm toate modurile în care $B$ poate începe.
]

#algoritm(title: "Calculul CLOSURE")[
  ```
  CLOSURE(I) {
      J = I;
      repeat {
          for each [A -> α.Bβ] in J
              for each B -> γ in G
                  if [B -> .γ] not in J
                      add [B -> .γ] to J
      } until no more items can be added
      return J
  }
  ```
]

== Funcția GOTO

#definitie(title: "GOTO(I, X)")[
  Pentru o mulțime de elemente $I$ și un simbol $X$ (terminal sau neterminal):

  $"GOTO"(I, X) = "CLOSURE"({[A -> alpha X . beta] | [A -> alpha . X beta] in I})$

  Intuitiv: din starea $I$, după ce citim/recunoaștem $X$, ajungem în starea GOTO(I, X).
]

#truc[
  *La examen: Definiția funcției GOTO*

  "GOTO(I, X) este CLOSURE-ul mulțimii elementelor obținute din I prin avansarea punctului peste simbolul X, pentru toate elementele din I care au X imediat după punct."
]

== Colecția Canonică LR(0)

#algoritm(title: "Construcția colecției canonice LR(0)")[
  ```
  construieste_colectie() {
      C = {CLOSURE({[S' -> .S]})};  // I₀
      repeat {
          for each I in C
              for each X (terminal sau neterminal)
                  J = GOTO(I, X)
                  if J ≠ ∅ and J not in C
                      add J to C
      } until no more sets can be added
      return C
  }
  ```
]

#exemplu(title: "Colecția canonică LR(0)")[
  Gramatica augmentată:
  - $S' -> S$ ... (0)
  - $S -> A A$ ... (1)
  - $A -> a A$ ... (2)
  - $A -> b$ ... (3)

  *$I_0 = "CLOSURE"({[S' -> . S]})$:*
  - $[S' -> . S]$
  - $[S -> . A A]$ (din S -> A A)
  - $[A -> . a A]$ (din A -> a A)
  - $[A -> . b]$ (din A -> b)

  *$I_1 = "GOTO"(I_0, S)$:*
  - $[S' -> S .]$

  *$I_2 = "GOTO"(I_0, A)$:*
  - $[S -> A . A]$
  - $[A -> . a A]$
  - $[A -> . b]$

  *$I_3 = "GOTO"(I_0, a)$:*
  - $[A -> a . A]$
  - $[A -> . a A]$
  - $[A -> . b]$

  *$I_4 = "GOTO"(I_0, b)$:*
  - $[A -> b .]$

  *$I_5 = "GOTO"(I_2, A)$:*
  - $[S -> A A .]$

  *$I_6 = "GOTO"(I_3, A)$:*
  - $[A -> a A .]$

  (GOTO(I_2, a) = I_3, GOTO(I_2, b) = I_4, GOTO(I_3, a) = I_3, GOTO(I_3, b) = I_4)
]

== Tipuri de Analizoare LR

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
  [*Tip*], [*Descriere*],
  [*LR(0)*], [Fără lookahead. Cel mai simplu, dar cel mai restrictiv.],
  [*SLR(1)*], [Simple LR. Folosește FOLLOW pentru a decide reducerile.],
  [*LR(1)*], [Canonical LR. Fiecare element are lookahead explicit.],
  [*LALR(1)*], [Look-Ahead LR. Combină stări LR(1) cu același nucleu.],
)

Putere expresivă: LR(0) < SLR(1) < LALR(1) < LR(1)

== Construcția Tabelului SLR

#algoritm(title: "Construcția tabelului SLR")[
  Fie $C = {I_0, I_1, ..., I_n}$ colecția canonică LR(0).

  *ACTION[i, a]:*

  1. Dacă $[A -> alpha . a beta] in I_i$ și $"GOTO"(I_i, a) = I_j$:
     - ACTION[i, a] = *shift j* (sj)

  2. Dacă $[A -> alpha .] in I_i$ și $A != S'$:
     - Pentru fiecare $a in "FOLLOW"(A)$:
       - ACTION[i, a] = *reduce A -> α* (rk, unde k e numărul producției)

  3. Dacă $[S' -> S .] in I_i$:
     - ACTION[i, \$] = *accept*

  *GOTO[i, A]:* (pentru neterminale)

  4. Dacă $"GOTO"(I_i, A) = I_j$:
     - GOTO[i, A] = j
]

#exemplu(title: "Tabelul SLR complet")[
  Pentru gramatica $S -> A A$, $A -> a A | b$:

  FOLLOW(S) = {\$}, FOLLOW(A) = {a, b, \$}

  #table(
    columns: (auto, auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 or x == 0 { rgb("#e3f2fd") } else { white },
    [], [*a*], [*b*], [*\$*], [*S*], [*A*],
    [*$I_0$*], [s3], [s4], [], [1], [2],
    [*$I_1$*], [], [], [acc], [], [],
    [*$I_2$*], [s3], [s4], [], [], [5],
    [*$I_3$*], [s3], [s4], [], [], [6],
    [*$I_4$*], [r3], [r3], [r3], [], [],
    [*$I_5$*], [], [], [r1], [], [],
    [*$I_6$*], [r2], [r2], [r2], [], [],
  )

  Nu avem conflicte → gramatica este SLR(1).
]

== Conflicte

#definitie(title: "Conflicte LR")[
  - *Conflict shift-reduce*: în aceeași celulă avem și shift și reduce
  - *Conflict reduce-reduce*: în aceeași celulă avem două reduceri diferite
]

#greseala[
  *Dacă există conflicte, gramatica NU este de tipul respectiv!*

  - Conflicte în tabelul LR(0) → nu e LR(0)
  - Conflicte în tabelul SLR → nu e SLR (dar poate fi LR(1))
]

== Algoritmul de Analiză LR

#algoritm(title: "Analizorul LR")[
  *Structuri:*
  - Stiva: conține alternant stări și simboluri
  - Intrare: cuvântul de analizat + \$

  ```
  push(0);  // starea inițială
  a = primul simbol;
  while (true) {
      s = top(stiva);
      if (ACTION[s, a] == shift t) {
          push(a); push(t);
          a = următorul simbol;
      } else if (ACTION[s, a] == reduce A -> β) {
          pop 2*|β| elemente;
          t = top(stiva);
          push(A); push(GOTO[t, A]);
          output("A -> β");
      } else if (ACTION[s, a] == accept) {
          return SUCCESS;
      } else {
          error();
      }
  }
  ```
]

#exemplu(title: "Analiză LR pas cu pas")[
  Analizăm $a b a b$ cu gramatica $S -> A A$, $A -> a A | b$.

  #table(
    columns: (auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Stiva*], [*Intrare*], [*Acțiune*], [*Ieșire*],
    [0], [a b a b \$], [shift 3], [],
    [0 a 3], [b a b \$], [shift 4], [],
    [0 a 3 b 4], [a b \$], [reduce $A -> b$], [3],
    [0 a 3 A 6], [a b \$], [reduce $A -> a A$], [2 3],
    [0 A 2], [a b \$], [shift 3], [2 3],
    [0 A 2 a 3], [b \$], [shift 4], [2 3],
    [0 A 2 a 3 b 4], [\$], [reduce $A -> b$], [3 2 3],
    [0 A 2 a 3 A 6], [\$], [reduce $A -> a A$], [2 3 2 3],
    [0 A 2 A 5], [\$], [reduce $S -> A A$], [1 2 3 2 3],
    [0 S 1], [\$], [accept], [],
  )

  *Derivarea (în ordine inversă):* $S => A A => A a A => A a b => a A a b => a b a b$
]

== Analiza LR(1)

#definitie(title: "Element LR(1)")[
  Un *element LR(1)* este o pereche:

  $[A -> alpha . beta, a]$

  unde $a in V_T union {dollar}$ este *simbolul lookahead*.

  Semnificație: reducem $A -> alpha$ doar dacă următorul simbol este $a$.
]

#algoritm(title: "CLOSURE pentru LR(1)")[
  Dacă $[A -> alpha . B beta, a] in I$:
  - Pentru fiecare $B -> gamma$ și fiecare $b in "FIRST"(beta a)$:
    - Adaugă $[B -> . gamma, b]$
]

== LALR(1)

#definitie(title: "LALR(1)")[
  LALR(1) se obține din LR(1) prin *unirea stărilor cu același nucleu*.

  Nucleul = mulțimea de elemente fără lookahead.

  Avantaj: mai puține stări decât LR(1), aceeași putere pentru majoritatea gramaticilor practice.
]

#exemplu(title: "Unirea stărilor pentru LALR")[
  Dacă în LR(1) avem:
  - $I_5 = {[A -> a A ., dollar]}$
  - $I_8 = {[A -> a A ., b]}$

  Aceste stări au același nucleu $[A -> a A .]$.

  Le unim în LALR: $I_(5-8) = {[A -> a A ., dollar | b]}$
]

== Exercițiu Complet Rezolvat

#exercitiu(1)[
  Fie gramatica:
  - $S -> a S c$
  - $S -> b S c$
  - $S -> i$

  a) Construiți colecția canonică LR(0).
  b) Construiți tabelul SLR.
  c) Este gramatica SLR(1)?
  d) Analizați secvența $a i c$.
]

#rezolvare[
  Gramatica augmentată:
  - (0) $S' -> S$
  - (1) $S -> a S c$
  - (2) $S -> b S c$
  - (3) $S -> i$

  *a) Colecția canonică:*

  $I_0$: $[S' -> . S], [S -> . a S c], [S -> . b S c], [S -> . i]$

  $I_1 = "GOTO"(I_0, S)$: $[S' -> S .]$

  $I_2 = "GOTO"(I_0, a)$: $[S -> a . S c], [S -> . a S c], [S -> . b S c], [S -> . i]$

  $I_3 = "GOTO"(I_0, b)$: $[S -> b . S c], [S -> . a S c], [S -> . b S c], [S -> . i]$

  $I_4 = "GOTO"(I_0, i)$: $[S -> i .]$

  $I_5 = "GOTO"(I_2, S)$: $[S -> a S . c]$

  $I_6 = "GOTO"(I_3, S)$: $[S -> b S . c]$

  $I_7 = "GOTO"(I_5, c)$: $[S -> a S c .]$

  $I_8 = "GOTO"(I_6, c)$: $[S -> b S c .]$

  (GOTO(I_2, a) = I_2, GOTO(I_2, b) = I_3, GOTO(I_2, i) = I_4)
  (GOTO(I_3, a) = I_2, GOTO(I_3, b) = I_3, GOTO(I_3, i) = I_4)

  *b) FOLLOW:* FOLLOW(S) = {c, \$}

  *Tabelul SLR:*

  #table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 or x == 0 { rgb("#e3f2fd") } else { white },
    [], [*a*], [*b*], [*c*], [*i*], [*\$*], [*S*],
    [$I_0$], [s2], [s3], [], [s4], [], [1],
    [$I_1$], [], [], [], [], [acc], [],
    [$I_2$], [s2], [s3], [], [s4], [], [5],
    [$I_3$], [s2], [s3], [], [s4], [], [6],
    [$I_4$], [], [], [r3], [], [r3], [],
    [$I_5$], [], [], [s7], [], [], [],
    [$I_6$], [], [], [s8], [], [], [],
    [$I_7$], [], [], [r1], [], [r1], [],
    [$I_8$], [], [], [r2], [], [r2], [],
  )

  *c)* Nu există conflicte → *gramatica este SLR(1)*.

  *d) Analiza secvenței $a i c$:*

  #table(
    columns: (auto, auto, auto, auto),
    stroke: 0.5pt,
    [*Stiva*], [*Intrare*], [*Acțiune*], [*Ieșire*],
    [0], [a i c \$], [s2], [],
    [0 a 2], [i c \$], [s4], [],
    [0 a 2 i 4], [c \$], [r3 ($S -> i$)], [3],
    [0 a 2 S 5], [c \$], [s7], [3],
    [0 a 2 S 5 c 7], [\$], [r1 ($S -> a S c$)], [1 3],
    [0 S 1], [\$], [acc], [],
  )

  $a i c in L(G)$ $checkmark$
]

#pagebreak()
