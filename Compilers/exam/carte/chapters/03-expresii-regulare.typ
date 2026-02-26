// ============================================================================
// CAPITOLUL 3: EXPRESII REGULATE
// ============================================================================

#import "../lib/template.typ": *

= Expresii Regulate

== Definiție

#definitie(title: "Expresie Regulată")[
  O *expresie regulară* (ER) peste un alfabet $Sigma$ este definită recursiv:

  *Baza:*
  - $emptyset$ este o ER (reprezintă limbajul vid)
  - $epsilon$ este o ER (reprezintă limbajul ${epsilon}$)
  - Pentru orice $a in Sigma$, $a$ este o ER (reprezintă limbajul ${a}$)

  *Pas recursiv:* Dacă $r$ și $s$ sunt ER, atunci:
  - $(r | s)$ este o ER (*alternare/reuniune*)
  - $(r s)$ este o ER (*concatenare*)
  - $(r)^*$ este o ER (*închidere Kleene*)
]

#definitie(title: "Limbajul unei expresii regulare")[
  Limbajul $L(r)$ asociat unei expresii regulare $r$:
  - $L(emptyset) = emptyset$
  - $L(epsilon) = {epsilon}$
  - $L(a) = {a}$ pentru $a in Sigma$
  - $L(r | s) = L(r) union L(s)$
  - $L(r s) = L(r) dot.c L(s)$
  - $L(r^*) = L(r)^*$
]

== Operatori și Precedență

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt,
  align: (center, center, left),
  fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
  [*Operator*], [*Precedență*], [*Descriere*],
  [$*$], [1 (cea mai mare)], [Închidere Kleene - zero sau mai multe],
  [$+$], [1], [Închidere pozitivă - una sau mai multe ($r^+ = r r^*$)],
  [$?$], [1], [Opțional - zero sau una ($r? = r | epsilon$)],
  [concatenare], [2], [Concatenare (implicit, fără operator)],
  [$|$], [3 (cea mai mică)], [Alternare/reuniune],
)

#exemplu[
  $a b^* | c$ se parsează ca $(a (b^*)) | c$

  - Mai întâi $b^*$ (steaua are precedența cea mai mare)
  - Apoi $a b^*$ (concatenare)
  - În final $a b^* | c$ (alternare)
]

== Proprietăți Algebrice

#teorema(title: "Proprietăți ale expresiilor regulare")[
  Fie $r$, $s$, $t$ expresii regulare. Atunci:

  *Asociativitate:*
  - $(r | s) | t = r | (s | t)$
  - $(r s) t = r (s t)$

  *Comutativitate:*
  - $r | s = s | r$
  - $r s != s r$ (concatenarea NU e comutativă!)

  *Element neutru:*
  - $r | emptyset = r$
  - $r epsilon = epsilon r = r$

  *Element absorbant:*
  - $r emptyset = emptyset r = emptyset$

  *Idempotență:*
  - $r | r = r$

  *Distributivitate:*
  - $r(s | t) = r s | r t$
  - $(r | s)t = r t | s t$
]

== Proprietăți ale Stelei Kleene

#truc[
  *Proprietăți importante pentru True/False la examen:*

  #table(
    columns: (1fr, auto),
    stroke: 0.5pt,
    [*Proprietate*], [*Valoare*],
    [$(r^*)^* = r^*$], [*ADEVĂRAT*],
    [$(r^+)^* = r^*$], [*ADEVĂRAT*],
    [$(r^*)^+ = r^*$], [*ADEVĂRAT*],
    [$r^* r^* = r^*$], [*ADEVĂRAT*],
    [$r^+ = r r^* = r^* r$], [*ADEVĂRAT*],
    [$r^* = r^+ | epsilon$], [*ADEVĂRAT*],
    [$r^* + epsilon = r^*$], [*ADEVĂRAT* (deoarece $epsilon in L(r^*)$)],
    [$(r | s)^* = r^* | s^*$], [*FALS* în general],
    [$(r s)^* = r^* s^*$], [*FALS* în general],
  )
]

#exemplu(title: "Demonstrația că $(r^*)^* = r^*$")[
  Fie $L = L(r)$. Trebuie să arătăm că $(L^*)^* = L^*$.

  "$subset.eq$": $(L^*)^* = union_(i>=0) (L^*)^i$. Fiecare $(L^*)^i$ este o concatenare de elemente din $L^*$, care sunt la rândul lor concatenări de elemente din $L$. Deci $(L^*)^* subset.eq L^*$.

  "$supset.eq$": $L^* = (L^*)^1 subset.eq (L^*)^*$.

  Deci $(L^*)^* = L^*$. $square$
]

== Echivalența ER ↔ AF

#teorema(title: "Teorema Kleene")[
  Un limbaj este *regular* dacă și numai dacă poate fi descris de o expresie regulară.

  Echivalent: Clasa limbajelor acceptate de AF = Clasa limbajelor descrise de ER.
]

=== Algoritmul Thompson (ER → NFA)

#algoritm(title: "Construcția Thompson")[
  Construiește un $epsilon$-NFA pentru o expresie regulară:

  *Cazuri de bază:*

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 10pt,
    [
      *Pentru $epsilon$:*

      $q_0 -->^epsilon q_f$
    ],
    [
      *Pentru $a$:*

      $q_0 -->^a q_f$
    ],
    [
      *Pentru $emptyset$:*

      $q_0 space.quad q_f$ (fără arc)
    ]
  )

  *Cazuri recursive:*

  *Alternare $r | s$:*
  - Creăm o nouă stare inițială și finală
  - $epsilon$-tranziții către automatele pentru $r$ și $s$
  - $epsilon$-tranziții de la stările finale ale lui $r$ și $s$ către noua stare finală

  *Concatenare $r s$:*
  - Starea finală a lui $r$ devine starea inițială a lui $s$ (prin $epsilon$-tranziție)

  *Steaua $r^*$:*
  - Stare nouă inițială cu $epsilon$ la starea inițială a lui $r$ și la starea finală nouă
  - $epsilon$-tranziție de la starea finală a lui $r$ la starea sa inițială (pentru repetare)
  - $epsilon$-tranziție de la starea finală a lui $r$ la starea finală nouă
]

#exemplu(title: "Thompson pentru $(a | b)^* a$")[
  1. Construim NFA pentru $a$: $q_1 ->^a q_2$
  2. Construim NFA pentru $b$: $q_3 ->^b q_4$
  3. Construim NFA pentru $a | b$: nouă stare inițială cu $epsilon$ la $q_1$ și $q_3$
  4. Construim NFA pentru $(a | b)^*$: adăugăm bucla și bypass-ul pentru $epsilon$
  5. Concatenăm cu NFA pentru $a$
]

=== Conversia AF → ER

#algoritm(title: "Metoda eliminării stărilor")[
  1. Adaugă o nouă stare inițială $q_s$ cu $epsilon$-tranziție la vechea stare inițială
  2. Adaugă o nouă stare finală $q_f$ cu $epsilon$-tranziții de la toate stările finale
  3. Elimină stările una câte una (în afară de $q_s$ și $q_f$):
     - Pentru fiecare pereche de stări $(p, r)$ și starea eliminată $q$:
     - Dacă există căi $p ->^a q ->^b r$ și $q ->^c q$ (buclă)
     - Adaugă arcul $p ->^(a c^* b) r$
  4. La final, eticheta arcului $q_s -> q_f$ este expresia regulară
]

== Exerciții Rezolvate

#exercitiu(1)[
  Scrieți o expresie regulară pentru limbajul cuvintelor peste ${a, b}$ care conțin subșirul "ab".
]

#rezolvare[
  Cuvântul trebuie să aibă "ab" undeva în interior:
  - Înainte de "ab" pot fi orice caractere: $(a | b)^*$
  - Trebuie să apară "ab": $a b$
  - După "ab" pot fi orice caractere: $(a | b)^*$

  *Răspuns:* $(a | b)^* a b (a | b)^*$
]

#exercitiu(2)[
  Scrieți o expresie regulară pentru limbajul cuvintelor peste ${a, b}$ care se termină în "ab".
]

#rezolvare[
  - Orice caractere la început: $(a | b)^*$
  - Trebuie să se termine în "ab": $a b$

  *Răspuns:* $(a | b)^* a b$
]

#exercitiu(3)[
  Care este valoarea de adevăr a următoarelor afirmații? (Fie $r$ o expresie regulară oarecare)

  a) $(r^*)^* = r^*$
  b) $(r + epsilon)^* = r^*$
  c) $r^* r^* = r^*$
  d) $r^* + epsilon = r^*$
]

#rezolvare[
  a) *ADEVĂRAT* - $(L^*)^* = L^*$ (demonstrat mai sus)

  b) *ADEVĂRAT* - $L(r + epsilon) = L(r) union {epsilon}$, dar $epsilon in L(r)^*$ oricum, deci $(L(r) union {epsilon})^* = L(r)^*$

  c) *ADEVĂRAT* - $L^* dot.c L^* = L^*$ (concatenarea a zero-sau-mai-multe cu zero-sau-mai-multe dă tot zero-sau-mai-multe)

  d) *ADEVĂRAT* - $L^* union {epsilon} = L^*$ deoarece $epsilon in L^*$ întotdeauna
]

#exercitiu(4)[
  Construiți automatul finit pentru expresia $a b^* + b c^+$.
]

#rezolvare[
  Descompunem expresia:
  - $a b^*$: un $a$ urmat de zero sau mai multe $b$
  - $b c^+$: un $b$ urmat de unul sau mai multe $c$

  *Automatul pentru $a b^*$:*
  - $q_0 ->^a q_1$ (stare finală)
  - $q_1 ->^b q_1$ (buclă pentru $b^*$)

  *Automatul pentru $b c^+$:*
  - $q_0 ->^b q_2$
  - $q_2 ->^c q_3$ (stare finală)
  - $q_3 ->^c q_3$ (buclă pentru mai multe $c$)

  *Combinarea (NFA):*
  - Stare inițială nouă $q_s$
  - $q_s ->^epsilon q_0^1$ (pentru $a b^*$)
  - $q_s ->^epsilon q_0^2$ (pentru $b c^+$)
]

#exercitiu(5)[
  Dată expresia regulară $a a^* b^*$, găsiți gramatica regulară corespunzătoare.
]

#rezolvare[
  Limbajul: cel puțin un $a$, urmat de zero sau mai multe $b$.

  $L = {a^n b^m | n >= 1, m >= 0}$

  *Gramatica regulară (liniară la dreapta):*
  - $S -> a A$
  - $A -> a A | B$
  - $B -> b B | epsilon$

  Sau mai simplu:
  - $S -> a A$
  - $A -> a A | b A | epsilon$
]

#pagebreak()
