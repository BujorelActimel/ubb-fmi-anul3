// ============================================================================
// CAPITOLUL 0: PREFAȚĂ ȘI GHID PENTRU EXAMEN
// ============================================================================

#import "../lib/template.typ": *

= Prefață și Ghid pentru Examen

== Despre această carte

Această carte a fost concepută ca un material complet de pregătire pentru examenul de *Limbaje Formale și Tehnici de Compilare (LFTC)*. Conține:

- *Teoria completă* prezentată clar și concis
- *Algoritmi detaliați* cu explicații pas cu pas
- *Exemple rezolvate* din cursuri și seminarii
- *Exerciții tip examen* cu rezolvări complete
- *Trucuri și sfaturi* pentru rezolvarea rapidă
- *Greșeli comune* de evitat

== Structura Examenului (Ianuarie 2026)

#atentie[
  *Durata examenului:* 120 minute

  *Punctaj:* 1 punct din oficiu + 9 puncte din cerințe

  *NU se permite* folosirea niciunei surse de informații!
]

=== Ce apare pe biletul de examen?

#table(
  columns: (auto, 1fr, auto),
  stroke: 0.5pt,
  align: (center, left, center),
  fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
  [*Tip*], [*Descriere*], [*Punctaj*],
  [1], [Teorie "pură": definiții, descrieri formale], [max 2p],
  [2], [Probleme similare exemplelor din curs], [1-2p],
  [3], [Probleme de tipul celor din seminar], [1-2p],
  [4], [Exemple scurte, simple, aplicative], [1p],
  [5], [Probleme true/false, multiple choice], [1p],
  [6], [Probleme similare cu cele din laborator], [1p],
)

=== Ce apare SIGUR la examen

#definitie(title: "Obligatoriu")[
  Fiecare subiect va conține *cel puțin o problemă* (sau mai multe) din partea cu *analiza sintactică*, valorând între *1 și 3 puncte*.

  Aceasta înseamnă:
  - Funcțiile FIRST și FOLLOW
  - Construcția tabelelor LL(1)
  - Construcția colecției canonice LR(0)/LR(1)
  - Construcția tabelelor SLR/LR(1)/LALR
  - Verificarea dacă o secvență aparține limbajului
]

=== Ce NU apare la examen

#truc[
  *Nu se dau la examenul scris:*
  - Lex/Flex și Yacc/Bison (instrumente practice)
  - Nimic cu ASM (cod assembly)
  - Automate Mealy și Moore

  Acestea sunt studiate pentru înțelegere, nu pentru examen!
]

== Cum să folosești această carte

=== Plan de studiu recomandat

*Săptămâna 1:*
- Ziua 1-2: Capitolele 1-2 (Noțiuni de bază, Automate Finite)
- Ziua 3: Capitolul 3 (Expresii Regulate)
- Ziua 4: Capitolul 4 (Gramatici Regulare)
- Ziua 5-6: Capitolele 5-6 (GIC, APD)
- Ziua 7: Recapitulare și exerciții

*Săptămâna 2:*
- Ziua 1: Capitolul 8 (Analiza Descendentă)
- Ziua 2-3: Capitolul 9 (Analiza LL) - *FOARTE IMPORTANT*
- Ziua 4-5: Capitolul 10 (Analiza LR) - *FOARTE IMPORTANT*
- Ziua 6: Capitolele 11-12 (Atribute, Cod Intermediar)
- Ziua 7: Capitolul 13 (Exerciții de examen)

=== Sfaturi pentru examen

#exemplu(title: "Strategia la examen")[
  1. *Citește tot subiectul* înainte să începi
  2. *Începe cu ce știi* - nu pierde timp pe ce nu-ți iese
  3. *Scrie clar și organizat* - punctajul parțial contează
  4. *Verifică-ți răspunsurile* dacă ai timp
  5. *Pentru analiză sintactică*: desenează diagramele de stări clar
]

== Notații folosite în carte

=== Simboluri matematice

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  [*Simbol*], [*Semnificație*],
  [$Sigma$], [Alfabet (mulțime finită de simboluri)],
  [$epsilon$], [Șirul vid (cuvântul de lungime 0)],
  [$Sigma^*$], [Mulțimea tuturor cuvintelor peste $Sigma$ (inclusiv $epsilon$)],
  [$Sigma^+$], [Mulțimea tuturor cuvintelor nevide peste $Sigma$],
  [$|w|$], [Lungimea cuvântului $w$],
  [$L(G)$], [Limbajul generat de gramatica $G$],
  [$L(M)$], [Limbajul acceptat de automatul $M$],
)

=== Notații pentru gramatici

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  [*Notație*], [*Semnificație*],
  [$A -> alpha$], [Producție: $A$ se rescrie în $alpha$],
  [$=>$], [Derivare directă (într-un pas)],
  [$=>^*$], [Derivare în zero sau mai mulți pași],
  [$=>^+$], [Derivare în unul sau mai mulți pași],
  [$V_N$], [Mulțimea neterminalelor],
  [$V_T$], [Mulțimea terminalelor],
)

=== Notații pentru analiză sintactică

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  [*Notație*], [*Semnificație*],
  [$"FIRST"(alpha)$], [Mulțimea terminalelor care pot începe derivări din $alpha$],
  [$"FOLLOW"(A)$], [Mulțimea terminalelor care pot urma după $A$],
  [$[A -> alpha . beta]$], [Element LR(0) - punctul indică poziția curentă],
  [$[A -> alpha . beta, a]$], [Element LR(1) cu lookahead $a$],
  [$"CLOSURE"(I)$], [Închiderea mulțimii de elemente $I$],
  [$"GOTO"(I, X)$], [Tranziția din starea $I$ pe simbolul $X$],
)

== Resurse suplimentare

Pentru aprofundare și verificare, poți folosi:

- *JFLAP* - simulator pentru automate și gramatici (gratuit)
- *regex101.com* - pentru testarea expresiilor regulare
- *Stanford Compilers* (Coursera) - curs video complementar în engleză

#pagebreak()
