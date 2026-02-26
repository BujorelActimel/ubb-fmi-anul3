// ============================================================================
// CAPITOLUL 1: NOȚIUNI DE BAZĂ
// ============================================================================

#import "../lib/template.typ": *

= Noțiuni de Bază

== Alfabete și Simboluri

#definitie(title: "Alfabet")[
  Un *alfabet* $Sigma$ este o mulțime finită, nevidă de simboluri.

  Exemple:
  - $Sigma = {a, b}$ - alfabet binar cu literele a și b
  - $Sigma = {0, 1}$ - alfabet binar cu cifrele 0 și 1
  - $Sigma = {a, b, c, ..., z}$ - alfabetul latin
]

== Secvențe (Cuvinte)

#definitie(title: "Secvență/Cuvânt")[
  O *secvență* (sau *cuvânt*) peste un alfabet $Sigma$ este o succesiune finită de simboluri din $Sigma$.

  - *Cuvântul vid* $epsilon$ este cuvântul fără niciun simbol, cu $|epsilon| = 0$
  - *Lungimea* unui cuvânt $w$, notată $|w|$, este numărul de simboluri din $w$

  Exemple pentru $Sigma = {a, b}$:
  - $w = a b a$ este un cuvânt cu $|w| = 3$
  - $w = a a a a$ este un cuvânt cu $|w| = 4$
  - $epsilon$ este cuvântul vid cu $|epsilon| = 0$
]

#definitie(title: "Mulțimi de cuvinte")[
  - $Sigma^*$ = mulțimea tuturor cuvintelor peste $Sigma$ (inclusiv $epsilon$)
  - $Sigma^+$ = mulțimea tuturor cuvintelor *nevide* peste $Sigma$ ($Sigma^+ = Sigma^* - {epsilon}$)

  Relația: $Sigma^* = Sigma^+ union {epsilon}$
]

== Operații cu Cuvinte

=== Concatenarea

#definitie(title: "Concatenarea")[
  *Concatenarea* a două cuvinte $u$ și $v$ este cuvântul $u v$ obținut prin alipirea lui $v$ la sfârșitul lui $u$.

  Proprietăți:
  - $|u v| = |u| + |v|$
  - $epsilon dot.c w = w dot.c epsilon = w$ (elementul neutru)
  - Asociativitate: $(u v) w = u (v w)$
  - *NU* este comutativă: $a b != b a$
]

#exemplu[
  Fie $u = a b$ și $v = b a$. Atunci:
  - $u v = a b b a$
  - $v u = b a a b$
  - $|u v| = |u| + |v| = 2 + 2 = 4$
]

=== Puterea unui cuvânt

#definitie(title: "Puterea unui cuvânt")[
  *Puterea* $n$ a unui cuvânt $w$, notată $w^n$, este:
  - $w^0 = epsilon$
  - $w^1 = w$
  - $w^n = w^(n-1) w$ pentru $n >= 1$

  Cu alte cuvinte, $w^n$ = $w$ concatenat cu el însuși de $n$ ori.
]

#exemplu[
  Fie $w = a b$. Atunci:
  - $w^0 = epsilon$
  - $w^1 = a b$
  - $w^2 = a b a b$
  - $w^3 = a b a b a b$
]

=== Oglinditul (Reversul)

#definitie(title: "Oglinditul")[
  *Oglinditul* (sau *reversul*) unui cuvânt $w$, notat $w^R$, este cuvântul obținut prin citirea lui $w$ de la dreapta la stânga.

  Formal:
  - $epsilon^R = epsilon$
  - $(w a)^R = a w^R$ pentru orice cuvânt $w$ și simbol $a$
]

#exemplu[
  - $(a b c)^R = c b a$
  - $(a b b a)^R = a b b a$ (palindrom)
  - $epsilon^R = epsilon$
]

== Limbaje

#definitie(title: "Limbaj")[
  Un *limbaj* $L$ peste un alfabet $Sigma$ este o submulțime a lui $Sigma^*$.

  $L subset.eq Sigma^*$

  Exemple:
  - $L = emptyset$ - limbajul vid (nu conține niciun cuvânt)
  - $L = {epsilon}$ - limbajul care conține doar cuvântul vid
  - $L = {a^n b^n | n >= 0}$ - limbajul cuvintelor de forma $a...a b...b$ cu număr egal de $a$ și $b$
]

#atentie[
  *Diferența importantă:*
  - $emptyset$ este limbajul *vid* (mulțime fără elemente)
  - ${epsilon}$ este limbajul care conține *un singur element*: cuvântul vid

  $emptyset != {epsilon}$
]

== Operații cu Limbaje

=== Reuniunea, Intersecția, Diferența

Fiind mulțimi, limbajele admit operațiile standard:

- *Reuniunea*: $L_1 union L_2 = {w | w in L_1 "sau" w in L_2}$
- *Intersecția*: $L_1 inter L_2 = {w | w in L_1 "și" w in L_2}$
- *Diferența*: $L_1 - L_2 = {w | w in L_1 "și" w in.not L_2}$
- *Complementul*: $overline(L) = Sigma^* - L$

=== Concatenarea limbajelor

#definitie(title: "Concatenarea limbajelor")[
  *Concatenarea* a două limbaje $L_1$ și $L_2$ este:

  $L_1 dot.c L_2 = {u v | u in L_1, v in L_2}$

  Adică, mulțimea tuturor cuvintelor obținute prin concatenarea unui cuvânt din $L_1$ cu unul din $L_2$.
]

#exemplu[
  Fie $L_1 = {a, a a}$ și $L_2 = {b, b b}$. Atunci:

  $L_1 L_2 = {a b, a b b, a a b, a a b b}$
]

=== Puterea unui limbaj

#definitie(title: "Puterea unui limbaj")[
  *Puterea* $n$ a unui limbaj $L$, notată $L^n$:
  - $L^0 = {epsilon}$
  - $L^1 = L$
  - $L^n = L^(n-1) dot.c L$ pentru $n >= 1$
]

#exemplu[
  Fie $L = {a, b}$. Atunci:
  - $L^0 = {epsilon}$
  - $L^1 = {a, b}$
  - $L^2 = {a a, a b, b a, b b}$
  - $L^3 = {a a a, a a b, a b a, a b b, b a a, b a b, b b a, b b b}$
]

=== Închiderea Kleene (Steaua)

#definitie(title: "Închiderea Kleene")[
  *Închiderea Kleene* (sau *steaua*) unui limbaj $L$, notată $L^*$:

  $L^* = union.big_(i=0)^infinity L^i = L^0 union L^1 union L^2 union ...$

  Este mulțimea tuturor cuvintelor obținute prin concatenarea a zero sau mai multe cuvinte din $L$.
]

#definitie(title: "Închiderea pozitivă")[
  *Închiderea pozitivă* a unui limbaj $L$, notată $L^+$:

  $L^+ = union.big_(i=1)^infinity L^i = L^1 union L^2 union L^3 union ...$

  Relația: $L^* = L^+ union {epsilon}$ și $L^+ = L dot.c L^* = L^* dot.c L$
]

#truc[
  *Relații importante:*
  - $epsilon in L^*$ întotdeauna (pentru orice $L$)
  - $epsilon in L^+$ dacă și numai dacă $epsilon in L$
  - $L^* = L^+ union {epsilon}$
  - $L^+ = L L^* = L^* L$
]

#exemplu[
  Fie $L = {a b}$. Atunci:
  - $L^* = {epsilon, a b, a b a b, a b a b a b, ...} = {(a b)^n | n >= 0}$
  - $L^+ = {a b, a b a b, a b a b a b, ...} = {(a b)^n | n >= 1}$
]

== Exerciții Rezolvate

#exercitiu(1)[
  Fie $L = {a}$. Calculați $L^*$ și $L^+$.
]

#rezolvare[
  - $L^0 = {epsilon}$
  - $L^1 = {a}$
  - $L^2 = {a a}$
  - $L^3 = {a a a}$
  - ...

  Deci:
  - $L^* = {epsilon, a, a a, a a a, ...} = {a^n | n >= 0}$
  - $L^+ = {a, a a, a a a, ...} = {a^n | n >= 1}$
]

#exercitiu(2)[
  Demonstrați că $L^* = L^+ union {epsilon}$.
]

#rezolvare[
  Din definiții:
  - $L^* = L^0 union L^1 union L^2 union ... = {epsilon} union L^1 union L^2 union ...$
  - $L^+ = L^1 union L^2 union ...$

  Deci $L^* = {epsilon} union L^+ = L^+ union {epsilon}$ $square$
]

#exercitiu(3)[
  Fie $L_1 = {a, a a}$ și $L_2 = {b}$. Calculați $L_1 L_2$ și $L_2 L_1$.
]

#rezolvare[
  $L_1 L_2 = {a b, a a b}$

  $L_2 L_1 = {b a, b a a}$

  Observăm că $L_1 L_2 != L_2 L_1$ (concatenarea nu este comutativă).
]

== Fazele Compilării (Întrebări tip grilă)

#atentie[
  *Aceste întrebări apar frecvent la examen ca multiple choice (1p)!*
]

#definitie(title: "Fazele compilării")[
  Un *compilator* traduce codul sursă în cod mașină prin următoarele faze:

  1. *Analiza lexicală* (Scanner) - identifică atomii lexicali (tokeni)
  2. *Analiza sintactică* (Parser) - construiește arborele de derivare
  3. *Analiza semantică* - verifică tipurile și sensul
  4. *Generarea codului intermediar* - produce cod abstract
  5. *Optimizarea codului* - îmbunătățește eficiența
  6. *Generarea codului final* - produce cod mașină
]

#truc[
  *Întrebări tip examen și răspunsuri:*

  *Q: "Analiza lexicală are drept scop:"*
  - ✓ identificarea atomilor lexicali (tokeni)
  - ✗ crearea arborelui de derivare (→ analiza sintactică)
  - ✗ generarea codului mașină (→ generarea codului)
  - ✗ crearea codului intermediar (→ faza de cod intermediar)

  *Q: "Cuvintele cheie sunt recunoscute în timpul:"*
  - ✓ analizei lexicale (cuvintele cheie sunt tokeni speciali)
  - ✗ analizei sintactice
  - ✗ analizei semantice
  - ✗ fazei de generare de cod

  *Q: "Arborele de derivare se construiește în timpul:"*
  - ✗ analizei lexicale
  - ✓ analizei sintactice
  - ✗ analizei semantice
  - ✗ optimizării

  *Q: "Verificarea tipurilor se face în timpul:"*
  - ✗ analizei lexicale
  - ✗ analizei sintactice
  - ✓ analizei semantice
  - ✗ generării codului
]

== Gramatici - Definiție Formală

#definitie(title: "Gramatică")[
  O *gramatică* este un cvadruplu $G = (V_N, V_T, P, S)$ unde:

  - $V_N$ = mulțimea *neterminalelor* (variabilelor) - simboluri care pot fi înlocuite
  - $V_T$ = mulțimea *terminalelor* - simboluri din alfabetul final
  - $P$ = mulțimea *producțiilor* (regulilor de rescriere)
  - $S in V_N$ = *simbolul de start* (axioma)

  Condiții: $V_N inter V_T = emptyset$ și $V_N union V_T != emptyset$
]

#truc[
  *La examen, când vi se cere definiția formală a unei gramatici:*

  "O gramatică este un cvadruplu $G = (V_N, V_T, P, S)$ unde:
  - $V_N$ este mulțimea finită, nevidă de neterminale
  - $V_T$ este mulțimea finită de terminale, cu $V_N inter V_T = emptyset$
  - $P$ este mulțimea finită de producții
  - $S in V_N$ este simbolul de start"
]

#exemplu(title: "Exemplu de gramatică")[
  $G = ({S, A}, {a, b}, P, S)$ cu producțiile:
  - $S -> a A$
  - $A -> b A$
  - $A -> epsilon$

  Această gramatică generează limbajul $L(G) = {a b^n | n >= 0} = {a, a b, a b b, ...}$
]

#pagebreak()
