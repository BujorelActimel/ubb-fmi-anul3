// ============================================================================
// CAPITOLUL 2: AUTOMATE FINITE
// ============================================================================

#import "../lib/template.typ": *

= Automate Finite

== Automat Finit Determinist (DFA)

#definitie(title: "Automat Finit Determinist")[
  Un *automat finit determinist* (DFA) este un cvintuplu $M = (Q, Sigma, delta, q_0, F)$ unde:

  - $Q$ = mulțimea finită, nevidă de *stări*
  - $Sigma$ = *alfabetul* de intrare (mulțime finită de simboluri)
  - $delta: Q times Sigma -> Q$ = *funcția de tranziție*
  - $q_0 in Q$ = *starea inițială*
  - $F subset.eq Q$ = mulțimea *stărilor finale* (de acceptare)
]

#truc[
  *Determinist* înseamnă că pentru fiecare stare $q$ și simbol $a$, există *exact o* stare următoare $delta(q, a)$.
]

=== Reprezentarea grafică

Un DFA poate fi reprezentat ca un *graf orientat* unde:
- *Nodurile* sunt stările
- *Arcele* sunt tranzițiile, etichetate cu simboluri
- Starea inițială are o săgeată care intră din "nicăieri"
- Stările finale sunt marcate cu cerc dublu

#exemplu(title: "DFA pentru limbajul cuvintelor care conțin 'ab'")[
  $M = ({q_0, q_1, q_2}, {a, b}, delta, q_0, {q_2})$

  Tranzițiile:
  - $delta(q_0, a) = q_1$, $delta(q_0, b) = q_0$
  - $delta(q_1, a) = q_1$, $delta(q_1, b) = q_2$
  - $delta(q_2, a) = q_2$, $delta(q_2, b) = q_2$

  Interpretare:
  - $q_0$: nu am văzut nimic relevant
  - $q_1$: am văzut 'a', aștept 'b'
  - $q_2$: am găsit 'ab' (stare finală)
]

=== Funcția de tranziție extinsă

#definitie(title: "Funcția de tranziție extinsă")[
  Funcția $hat(delta): Q times Sigma^* -> Q$ extinde $delta$ la cuvinte:

  - $hat(delta)(q, epsilon) = q$
  - $hat(delta)(q, w a) = delta(hat(delta)(q, w), a)$ pentru $w in Sigma^*$, $a in Sigma$
]

#definitie(title: "Limbajul acceptat")[
  *Limbajul acceptat* de un DFA $M$ este:

  $L(M) = {w in Sigma^* | hat(delta)(q_0, w) in F}$

  Adică, mulțimea cuvintelor pentru care automatul, pornind din starea inițială, ajunge într-o stare finală.
]

== Automat Finit Nedeterminist (NFA)

#definitie(title: "Automat Finit Nedeterminist")[
  Un *automat finit nedeterminist* (NFA) este un cvintuplu $M = (Q, Sigma, delta, q_0, F)$ unde:

  - $Q, Sigma, q_0, F$ - ca la DFA
  - $delta: Q times Sigma -> cal(P)(Q)$ = funcția de tranziție care returnează o *mulțime* de stări

  Diferența: pentru o stare și un simbol, pot exista *zero, una sau mai multe* stări următoare.
]

#atentie[
  *Diferența cheie DFA vs NFA:*
  - DFA: $delta(q, a) in Q$ (exact o stare)
  - NFA: $delta(q, a) subset.eq Q$ (mulțime de stări, posibil vidă)
]

=== NFA cu $epsilon$-tranziții ($epsilon$-NFA)

#definitie(title: "Epsilon-NFA")[
  Un *$epsilon$-NFA* permite tranziții pe cuvântul vid $epsilon$.

  $delta: Q times (Sigma union {epsilon}) -> cal(P)(Q)$

  $epsilon$-tranzițiile permit schimbarea stării *fără a consuma* niciun simbol de intrare.
]

#definitie(title: "Epsilon-închiderea")[
  *$epsilon$-închiderea* unei stări $q$, notată $"ECLOSE"(q)$, este mulțimea stărilor accesibile din $q$ folosind doar $epsilon$-tranziții (inclusiv $q$ însăși).
]

== Echivalența DFA - NFA

#teorema(title: "Echivalența DFA-NFA")[
  Pentru orice NFA $M$ există un DFA $M'$ astfel încât $L(M) = L(M')$.

  Cu alte cuvinte, DFA și NFA au aceeași putere expresivă - acceptă exact *limbajele regulare*.
]

=== Algoritmul Subset Construction (NFA → DFA)

#algoritm(title: "Conversie NFA → DFA")[
  *Input:* NFA $N = (Q_N, Sigma, delta_N, q_0, F_N)$

  *Output:* DFA $D = (Q_D, Sigma, delta_D, s_0, F_D)$

  *Algoritm:*
  1. $s_0 = "ECLOSE"(q_0)$ (starea inițială a DFA)
  2. Pentru fiecare stare $S in Q_D$ și simbol $a in Sigma$:
     - $delta_D(S, a) = union.big_(q in S) "ECLOSE"(delta_N(q, a))$
  3. $F_D = {S in Q_D | S inter F_N != emptyset}$
]

#exemplu(title: "Conversie NFA → DFA")[
  NFA cu $Q = {q_0, q_1, q_2}$, stare inițială $q_0$, stare finală $q_2$:
  - $delta(q_0, a) = {q_0, q_1}$
  - $delta(q_0, b) = {q_0}$
  - $delta(q_1, b) = {q_2}$

  Construcția DFA:
  - Stare inițială: ${q_0}$
  - Din ${q_0}$ pe $a$: ${q_0, q_1}$
  - Din ${q_0}$ pe $b$: ${q_0}$
  - Din ${q_0, q_1}$ pe $a$: ${q_0, q_1}$
  - Din ${q_0, q_1}$ pe $b$: ${q_0, q_2}$ (stare finală!)
  - ...
]

== Minimizarea DFA

#teorema(title: "Unicitatea DFA minim")[
  Pentru orice limbaj regular $L$ există un *unic* DFA cu număr minim de stări care acceptă $L$ (unic până la redenumirea stărilor).
]

=== Algoritmul de minimizare

#algoritm(title: "Minimizarea DFA")[
  *Pasul 1:* Eliminăm stările inaccesibile (care nu pot fi atinse din $q_0$)

  *Pasul 2:* Construim partiția stărilor:
  - Inițial: ${F, Q - F}$ (finale vs. non-finale)
  - Rafinare: două stări $p, q$ sunt în aceeași clasă dacă pentru orice $a in Sigma$, $delta(p, a)$ și $delta(q, a)$ sunt în aceeași clasă
  - Repetăm până partiția nu se mai schimbă

  *Pasul 3:* Fiecare clasă de echivalență devine o stare în DFA minim
]

#truc[
  *Pentru examen:* Când vi se cere un AF cu număr minim de stări pentru un limbaj simplu, încercați să identificați ce "informație" trebuie să rețină automatul.

  Exemplu: Pentru $a^*$, automatul trebuie să rețină doar "am văzut doar $a$-uri" → 2 stări (acceptare + eroare).
]

== Exerciții Rezolvate

#exercitiu(1)[
  Construiți un DFA cu 2 stări care acceptă limbajul $L = a^*$ (zero sau mai multe $a$).
]

#rezolvare[
  $M = ({q_0, q_1}, {a, b}, delta, q_0, {q_0})$

  Tranziții:
  - $delta(q_0, a) = q_0$ (rămânem în starea de acceptare)
  - $delta(q_0, b) = q_1$ (am văzut $b$, nu mai acceptăm)
  - $delta(q_1, a) = q_1$ (starea de eroare)
  - $delta(q_1, b) = q_1$

  Interpretare:
  - $q_0$: stare de acceptare (am văzut doar $a$-uri)
  - $q_1$: stare de eroare (am văzut cel puțin un $b$)
]

#exercitiu(2)[
  Fie automatul cu:
  - $Q = {q_0, q_1}$
  - $Sigma = {a, b}$
  - $delta(q_0, a) = q_1$, $delta(q_0, b) = q_0$
  - $delta(q_1, a) = q_0$, $delta(q_1, b) = q_1$
  - Stare inițială: $q_0$, Stări finale: ${q_1}$

  Ce limbaj acceptă acest automat?
]

#rezolvare[
  Analizăm:
  - $q_0$: număr par de $a$
  - $q_1$: număr impar de $a$

  Automatul acceptă în $q_1$, deci acceptă cuvintele cu *număr impar de $a$*.

  $L(M) = {w in {a, b}^* | |w|_a "este impar"}$

  unde $|w|_a$ = numărul de apariții ale lui $a$ în $w$.
]

#exercitiu(3)[
  Construiți un NFA pentru limbajul cuvintelor care se termină în "ab".
]

#rezolvare[
  $M = ({q_0, q_1, q_2}, {a, b}, delta, q_0, {q_2})$

  Tranziții NFA:
  - $delta(q_0, a) = {q_0, q_1}$ (ghicim dacă e ultimul 'a')
  - $delta(q_0, b) = {q_0}$
  - $delta(q_1, b) = {q_2}$

  Stări:
  - $q_0$: încă nu am "ghicit" sfârșitul
  - $q_1$: am văzut 'a', sper că urmează 'b' final
  - $q_2$: am găsit "ab" la final (acceptare)
]

== Proprietăți ale Limbajelor Regulare

#teorema(title: "Închiderea limbajelor regulare")[
  Limbajele regulare sunt *închise* la:
  - *Reuniune*: $L_1, L_2$ regulare $=>$ $L_1 union L_2$ regular
  - *Intersecție*: $L_1, L_2$ regulare $=>$ $L_1 inter L_2$ regular
  - *Complementare*: $L$ regular $=>$ $overline(L)$ regular
  - *Concatenare*: $L_1, L_2$ regulare $=>$ $L_1 L_2$ regular
  - *Stea Kleene*: $L$ regular $=>$ $L^*$ regular
]

#greseala[
  *Atenție:* Intersecția a două limbaje regulare este regulară, dar intersecția a două limbaje independente de context *NU* este neapărat independentă de context!
]

#pagebreak()
