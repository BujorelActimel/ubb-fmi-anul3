// ============================================================================
// Template și Macro-uri pentru Mini-Cartea LFTC
// ============================================================================

// Configurare pagină
#let setup-page() = {
  set page(
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
  set text(font: "New Computer Modern", size: 11pt, lang: "ro")
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1.")
}

// ============================================================================
// BOX-URI COLORATE PENTRU DIFERITE TIPURI DE CONȚINUT
// ============================================================================

// Definiție - albastru
#let definitie(title: "Definiție", body) = {
  block(
    fill: rgb("#e3f2fd"),
    stroke: (left: 4pt + rgb("#1976d2")),
    inset: 12pt,
    radius: (right: 4pt),
    width: 100%,
  )[
    #text(weight: "bold", fill: rgb("#1976d2"))[#title]
    #v(4pt)
    #body
  ]
}

// Teoremă - mov
#let teorema(title: "Teoremă", body) = {
  block(
    fill: rgb("#f3e5f5"),
    stroke: (left: 4pt + rgb("#7b1fa2")),
    inset: 12pt,
    radius: (right: 4pt),
    width: 100%,
  )[
    #text(weight: "bold", fill: rgb("#7b1fa2"))[#title]
    #v(4pt)
    #body
  ]
}

// Exemplu - verde
#let exemplu(title: "Exemplu", body) = {
  block(
    fill: rgb("#e8f5e9"),
    stroke: (left: 4pt + rgb("#388e3c")),
    inset: 12pt,
    radius: (right: 4pt),
    width: 100%,
  )[
    #text(weight: "bold", fill: rgb("#388e3c"))[#title]
    #v(4pt)
    #body
  ]
}

// Truc pentru examen - portocaliu
#let truc(body) = {
  block(
    fill: rgb("#fff3e0"),
    stroke: (left: 4pt + rgb("#f57c00")),
    inset: 12pt,
    radius: (right: 4pt),
    width: 100%,
  )[
    #text(weight: "bold", fill: rgb("#f57c00"))[Truc pentru examen]
    #v(4pt)
    #body
  ]
}

// Greșeală comună - roșu
#let greseala(body) = {
  block(
    fill: rgb("#ffebee"),
    stroke: (left: 4pt + rgb("#d32f2f")),
    inset: 12pt,
    radius: (right: 4pt),
    width: 100%,
  )[
    #text(weight: "bold", fill: rgb("#d32f2f"))[Greșeală comună]
    #v(4pt)
    #body
  ]
}

// Algoritm - cyan
#let algoritm(title: "Algoritm", body) = {
  block(
    fill: rgb("#e0f7fa"),
    stroke: (left: 4pt + rgb("#0097a7")),
    inset: 12pt,
    radius: (right: 4pt),
    width: 100%,
  )[
    #text(weight: "bold", fill: rgb("#0097a7"))[#title]
    #v(4pt)
    #body
  ]
}

// Atenție/Important - galben
#let atentie(body) = {
  block(
    fill: rgb("#fffde7"),
    stroke: (left: 4pt + rgb("#fbc02d")),
    inset: 12pt,
    radius: (right: 4pt),
    width: 100%,
  )[
    #text(weight: "bold", fill: rgb("#f9a825"))[Atenție!]
    #v(4pt)
    #body
  ]
}

// Rezolvare pas cu pas - gri
#let rezolvare(body) = {
  block(
    fill: rgb("#fafafa"),
    stroke: 1pt + rgb("#9e9e9e"),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
  )[
    #text(weight: "bold", fill: rgb("#616161"))[Rezolvare]
    #v(4pt)
    #body
  ]
}

// Exercițiu propus
#let exercitiu(nr, body) = {
  block(
    inset: (left: 0pt, top: 8pt, bottom: 8pt),
    width: 100%,
  )[
    #text(weight: "bold")[Exercițiul #nr.] #body
  ]
}

// ============================================================================
// MACRO-URI PENTRU GRAMATICI ȘI AUTOMATE
// ============================================================================

// Producție gramaticală
#let prod(lhs, rhs) = $#lhs arrow.r #rhs$

// Derivare într-un pas
#let deriv(from, to) = $#from arrow.r.double #to$

// Derivare în mai mulți pași
#let derivstar(from, to) = $#from arrow.r.double^* #to$

// Derivare în cel puțin un pas
#let derivplus(from, to) = $#from arrow.r.double^+ #to$

// Simbol pentru șirul vid
#let eps = $epsilon$

// FIRST și FOLLOW
#let First(x) = $"FIRST"(#x)$
#let Follow(x) = $"FOLLOW"(#x)$

// Element LR
#let lritem(lhs, before, after) = $[#lhs arrow.r #before dot.c #after]$

// Element LR(1) cu lookahead
#let lr1item(lhs, before, after, la) = $[#lhs arrow.r #before dot.c #after, #la]$

// Funcții pentru automate
#let Closure(x) = $"CLOSURE"(#x)$
#let Goto(i, x) = $"GOTO"(#i, #x)$

// ============================================================================
// TABELE PENTRU ANALIZĂ SINTACTICĂ
// ============================================================================

// Tabel de tranziții simplu
#let transition-table(headers, ..rows) = {
  table(
    columns: headers.len(),
    stroke: 0.5pt,
    align: center,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    ..headers.map(h => text(weight: "bold")[#h]),
    ..rows.pos().flatten()
  )
}

// ============================================================================
// PENTRU COD INTERMEDIAR
// ============================================================================

// Cvadruplu
#let quad(op, arg1, arg2, result) = $(#op, #arg1, #arg2, #result)$

// Triplu
#let triple(op, arg1, arg2) = $(#op, #arg1, #arg2)$

// ============================================================================
// CONFIGURAȚII PENTRU ANALIZOARE
// ============================================================================

// Configurație analizor descendent
#let config(state, pos, alpha, beta) = $(#state, #pos, #alpha, #beta)$

// Tranziție
#let trans = $tack.r$

// ============================================================================
// STILURI PENTRU COD
// ============================================================================

#let code-block(code) = {
  block(
    fill: rgb("#f5f5f5"),
    stroke: 1pt + rgb("#e0e0e0"),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
  )[
    #set text(font: "Fira Code", size: 10pt)
    #code
  ]
}
