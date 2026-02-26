// ============================================================================
// CAPITOLUL 9: ANALIZA SINTACTICĂ LL(k)
// ============================================================================

#import "../lib/template.typ": *

= Analiza Sintactică LL(k)

#atentie[
  *CAPITOL CRITIC PENTRU EXAMEN!*

  Problemele cu FIRST, FOLLOW și tabele LL(1) apar *obligatoriu* la examen, valorând 1-3 puncte.
]

== Principiul Analizei LL(k)

#definitie(title: "Analiza LL(k)")[
  *LL(k)* înseamnă:
  - *L* = Left-to-right (citim de la stânga la dreapta)
  - *L* = Leftmost derivation (derivare stânga)
  - *k* = numărul de simboluri lookahead

  Analizorul LL(k) este *predictiv*: folosind următoarele $k$ simboluri din intrare, poate decide *unic* ce producție să aplice.
]

== Funcția FIRST

#definitie(title: "FIRST(α)")[
  Pentru $alpha in (V_N union V_T)^*$, definim:

  $"FIRST"(alpha) = {a in V_T | alpha =>^* a beta} union {epsilon | alpha =>^* epsilon}$

  Adică, mulțimea terminalelor care pot apărea *la începutul* oricărei derivări din $alpha$, plus $epsilon$ dacă $alpha$ poate genera cuvântul vid.
]

#algoritm(title: "Calculul FIRST")[
  *Pentru un simbol $X$:*

  1. Dacă $X$ este *terminal*: $"FIRST"(X) = {X}$

  2. Dacă $X$ este *neterminal*:
     - Pentru fiecare producție $X -> Y_1 Y_2 ... Y_k$:
       - Adaugă $"FIRST"(Y_1) - {epsilon}$ la $"FIRST"(X)$
       - Dacă $epsilon in "FIRST"(Y_1)$, adaugă $"FIRST"(Y_2) - {epsilon}$
       - ...continuă până găsești un $Y_i$ cu $epsilon in.not "FIRST"(Y_i)$
       - Dacă $epsilon in "FIRST"(Y_i)$ pentru toți $i$, adaugă $epsilon$ la $"FIRST"(X)$
     - Pentru $X -> epsilon$: adaugă $epsilon$ la $"FIRST"(X)$

  *Pentru un șir $alpha = X_1 X_2 ... X_n$:*

  $"FIRST"(alpha) = "FIRST"(X_1) - {epsilon}$

  Dacă $epsilon in "FIRST"(X_1)$, adaugă $"FIRST"(X_2) - {epsilon}$, etc.
]

#exemplu(title: "Calculul FIRST")[
  Gramatica:
  - $E -> T E'$
  - $E' -> + T E' | epsilon$
  - $T -> F T'$
  - $T' -> ast.op F T' | epsilon$
  - $F -> (E) | "id"$

  *Calculul FIRST:*

  $"FIRST"(F) = {(, "id"}$ (din $F -> (E)$ și $F -> "id"$)

  $"FIRST"(T') = {ast.op, epsilon}$ (din $T' -> * F T'$ și $T' -> epsilon$)

  $"FIRST"(T) = "FIRST"(F) = {(, "id"}$ (din $T -> F T'$, $F$ nu generează $epsilon$)

  $"FIRST"(E') = {+, epsilon}$ (din $E' -> + T E'$ și $E' -> epsilon$)

  $"FIRST"(E) = "FIRST"(T) = {(, "id"}$ (din $E -> T E'$, $T$ nu generează $epsilon$)
]

== Funcția FOLLOW

#definitie(title: "FOLLOW(A)")[
  Pentru $A in V_N$, definim:

  $"FOLLOW"(A) = {a in V_T | S =>^* alpha A a beta} union {dollar | S =>^* alpha A}$

  Adică, mulțimea terminalelor care pot apărea *imediat după* $A$ în orice formă propozițională derivată din $S$, plus $dollar$ dacă $A$ poate apărea la sfârșitul derivării.
]

#algoritm(title: "Calculul FOLLOW")[
  1. $dollar in "FOLLOW"(S)$ (simbolul de start poate fi urmat de sfârșitul intrării)

  2. Pentru fiecare producție $A -> alpha B beta$:
     - Adaugă $"FIRST"(beta) - {epsilon}$ la $"FOLLOW"(B)$

  3. Pentru fiecare producție $A -> alpha B$ sau $A -> alpha B beta$ unde $epsilon in "FIRST"(beta)$:
     - Adaugă $"FOLLOW"(A)$ la $"FOLLOW"(B)$

  Repetă pașii 2-3 până nu se mai adaugă nimic.
]

#exemplu(title: "Calculul FOLLOW")[
  Gramatica (continuare):
  - $E -> T E'$
  - $E' -> + T E' | epsilon$
  - $T -> F T'$
  - $T' -> ast.op F T' | epsilon$
  - $F -> (E) | "id"$

  *Calculul FOLLOW:*

  $"FOLLOW"(E) = {dollar}$ (simbolul de start)

  Din $F -> (E)$: $) in "FOLLOW"(E)$

  $"FOLLOW"(E) = {dollar, )}$

  Din $E -> T E'$: $"FOLLOW"(E') supset.eq "FOLLOW"(E)$ (deoarece $E'$ e la final)

  $"FOLLOW"(E') = {dollar, )}$

  Din $E -> T E'$: $"FIRST"(E') - {epsilon} = {+} subset.eq "FOLLOW"(T)$

  Dar $epsilon in "FIRST"(E')$, deci $"FOLLOW"(E) subset.eq "FOLLOW"(T)$

  $"FOLLOW"(T) = {+, dollar, )}$

  Din $E' -> + T E'$: similar, $"FOLLOW"(T) supset.eq "FOLLOW"(E') = {dollar, )}$

  $"FOLLOW"(T) = {+, dollar, )}$

  Din $T -> F T'$: $"FIRST"(T') - {epsilon} = {ast.op} subset.eq "FOLLOW"(F)$

  Dar $epsilon in "FIRST"(T')$, deci $"FOLLOW"(T) subset.eq "FOLLOW"(F)$

  $"FOLLOW"(F) = {ast.op, +, dollar, )}$

  Din $T' -> ast.op F T'$: similar

  $"FOLLOW"(T') = "FOLLOW"(T) = {+, dollar, )}$
]

#truc[
  *Regulă practică pentru FOLLOW:*

  - $A -> alpha B beta$: FOLLOW(B) primește FIRST(β) - {ε}
  - Dacă β poate genera ε (sau nu există): FOLLOW(B) primește FOLLOW(A)
  - Simbolul de start primește întotdeauna $dollar$
]

== Condiția LL(1)

#definitie(title: "Gramatică LL(1)")[
  O gramatică $G$ este *LL(1)* dacă pentru orice două producții $A -> alpha$ și $A -> beta$ cu $alpha != beta$:

  $"FIRST"(alpha) inter "FIRST"(beta) = emptyset$

  și dacă $epsilon in "FIRST"(alpha)$, atunci:

  $"FIRST"(beta) inter "FOLLOW"(A) = emptyset$
]

#greseala[
  *O gramatică NU este LL(1) dacă:*
  - Are *recursivitate la stânga*: $A -> A alpha$
  - Are *prefix comun*: $A -> alpha beta | alpha gamma$
  - Două alternative pot începe cu același terminal
]

== Construcția Tabelului LL(1)

#algoritm(title: "Construcția tabelului de analiză LL(1)")[
  Tabelul $M[A, a]$ unde $A in V_N$ și $a in V_T union {dollar}$:

  Pentru fiecare producție $A -> alpha$:

  1. Pentru fiecare $a in "FIRST"(alpha) - {epsilon}$:
     - Adaugă $A -> alpha$ la $M[A, a]$

  2. Dacă $epsilon in "FIRST"(alpha)$:
     - Pentru fiecare $b in "FOLLOW"(A)$:
       - Adaugă $A -> alpha$ la $M[A, b]$
]

#exemplu(title: "Tabelul LL(1)")[
  Pentru gramatica expresiilor (după eliminarea recursivității stânga):

  #table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 or x == 0 { rgb("#e3f2fd") } else { white },
    [], [*id*], [*+*], [*\**], [*(*], [*)*], [*\$*],
    [*E*], [$E -> T E'$], [], [], [$E -> T E'$], [], [],
    [*E'*], [], [$E' -> + T E'$], [], [], [$E' -> epsilon$], [$E' -> epsilon$],
    [*T*], [$T -> F T'$], [], [], [$T -> F T'$], [], [],
    [*T'*], [], [$T' -> epsilon$], [$T' -> ast.op F T'$], [], [$T' -> epsilon$], [$T' -> epsilon$],
    [*F*], [$F -> "id"$], [], [], [$F -> (E)$], [], [],
  )
]

== Algoritmul de Analiză LL(1)

#algoritm(title: "Analizorul LL(1)")[
  *Input:* Cuvântul $w$ și tabelul de analiză $M$

  *Structuri:*
  - Stiva (inițial conține $dollar$ și $S$)
  - Pointerul de intrare (inițial pe primul simbol din $w dollar$)

  *Algoritm:*
  ```text
  push($); push(S);
  a = primul simbol din w;
  while (stiva nu e goală) {
      X = top(stiva);
      if (X == a) {
          pop(); a = următorul simbol;
      } else if (X este terminal) {
          error();
      } else if (M[X, a] este vid) {
          error();
      } else {
          // M[X, a] = X -> Y1 Y2 ... Yk
          pop();
          push(Yk); ... push(Y1);
          output("X -> Y1 Y2 ... Yk");
      }
  }
  accept();
  ```
]

#exemplu(title: "Analiză LL(1) pas cu pas")[
  Analizăm $"id" + "id" ast.op "id"$ cu gramatica expresiilor.

  #table(
    columns: (auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Stiva*], [*Intrare*], [*Ieșire*], [*Acțiune*],
    [$dollar E$], [id + id \* id \$], [], [$E -> T E'$],
    [$dollar E' T$], [id + id \* id \$], [$E -> T E'$], [$T -> F T'$],
    [$dollar E' T' F$], [id + id \* id \$], [$T -> F T'$], [$F -> "id"$],
    [$dollar E' T' "id"$], [id + id \* id \$], [$F -> "id"$], [match id],
    [$dollar E' T'$], [+ id \* id \$], [], [$T' -> epsilon$],
    [$dollar E'$], [+ id \* id \$], [$T' -> epsilon$], [$E' -> + T E'$],
    [$dollar E' T +$], [+ id \* id \$], [$E' -> + T E'$], [match +],
    [$dollar E' T$], [id \* id \$], [], [$T -> F T'$],
    [$dollar E' T' F$], [id \* id \$], [$T -> F T'$], [$F -> "id"$],
    [$dollar E' T' "id"$], [id \* id \$], [$F -> "id"$], [match id],
    [$dollar E' T'$], [\* id \$], [], [$T' -> ast.op F T'$],
    [$dollar E' T' F ast.op$], [\* id \$], [$T' -> ast.op F T'$], [match \*],
    [$dollar E' T' F$], [id \$], [], [$F -> "id"$],
    [$dollar E' T' "id"$], [id \$], [$F -> "id"$], [match id],
    [$dollar E' T'$], [\$], [], [$T' -> epsilon$],
    [$dollar E'$], [\$], [$T' -> epsilon$], [$E' -> epsilon$],
    [$dollar$], [\$], [$E' -> epsilon$], [*ACCEPT*],
  )
]

== Transformări pentru LL(1)

=== Eliminarea Recursivității Stânga

#algoritm(title: "Eliminarea recursivității stânga directe")[
  Dacă avem: $A -> A alpha_1 | A alpha_2 | ... | beta_1 | beta_2 | ...$

  Înlocuim cu:
  - $A -> beta_1 A' | beta_2 A' | ...$
  - $A' -> alpha_1 A' | alpha_2 A' | ... | epsilon$
]

#exemplu[
  $E -> E + T | T$

  Devine:
  - $E -> T E'$
  - $E' -> + T E' | epsilon$
]

=== Factorizare la Stânga

#algoritm(title: "Factorizarea la stânga")[
  Dacă avem: $A -> alpha beta_1 | alpha beta_2 | ...$

  Înlocuim cu:
  - $A -> alpha A'$
  - $A' -> beta_1 | beta_2 | ...$
]

#exemplu[
  $S -> "if" E "then" S | "if" E "then" S "else" S$

  Devine:
  - $S -> "if" E "then" S S'$
  - $S' -> "else" S | epsilon$
]

#exemplu(title: "Factorizare la stânga - gramatică expresii (exercițiu de examen)")[
  *Gramatică inițială:*
  - $E -> T + E$
  - $E -> T$
  - $T -> F ast.op T$
  - $T -> F$
  - $F -> (E)$
  - $F -> a$

  *Pas 1:* Identificăm prefixurile comune:
  - $E -> T + E | T$ au prefixul comun $T$
  - $T -> F ast.op T | F$ au prefixul comun $F$

  *Pas 2:* Aplicăm factorizarea:

  Pentru $E$: prefixul comun este $T$
  - $E -> T E'$
  - $E' -> + E | epsilon$

  Pentru $T$: prefixul comun este $F$
  - $T -> F T'$
  - $T' -> ast.op T | epsilon$

  *Gramatică finală (factorizată):*
  - $E -> T E'$
  - $E' -> + E | epsilon$
  - $T -> F T'$
  - $T' -> ast.op T | epsilon$
  - $F -> (E) | a$
]

== Exercițiu Complet Rezolvat

#exercitiu(1)[
  Fie gramatica:
  - $S -> a A | b$
  - $A -> a A | b$

  a) Calculați FIRST și FOLLOW pentru toate neterminalele.
  b) Construiți tabelul LL(1).
  c) Verificați dacă secvența $a a b$ aparține $L(G)$.
]

#rezolvare[
  *a) FIRST și FOLLOW:*

  $"FIRST"(S) = {a, b}$ (din $S -> a A$ și $S -> b$)

  $"FIRST"(A) = {a, b}$ (din $A -> a A$ și $A -> b$)

  $"FOLLOW"(S) = {dollar}$ (simbolul de start)

  $"FOLLOW"(A)$: Din $S -> a A$, $A$ e la final, deci $"FOLLOW"(S) subset.eq "FOLLOW"(A)$

  Din $A -> a A$, la fel.

  $"FOLLOW"(A) = {dollar}$

  *b) Tabelul LL(1):*

  #table(
    columns: (auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 or x == 0 { rgb("#e3f2fd") } else { white },
    [], [*a*], [*b*], [*\$*],
    [*S*], [$S -> a A$], [$S -> b$], [],
    [*A*], [$A -> a A$], [$A -> b$], [],
  )

  Gramatica este LL(1) (fără conflicte).

  *c) Analiza secvenței $a a b$:*

  #table(
    columns: (auto, auto, auto),
    stroke: 0.5pt,
    [*Stiva*], [*Intrare*], [*Acțiune*],
    [$dollar S$], [a a b \$], [$S -> a A$],
    [$dollar A a$], [a a b \$], [match a],
    [$dollar A$], [a b \$], [$A -> a A$],
    [$dollar A a$], [a b \$], [match a],
    [$dollar A$], [b \$], [$A -> b$],
    [$dollar b$], [b \$], [match b],
    [$dollar$], [\$], [*ACCEPT*],
  )

  $a a b in L(G)$ $checkmark$
]

#pagebreak()
