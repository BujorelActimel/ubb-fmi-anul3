// ============================================================================
// CAPITOLUL 8: ANALIZA DESCENDENTĂ CU REVENIRI
// ============================================================================

#import "../lib/template.typ": *

= Analiza Descendentă cu Reveniri

== Principiul Analizei Descendente

#definitie(title: "Analiza Descendentă (Top-Down)")[
  *Analiza descendentă* construiește arborele de derivare de la *rădăcină* (simbolul de start) către *frunze* (terminale).

  La fiecare pas, se încearcă expandarea neterminalului cel mai din stânga folosind producțiile gramaticii.
]

== Analizorul Descendent cu Reveniri

Când există mai multe producții pentru un neterminal, analizorul *încearcă* fiecare alternativă. Dacă alegerea duce la eșec, analizorul face *backtracking* (revenire) și încearcă următoarea alternativă.

=== Configurația Analizorului

#definitie(title: "Configurație")[
  O *configurație* este un cvadruplu $(s, i, alpha, beta)$ unde:
  - $s in {q, r, t, e}$ = starea analizorului
  - $i$ = poziția curentă în cuvântul de intrare (1, 2, ..., n+1)
  - $alpha$ = banda de lucru (istoria derivării)
  - $beta$ = forma propozițională curentă (ce mai e de derivat)
]

=== Stările Analizorului

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt,
  fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
  [*Stare*], [*Nume*], [*Semnificație*],
  [$q$], [Normal], [Stare normală de lucru],
  [$r$], [Revenire], [Backtracking - încercăm altă alternativă],
  [$t$], [Terminal/Accept], [Succes - cuvântul a fost acceptat],
  [$e$], [Eroare], [Eșec - cuvântul nu aparține limbajului],
)

=== Tranzițiile Analizorului

#algoritm(title: "Tranzițiile analizorului descendent cu reveniri")[
  Fie gramatica cu producțiile $A -> alpha_1 | alpha_2 | ... | alpha_k$ notate $A_1, A_2, ..., A_k$.

  *1. Expandare* (din starea $q$, neterminal în vârful lui $beta$):
  $(q, i, alpha, A gamma) tack.r (q, i, alpha A_1, alpha_1 gamma)$

  Se înlocuiește $A$ cu prima sa alternativă și se notează alegerea pe banda de lucru.

  *2. Avans* (din starea $q$, terminal în vârful lui $beta$ care coincide cu intrarea):
  $(q, i, alpha, a gamma) tack.r (q, i+1, alpha a, gamma)$ dacă $w_i = a$

  Se consumă terminalul și se avansează în intrare.

  *3. Insucces de moment* (din starea $q$, terminal în vârful lui $beta$ care NU coincide):
  $(q, i, alpha, a gamma) tack.r (r, i, alpha, a gamma)$ dacă $w_i != a$

  Se trece în starea de revenire.

  *4. Altă încercare* (din starea $r$, ultima alegere NU era ultima alternativă):
  $(r, i, alpha A_j, gamma) tack.r (q, i, alpha A_(j+1), alpha_(j+1) gamma')$

  unde $gamma = alpha_j gamma'$. Se încearcă următoarea alternativă.

  *5. Revenire* (din starea $r$, ultimul simbol pe bandă este terminal):
  $(r, i, alpha a, gamma) tack.r (r, i-1, alpha, a gamma)$

  Se "desface" ultimul pas de avans.

  *6. Succes* (din starea $q$, $beta$ vid și intrarea consumată):
  $(q, n+1, alpha, epsilon) tack.r (t, n+1, alpha, epsilon)$

  *7. Eșec* (din starea $r$, prima alternativă a simbolului de start, banda goală):
  $(r, 1, epsilon, S) tack.r (e, 1, epsilon, S)$
]

== Exemplu Complet Rezolvat

#exemplu(title: "Gramatica ambiguă")[
  Fie gramatica:
  - $S -> a S b S$ ... $(S_1)$
  - $S -> a S$ ... $(S_2)$
  - $S -> c$ ... $(S_3)$

  Verificăm dacă $w = a c b c in L(G)$.
]

#rezolvare[
  Configurația inițială: $(q, 1, epsilon, S)$

  #table(
    columns: (auto, 1fr, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Pas*], [*Configurație*], [*Operație*],
    [0], [$(q, 1, epsilon, S)$], [expandare],
    [1], [$(q, 1, S_1, a S b S)$], [avans (citim $a$)],
    [2], [$(q, 2, S_1 a, S b S)$], [expandare],
    [3], [$(q, 2, S_1 a S_1, a S b S b S)$], [insucces ($a != c$)],
    [4], [$(r, 2, S_1 a S_1, a S b S b S)$], [altă încercare],
    [5], [$(q, 2, S_1 a S_2, a S b S)$], [insucces ($a != c$)],
    [6], [$(r, 2, S_1 a S_2, a S b S)$], [altă încercare],
    [7], [$(q, 2, S_1 a S_3, c b S)$], [avans (citim $c$)],
    [8], [$(q, 3, S_1 a S_3 c, b S)$], [avans (citim $b$)],
    [9], [$(q, 4, S_1 a S_3 c b, S)$], [expandare],
    [10], [$(q, 4, S_1 a S_3 c b S_1, a S b S)$], [insucces ($a != c$)],
    [11], [$(r, 4, S_1 a S_3 c b S_1, a S b S)$], [altă încercare],
    [12], [$(q, 4, S_1 a S_3 c b S_2, a S)$], [insucces ($a != c$)],
    [13], [$(r, 4, S_1 a S_3 c b S_2, a S)$], [altă încercare],
    [14], [$(q, 4, S_1 a S_3 c b S_3, c)$], [avans (citim $c$)],
    [15], [$(q, 5, S_1 a S_3 c b S_3 c, epsilon)$], [*SUCCES*],
    [16], [$(t, 5, S_1 a S_3 c b S_3 c, epsilon)$], [],
  )

  *Rezultat:* $a c b c in L(G)$

  *Derivarea:* $S =>_(S_1) a S b S =>_(S_3) a c b S =>_(S_3) a c b c$

  Producțiile utilizate: $S_1, S_3, S_3$
]

#exemplu(title: "Cuvânt care NU aparține limbajului")[
  Fie aceeași gramatică. Verificăm dacă $w = c b in L(G)$.
]

#rezolvare[
  #table(
    columns: (auto, 1fr, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Pas*], [*Configurație*], [*Operație*],
    [0], [$(q, 1, epsilon, S)$], [expandare],
    [1], [$(q, 1, S_1, a S b S)$], [insucces ($a != c$)],
    [2], [$(r, 1, S_1, a S b S)$], [altă încercare],
    [3], [$(q, 1, S_2, a S)$], [insucces ($a != c$)],
    [4], [$(r, 1, S_2, a S)$], [altă încercare],
    [5], [$(q, 1, S_3, c)$], [avans (citim $c$)],
    [6], [$(q, 2, S_3 c, epsilon)$], [insucces ($beta = epsilon$ dar $i = 2 != 3$)],
    [7], [$(r, 2, S_3 c, epsilon)$], [revenire],
    [8], [$(r, 1, S_3, c)$], [altă încercare (dar $S_3$ e ultima)],
    [9], [$(e, 1, epsilon, S)$], [*EȘEC*],
  )

  *Rezultat:* $c b in.not L(G)$
]

== Complexitatea și Limitări

#greseala[
  *Probleme ale analizei cu reveniri:*

  1. *Complexitate exponențială* în cazul cel mai rău
  2. *Recursivitate la stânga* cauzează buclă infinită:
     $A -> A alpha | beta$ va încerca mereu $A -> A alpha -> A alpha alpha -> ...$
  3. *Ineficiență* pentru gramatici mari
]

#truc[
  Pentru a evita problemele:
  1. Eliminați recursivitatea la stânga înainte de analiză
  2. Folosiți analiză *predictivă* (LL) când e posibil
  3. Factorizați la stânga pentru a reduce backtracking-ul
]

== Exerciții Rezolvate

#exercitiu(1)[
  Fie gramatica:
  - $S -> + S S$
  - $S -> - S S$
  - $S -> a$

  Verificați dacă $+ a - a a in L(G)$ folosind analizorul descendent cu reveniri.
]

#rezolvare[
  Notăm producțiile: $S_1: S -> + S S$, $S_2: S -> - S S$, $S_3: S -> a$

  #table(
    columns: (auto, 1fr, auto),
    stroke: 0.5pt,
    [*Pas*], [*Configurație*], [*Operație*],
    [0], [$(q, 1, epsilon, S)$], [expandare],
    [1], [$(q, 1, S_1, + S S)$], [avans],
    [2], [$(q, 2, S_1 +, S S)$], [expandare],
    [3], [$(q, 2, S_1 + S_1, + S S S)$], [insucces ($+ != a$)],
    [4], [$(r, 2, S_1 + S_1, + S S S)$], [altă încercare],
    [5], [$(q, 2, S_1 + S_2, - S S S)$], [insucces ($- != a$)],
    [6], [$(r, 2, S_1 + S_2, - S S S)$], [altă încercare],
    [7], [$(q, 2, S_1 + S_3, a S)$], [avans],
    [8], [$(q, 3, S_1 + S_3 a, S)$], [expandare],
    [9], [$(q, 3, S_1 + S_3 a S_1, + S S)$], [insucces ($+ != -$)],
    [10], [$(r, 3, S_1 + S_3 a S_1, + S S)$], [altă încercare],
    [11], [$(q, 3, S_1 + S_3 a S_2, - S S)$], [avans],
    [12], [$(q, 4, S_1 + S_3 a S_2 -, S S)$], [expandare],
    [13], [$(q, 4, S_1 + S_3 a S_2 - S_3, a S)$], [avans],
    [14], [$(q, 5, S_1 + S_3 a S_2 - S_3 a, S)$], [expandare],
    [15], [$(q, 5, S_1 + S_3 a S_2 - S_3 a S_3, a)$], [avans],
    [16], [$(q, 6, S_1 + S_3 a S_2 - S_3 a S_3 a, epsilon)$], [*SUCCES*],
  )

  *Rezultat:* $+ a - a a in L(G)$

  *Derivarea:* $S => + S S => + a S => + a - S S => + a - a S => + a - a a$
]

#pagebreak()
