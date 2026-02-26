// ============================================================================
// LIMBAJE FORMALE ȘI TEHNICI DE COMPILARE
// Mini-Carte pentru Examen
// ============================================================================

#import "lib/template.typ": *

// Configurare document
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 1 {
      align(right, text(size: 9pt, fill: gray)[_Limbaje Formale și Tehnici de Compilare_])
    }
  },
  footer: context {
    align(center, text(size: 10pt)[#counter(page).display("1")])
  }
)
#set text(font: "New Computer Modern", size: 11pt, lang: "ro")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1.")

// ============================================================================
// PAGINA DE TITLU
// ============================================================================

#align(center)[
  #v(3cm)

  #text(size: 28pt, weight: "bold")[
    Limbaje Formale și\
    Tehnici de Compilare
  ]

  // #v(1cm)

  // #text(size: 16pt)[
  //   Mini-Carte pentru Pregătirea Examenului
  // ]

  #v(2cm)

  #text(size: 12pt, fill: gray)[
    Bazată pe cursurile și seminariile\
    Universității Babeș-Bolyai\
    Facultatea de Matematică și Informatică
  ]

  #v(1cm)

  #text(size: 11pt, fill: gray)[
    Anul universitar 2025-2026
  ]

  #v(4cm)

  #block(
    fill: rgb("#fff3e0"),
    stroke: 1pt + rgb("#f57c00"),
    inset: 15pt,
    radius: 8pt,
    width: 80%,
  )[
    #text(weight: "bold", fill: rgb("#e65100"))[Despre această carte:]

    Acest material conține teoria completă, algoritmi detaliați și exerciții rezolvate pas cu pas pentru examenul de LFTC. Accentul este pus pe analiza sintactică (LL și LR), care apare obligatoriu la examen.
  ]
]

#pagebreak()

// ============================================================================
// CUPRINS
// ============================================================================

#outline(
  title: [Cuprins],
  indent: auto,
  depth: 2
)

#pagebreak()

// ============================================================================
// CAPITOLELE
// ============================================================================

#include "chapters/00-prefata.typ"
#include "chapters/01-notiuni-baza.typ"
#include "chapters/02-automate-finite.typ"
#include "chapters/03-expresii-regulare.typ"
#include "chapters/04-gramatici-regulare.typ"
#include "chapters/05-gic.typ"
#include "chapters/06-apd.typ"
#include "chapters/07-analiza-lexicala.typ"
#include "chapters/08-analiza-descendenta.typ"
#include "chapters/09-analiza-ll.typ"
#include "chapters/10-analiza-lr.typ"
#include "chapters/11-gramatici-atribute.typ"
#include "chapters/12-cod-intermediar.typ"
#include "chapters/13-exercitii-examen.typ"
