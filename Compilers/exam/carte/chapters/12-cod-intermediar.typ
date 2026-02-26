// ============================================================================
// CAPITOLUL 12: COD INTERMEDIAR
// ============================================================================

#import "../lib/template.typ": *

= Cod Intermediar

#atentie[
  *Problemele cu cod intermediar apar frecvent la examen!*

  Tipic: "Traduceți instrucțiunea Pascal în cod intermediar cu 3 adrese, reprezentare cvadruple" (2p)
]

== De Ce Cod Intermediar?

#definitie(title: "Cod Intermediar")[
  *Codul intermediar* este o reprezentare a programului între codul sursă și codul mașină.

  Avantaje:
  - *Portabilitate*: același front-end pentru mai multe arhitecturi
  - *Optimizare*: mai ușor de optimizat decât codul mașină
  - *Simplitate*: operații simple, uniforme
]

== Cod cu 3 Adrese

#definitie(title: "Instrucțiune cu 3 adrese")[
  O *instrucțiune cu 3 adrese* are forma:

  $x := y "op" z$

  unde $x$, $y$, $z$ sunt adrese (variabile sau temporare) și "op" este un operator.

  Fiecare instrucțiune are *cel mult un operator* (în afară de atribuire).
]

=== Tipuri de Instrucțiuni

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
  [*Forma*], [*Semnificație*],
  [$x := y "op" z$], [Operație binară (op ∈ {+, -, \*, /, <, >, =, ...})],
  [$x := "op" y$], [Operație unară (op ∈ {-, not, ...})],
  [$x := y$], [Copiere/atribuire],
  [$"goto" L$], [Salt necondiționat la eticheta L],
  [$"if" x "goto" L$], [Salt condiționat (dacă x este true)],
  [$"if" x "relop" y "goto" L$], [Salt condiționat cu comparație],
  [$"param" x$], [Parametru pentru apel de funcție],
  [$"call" p, n$], [Apel funcție p cu n parametri],
  [$"return" x$], [Întoarcere din funcție],
  [$x := y[i]$], [Acces indexat (citire din array)],
  [$x[i] := y$], [Acces indexat (scriere în array)],
)

== Reprezentări ale Codului cu 3 Adrese

=== Cvadruple

#definitie(title: "Cvadruplu")[
  Un *cvadruplu* este un tuplu $(op, arg_1, arg_2, "result")$:
  - $op$ = operatorul
  - $arg_1$ = primul operand
  - $arg_2$ = al doilea operand (poate fi vid)
  - $"result"$ = destinația rezultatului
]

#exemplu(title: "Expresia $a + b ast.op c$ în cvadruple")[
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Nr*], [*op*], [*arg1*], [*arg2*], [*result*],
    [0], [\*], [b], [c], [t1],
    [1], [+], [a], [t1], [t2],
  )

  Codul generat:
  - `t1 := b * c`
  - `t2 := a + t1`
]

=== Triple

#definitie(title: "Triplu")[
  Un *triplu* este un tuplu $(op, arg_1, arg_2)$ unde rezultatul este *implicit* - referit prin numărul triplului.

  Economie de spațiu, dar reordonarea este mai dificilă.
]

#exemplu(title: "Expresia $a + b ast.op c$ în triple")[
  #table(
    columns: (auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Nr*], [*op*], [*arg1*], [*arg2*],
    [0], [\*], [b], [c],
    [1], [+], [a], [(0)],
  )

  (0) referă rezultatul triplului 0.
]

== Generarea Codului pentru Expresii

#algoritm(title: "Generare cod pentru expresii aritmetice")[
  Pentru $E -> E_1 "op" E_2$:
  ```
  E.place = newtemp();
  E.code = E1.code || E2.code ||
           gen(E.place ':=' E1.place 'op' E2.place);
  ```

  Pentru $E -> (E_1)$:
  ```
  E.place = E1.place;
  E.code = E1.code;
  ```

  Pentru $E -> "id"$:
  ```
  E.place = id.name;
  E.code = '';
  ```
]

#exemplu(title: "Generarea codului pentru $x + y ast.op z$")[
  Pas cu pas:
  1. $y$: place = y, code = ""
  2. $z$: place = z, code = ""
  3. $y ast.op z$: place = t1, code = "t1 := y \* z"
  4. $x$: place = x, code = ""
  5. $x + y ast.op z$: place = t2, code = "t1 := y \* z; t2 := x + t1"

  *Cod final:*
  ```
  t1 := y * z
  t2 := x + t1
  ```
]

== Generarea Codului pentru Instrucțiuni de Control

=== Instrucțiunea IF-THEN-ELSE

#exemplu(title: "if a > b then max := a else max := b")[
  *Structura:*
  ```
      if a > b goto L1
      goto L2
  L1: max := a
      goto L3
  L2: max := b
  L3: ...
  ```

  *Cvadruple:*
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
    [6], [...], [], [], [],
  )
]

=== Instrucțiunea WHILE

#exemplu(title: "while a > b do a := a - 1")[
  *Structura:*
  ```
  L1: if a > b goto L2
      goto L3
  L2: a := a - 1
      goto L1
  L3: ...
  ```

  *Cvadruple:*
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Nr*], [*op*], [*arg1*], [*arg2*], [*result*],
    [0], [>], [a], [b], [t1],
    [1], [jmpt], [t1], [-], [3],
    [2], [jmp], [-], [-], [6],
    [3], [-], [a], [1], [t2],
    [4], [:=], [t2], [-], [a],
    [5], [jmp], [-], [-], [0],
    [6], [...], [], [], [],
  )
]

=== Instrucțiunea REPEAT-UNTIL

#exemplu(title: "repeat a := a - b until a < b")[
  *Structura:*
  ```
  L1: a := a - b
      if a < b goto L2
      goto L1
  L2: ...
  ```

  *Cvadruple:*
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Nr*], [*op*], [*arg1*], [*arg2*], [*result*],
    [0], [-], [a], [b], [t1],
    [1], [:=], [t1], [-], [a],
    [2], [<], [a], [b], [t2],
    [3], [jmpt], [t2], [-], [5],
    [4], [jmp], [-], [-], [0],
    [5], [...], [], [], [],
  )
]

== Exerciții Rezolvate

#exercitiu(1)[
  Traduceți în cod intermediar cu 3 adrese (reprezentare cvadruple):
  ```pascal
  if x > y then
      z := x - y
  else
      z := y - x
  ```
]

#rezolvare[
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Nr*], [*op*], [*arg1*], [*arg2*], [*result*],
    [0], [>], [x], [y], [t1],
    [1], [jmpt], [t1], [-], [3],
    [2], [jmp], [-], [-], [6],
    [3], [-], [x], [y], [t2],
    [4], [:=], [t2], [-], [z],
    [5], [jmp], [-], [-], [8],
    [6], [-], [y], [x], [t3],
    [7], [:=], [t3], [-], [z],
    [8], [], [], [], [],
  )
]

#exercitiu(2)[
  Traduceți în cod intermediar cu 3 adrese (reprezentare cvadruple):
  ```pascal
  repeat
      a := a - b
  until a < b
  ```
]

#rezolvare[
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Nr*], [*op*], [*arg1*], [*arg2*], [*result*],
    [0], [-], [a], [b], [t1],
    [1], [:=], [t1], [-], [a],
    [2], [<], [a], [b], [t2],
    [3], [jmpf], [t2], [-], [0],
  )

  *Notă:* `jmpf` = jump if false (salt dacă condiția este falsă).

  Alternativ, cu `jmpt`:
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    [*Nr*], [*op*], [*arg1*], [*arg2*], [*result*],
    [0], [-], [a], [b], [t1],
    [1], [:=], [t1], [-], [a],
    [2], [<], [a], [b], [t2],
    [3], [jmpt], [t2], [-], [5],
    [4], [jmp], [-], [-], [0],
    [5], [], [], [], [],
  )
]

#exercitiu(3)[
  Traduceți expresia $(a + b) ast.op (c - d)$ în cvadruple.
]

#rezolvare[
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Nr*], [*op*], [*arg1*], [*arg2*], [*result*],
    [0], [+], [a], [b], [t1],
    [1], [-], [c], [d], [t2],
    [2], [\*], [t1], [t2], [t3],
  )

  Cod cu 3 adrese:
  ```
  t1 := a + b
  t2 := c - d
  t3 := t1 * t2
  ```
]

#truc[
  *La examen:*
  - Numerotați cvadruplele începând de la 0
  - Folosiți variabile temporare t1, t2, ... pentru rezultate intermediare
  - Pentru salturi, indicați numărul cvadruplului destinație
  - Operatorii comuni: +, -, \*, /, <, >, <=, >=, =, :=, jmp, jmpt, jmpf
]

#pagebreak()
