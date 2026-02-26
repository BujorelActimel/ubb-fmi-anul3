// ============================================================================
// CAPITOLUL 6: AUTOMATE PUSHDOWN (APD)
// ============================================================================

#import "../lib/template.typ": *

= Automate Pushdown (APD)

== Definiție

#definitie(title: "Automat Pushdown")[
  Un *automat pushdown* (APD) este un septuplu $M = (Q, Sigma, Gamma, delta, q_0, Z_0, F)$ unde:

  - $Q$ = mulțimea finită de *stări*
  - $Sigma$ = *alfabetul de intrare*
  - $Gamma$ = *alfabetul stivei*
  - $delta: Q times (Sigma union {epsilon}) times Gamma -> cal(P)(Q times Gamma^*)$ = *funcția de tranziție*
  - $q_0 in Q$ = *starea inițială*
  - $Z_0 in Gamma$ = *simbolul inițial al stivei*
  - $F subset.eq Q$ = mulțimea *stărilor finale*
]

#atentie[
  *Diferența față de AF:*

  APD are o *stivă* (memorie LIFO) care îi permite să "numere" și să "țină minte" - de aceea poate accepta $a^n b^n$.
]

== Configurații și Tranziții

#definitie(title: "Configurație")[
  O *configurație* a unui APD este un triplu $(q, w, gamma)$ unde:
  - $q in Q$ este starea curentă
  - $w in Sigma^*$ este partea necitită din intrare
  - $gamma in Gamma^*$ este conținutul stivei (vârful la stânga)
]

#definitie(title: "Tranziție")[
  O *tranziție* între configurații: $(q, a w, Z gamma) tack.r (p, w, beta gamma)$

  dacă $(p, beta) in delta(q, a, Z)$ unde:
  - $a in Sigma union {epsilon}$
  - $Z in Gamma$ este simbolul din vârful stivei
  - $beta in Gamma^*$ înlocuiește $Z$ în stivă
]

== Moduri de Acceptare

#definitie(title: "Acceptare prin stare finală")[
  $L(M) = {w in Sigma^* | (q_0, w, Z_0) tack.r^* (q_f, epsilon, gamma) "pentru un" q_f in F}$

  Adică: pornim din configurația inițială, consumăm tot cuvântul și ajungem într-o stare finală.
]

#definitie(title: "Acceptare prin stivă vidă")[
  $N(M) = {w in Sigma^* | (q_0, w, Z_0) tack.r^* (q, epsilon, epsilon)}$

  Adică: pornim din configurația inițială, consumăm tot cuvântul și golim stiva.
]

#teorema[
  Cele două moduri de acceptare sunt echivalente: pentru orice APD cu acceptare prin stare finală există un APD echivalent cu acceptare prin stivă vidă și invers.
]

== Echivalența APD ↔ GIC

#teorema(title: "Echivalența APD și GIC")[
  Un limbaj este independent de context dacă și numai dacă este acceptat de un automat pushdown.

  Clasa limbajelor acceptate de APD = Clasa limbajelor generate de GIC
]

=== Conversia GIC → APD

#algoritm(title: "GIC → APD (cu stivă vidă)")[
  *Input:* GIC $G = (V_N, V_T, P, S)$

  *Output:* APD $M = ({q}, V_T, V_N union V_T, delta, q, S, emptyset)$

  *Construcție:*
  - APD cu o singură stare $q$
  - Stiva inițială conține simbolul de start $S$
  - Tranziții:
    - Pentru fiecare $A -> alpha in P$: $(q, alpha) in delta(q, epsilon, A)$
    - Pentru fiecare $a in V_T$: $(q, epsilon) in delta(q, a, a)$
]

== Exemple de APD

#exemplu(title: "APD pentru $L = {a^n b^n | n >= 0}$")[
  $M = ({q_0, q_1, q_2}, {a, b}, {Z_0, A}, delta, q_0, Z_0, {q_2})$

  Tranziții:
  - $delta(q_0, a, Z_0) = {(q_0, A Z_0)}$ - primul $a$: punem $A$ pe stivă
  - $delta(q_0, a, A) = {(q_0, A A)}$ - alt $a$: punem încă un $A$
  - $delta(q_0, b, A) = {(q_1, epsilon)}$ - primul $b$: scoatem un $A$, schimbăm starea
  - $delta(q_1, b, A) = {(q_1, epsilon)}$ - alt $b$: scoatem încă un $A$
  - $delta(q_1, epsilon, Z_0) = {(q_2, Z_0)}$ - am terminat: acceptăm

  Interpretare:
  - $q_0$: citim $a$-uri și le numărăm pe stivă
  - $q_1$: citim $b$-uri și descrețem contorul
  - $q_2$: acceptare (am potrivit toate)
]

#exemplu(title: "APD pentru paranteze corecte")[
  Limbajul parantezelor corecte (Dyck language):
  $L = {w in {(, )}^* | w "este o secvență corectă de paranteze"}$

  *Gramatica:* $S -> (S) S | epsilon$

  *APD:* $M = ({q}, {"(", ")"}, {Z_0, S, "(", ")"}, delta, q, Z_0, emptyset)$

  Tranziții (acceptare prin stivă vidă):
  - $delta(q, epsilon, Z_0) = {(q, S)}$
  - $delta(q, epsilon, S) = {(q, "(S)S"), (q, epsilon)}$ (din producții)
  - $delta(q, "(", "(") = {(q, epsilon)}$ (potrivire terminal)
  - $delta(q, ")", ")") = {(q, epsilon)}$ (potrivire terminal)
]

== Reprezentarea Tabelară a APD (Examen)

#atentie[
  *La examen apar frecvent APD-uri date în formă tabelară!*

  Trebuie să știți să citiți și să verificați dacă un APD este determinist.
]

#definitie(title: "Reprezentarea tabelară")[
  Un APD poate fi reprezentat ca un tabel cu:
  - *Rânduri*: perechi (stare, simbol stivă)
  - *Coloane*: simboluri de intrare ($a, b, ..., epsilon$) + coloana stărilor finale
  - *Celule*: (stare următoare, ce se pune pe stivă)
]

#exemplu(title: "APD în formă tabelară (tip examen)")[
  Fie următorul APD:

  #table(
    columns: (auto, auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 or x <= 1 { rgb("#e3f2fd") } else { white },
    [], [], [*a*], [*b*], [*ε*], [*F*],
    [$q_0$], [Z], [$(q_0, A Z)$], [], [$(q_1, epsilon)$], [0],
    [], [A], [$(q_0, epsilon)$], [], [], [],
    [$q_1$], [Z], [], [], [], [1],
    [], [A], [], [$(q_1, A)$], [], [],
  )

  *Interpretare:*
  - $(q_0, Z, a) -> (q_0, A Z)$: din starea $q_0$, cu $Z$ în vârf și citind $a$, rămânem în $q_0$ și punem $A Z$ pe stivă
  - $(q_0, A, a) -> (q_0, epsilon)$: din $q_0$ cu $A$ în vârf, citind $a$, scoatem $A$ de pe stivă
  - $(q_0, Z, epsilon) -> (q_1, epsilon)$: $epsilon$-tranziție, golim stiva și mergem în $q_1$
  - Coloana $F$: 0 = nu e finală, 1 = stare finală
]

#exercitiu(1)[
  Fie APD-ul de mai sus. Este el determinist? Justificați!
]

#rezolvare[
  Verificăm condiția de determinism: pentru fiecare (stare, simbol stivă), există cel mult o tranziție posibilă.

  - $(q_0, Z)$: avem tranziție pe $a$ și pe $epsilon$ → *conflict!*

  Dacă $delta(q, epsilon, Z) != emptyset$ și $delta(q, a, Z) != emptyset$ simultan, APD-ul *NU este determinist*.

  *Răspuns:* APD-ul nu este determinist deoarece din $(q_0, Z)$ există atât tranziție pe $a$ cât și $epsilon$-tranziție.
]

== APD Determinist (DPDA)

#definitie(title: "APD Determinist")[
  Un APD este *determinist* (DPDA) dacă pentru orice configurație există *cel mult o* tranziție posibilă:

  1. $|delta(q, a, Z)| + |delta(q, epsilon, Z)| <= 1$ pentru orice $q, a, Z$
  2. Dacă $delta(q, epsilon, Z) != emptyset$, atunci $delta(q, a, Z) = emptyset$ pentru orice $a in Sigma$
]

#atentie[
  *Important:* DPDA este mai puțin expresiv decât APD (nedeterminist)!

  Există limbaje independente de context care *nu pot* fi acceptate de niciun DPDA.

  Exemplu: $L = {w w^R | w in {a,b}^*}$ (palindroame de lungime pară) nu poate fi acceptat de DPDA.
]

== Exerciții Rezolvate

#exercitiu(1)[
  Construiți un APD pentru limbajul $L = {a^n b^m | n >= m >= 0}$.
]

#rezolvare[
  Ideea: punem $a$-urile pe stivă, apoi scoatem câte unul pentru fiecare $b$.
  La final, stiva poate avea $a$-uri rămase (deoarece $n >= m$).

  $M = ({q_0, q_1, q_f}, {a, b}, {Z_0, A}, delta, q_0, Z_0, {q_f})$

  Tranziții:
  - $delta(q_0, a, Z_0) = {(q_0, A Z_0)}$
  - $delta(q_0, a, A) = {(q_0, A A)}$
  - $delta(q_0, b, A) = {(q_1, epsilon)}$
  - $delta(q_0, epsilon, Z_0) = {(q_f, Z_0)}$ (acceptăm dacă nu sunt $b$-uri)
  - $delta(q_0, epsilon, A) = {(q_f, A)}$ (acceptăm cu $a$-uri rămase)
  - $delta(q_1, b, A) = {(q_1, epsilon)}$
  - $delta(q_1, epsilon, Z_0) = {(q_f, Z_0)}$
  - $delta(q_1, epsilon, A) = {(q_f, A)}$
]

#exercitiu(2)[
  Construiți un APD pentru gramatica:
  - $S -> a S b | c$
]

#rezolvare[
  Această gramatică generează $L = {a^n c b^n | n >= 0}$.

  *APD cu o stare (metoda generală):*

  $M = ({q}, {a, b, c}, {Z_0, S, a, b, c}, delta, q, Z_0, emptyset)$

  Tranziții:
  - $delta(q, epsilon, Z_0) = {(q, S)}$
  - $delta(q, epsilon, S) = {(q, a S b), (q, c)}$ (din producții)
  - $delta(q, a, a) = {(q, epsilon)}$
  - $delta(q, b, b) = {(q, epsilon)}$
  - $delta(q, c, c) = {(q, epsilon)}$

  *APD optimizat:*

  $M = ({q_0, q_1, q_f}, {a, b, c}, {Z_0, A}, delta, q_0, Z_0, {q_f})$

  - $delta(q_0, a, Z_0) = {(q_0, A Z_0)}$
  - $delta(q_0, a, A) = {(q_0, A A)}$
  - $delta(q_0, c, Z_0) = {(q_f, Z_0)}$ (dacă $n = 0$)
  - $delta(q_0, c, A) = {(q_1, A)}$
  - $delta(q_1, b, A) = {(q_1, epsilon)}$
  - $delta(q_1, epsilon, Z_0) = {(q_f, Z_0)}$
]

#exercitiu(3)[
  Construiți un APD pentru limbajul parantezelor corecte cu două tipuri: $()$ și $[]$.
]

#rezolvare[
  $L = {w in {"(", ")", "[", "]"}^* | w "este corect parantezat"}$

  $M = ({q_0, q_f}, {"(", ")", "[", "]"}, {Z_0, "(", "["}, delta, q_0, Z_0, {q_f})$

  Tranziții:
  - $delta(q_0, "(", Z_0) = {(q_0, "(" Z_0)}$
  - $delta(q_0, "(", "(") = {(q_0, "(" "(")}$
  - $delta(q_0, "(", "[") = {(q_0, "(" "[")}$
  - $delta(q_0, "[", Z_0) = {(q_0, "[" Z_0)}$
  - $delta(q_0, "[", "(") = {(q_0, "[" "(")}$
  - $delta(q_0, "[", "[") = {(q_0, "[" "[")}$
  - $delta(q_0, ")", "(") = {(q_0, epsilon)}$
  - $delta(q_0, "]", "[") = {(q_0, epsilon)}$
  - $delta(q_0, epsilon, Z_0) = {(q_f, Z_0)}$

  Ideea: punem fiecare paranteză deschisă pe stivă și o scoatem când apare perechea ei.
]

#pagebreak()
