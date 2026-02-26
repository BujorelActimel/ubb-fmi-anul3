// ============================================================================
// CAPITOLUL 11: GRAMATICI CU ATRIBUTE
// ============================================================================

#import "../lib/template.typ": *

= Gramatici cu Atribute

== Concepte de Bază

#definitie(title: "Gramatică cu Atribute")[
  O *gramatică cu atribute* extinde o GIC cu:
  - *Atribute* asociate simbolurilor (terminale și neterminale)
  - *Reguli semantice* care calculează valorile atributelor

  Permite definirea semanticii limbajului în paralel cu sintaxa.
]

#definitie(title: "Tipuri de Atribute")[
  - *Atribute sintetizate* (synthesized): valoarea se calculează din valorile atributelor *copiilor* în arborele de derivare (de jos în sus)

  - *Atribute moștenite* (inherited): valoarea se calculează din valorile atributelor *părintelui* și *fraților* (de sus în jos)
]

#exemplu[
  Pentru expresii aritmetice:
  - `val` = atribut sintetizat (valoarea expresiei)
  - `type` = poate fi moștenit (tipul așteptat) sau sintetizat (tipul calculat)
]

== Gramatici S-atribuite și L-atribuite

#definitie(title: "Gramatică S-atribuită")[
  O gramatică este *S-atribuită* dacă folosește *doar atribute sintetizate*.

  Avantaj: poate fi evaluată în timpul analizei bottom-up (LR).
]

#definitie(title: "Gramatică L-atribuită")[
  O gramatică este *L-atribuită* dacă pentru orice producție $A -> X_1 X_2 ... X_n$:
  - Fiecare atribut moștenit al lui $X_j$ depinde doar de:
    - Atributele moștenite ale lui $A$
    - Atributele (orice tip) ale lui $X_1, ..., X_(j-1)$

  Adică, atributele se calculează de la *stânga la dreapta*.

  Avantaj: poate fi evaluată în timpul analizei top-down (LL).
]

== Exemplu: Calculator de Expresii

#exemplu(title: "Gramatică S-atribuită pentru expresii")[
  Gramatica:
  - $E -> E_1 + T$ #{h(1cm)} `E."val" = E1."val" + T."val"`
  - $E -> T$ #{h(1cm)} `E."val" = T."val"`
  - $T -> T_1 * F$ #{h(1cm)} `T."val" = T1."val" * F."val"`
  - $T -> F$ #{h(1cm)} `T."val" = F."val"`
  - $F -> (E)$ #{h(1cm)} `F."val" = E."val"`
  - $F -> "digit"$ #{h(1cm)} `F."val" = digit.lexval`

  Pentru $3 + 5 * 2$:
  - $F."val" = 3$, $T."val" = 3$, $E_1."val" = 3$
  - $F."val" = 5$, $T_1."val" = 5$
  - $F."val" = 2$
  - $T."val" = 5 * 2 = 10$
  - $E."val" = 3 + 10 = 13$
]

== Schema de Traducere

#definitie(title: "Schemă de Traducere Dirijată de Sintaxă")[
  O *schemă de traducere* (syntax-directed translation scheme) este o GIC cu *acțiuni semantice* intercalate în producții:

  $A -> {"actiune"_1} X {"actiune"_2} Y {"actiune"_3}$

  Acțiunile se execută în ordinea în care sunt întâlnite în derivare.
]

#exemplu(title: "Traducere în notație postfixă")[
  $E -> T R$
  $R -> + T$ `{print('+');}` $R | epsilon$
  $T -> "digit"$ `{print(digit.lexval);}`

  Pentru $3 + 5$: output = `3 5 +`
]

== Evaluarea Atributelor

#algoritm(title: "Evaluarea atributelor sintetizate (bottom-up)")[
  1. Construiește arborele de derivare
  2. Parcurge arborele *postordine* (copiii înainte de părinți)
  3. La fiecare nod, calculează atributele sintetizate din valorile copiilor
]

#algoritm(title: "Evaluarea atributelor L-atribuite (top-down)")[
  1. Parcurge arborele *preordine* (părinți înainte de copii) și *stânga-dreapta*
  2. La fiecare nod:
     - Calculează atributele moștenite ale copiilor (în ordine stânga-dreapta)
     - Apoi vizitează copiii
     - La final calculează atributele sintetizate
]

== Graf de Dependențe

#definitie(title: "Graf de Dependențe")[
  *Graful de dependențe* pentru o gramatică cu atribute arată relațiile de dependență între atribute:
  - Noduri = instanțe de atribute în arborele de derivare
  - Arc $a -> b$ dacă valoarea lui $b$ depinde de valoarea lui $a$

  Graful trebuie să fie *aciclic* pentru ca evaluarea să fie posibilă.
]

== Exemplu: Declarații de Tip

#exemplu(title: "Atribute moștenite pentru tipuri")[
  Gramatica pentru declarații:
  - $D -> T L$
  - $T -> "int"$ | $"float"$
  - $L -> L_1 , "id"$ | $"id"$

  Atribute:
  - `T.type` = sintetizat (tipul declarat)
  - `L.type` = moștenit (tipul de la T)

  Reguli:
  - $D -> T L$: `L.type = T.type`
  - $T -> "int"$: `T.type = integer`
  - $T -> "float"$: `T.type = float`
  - $L -> L_1 , "id"$: `L1.type = L.type; addtype(id.name, L.type)`
  - $L -> "id"$: `addtype(id.name, L.type)`
]

== Implementare în Analizoare

=== În Analizoare Bottom-Up (Yacc/Bison)

```yacc
%union { int val; }
%token <val> NUMBER
%type <val> expr term factor

%%
expr : expr '+' term   { $$ = $1 + $3; }
     | term            { $$ = $1; }
     ;
term : term '*' factor { $$ = $1 * $3; }
     | factor          { $$ = $1; }
     ;
factor : NUMBER        { $$ = $1; }
       | '(' expr ')'  { $$ = $2; }
       ;
```

#truc[
  *În Yacc/Bison:*
  - `$$` = atributul părții stângi (neterminalul redus)
  - `$1, $2, ...` = atributele simbolurilor din partea dreaptă
  - Toate atributele sunt implicit *sintetizate*
]

#atentie[
  *Implementarea în Bison NU apare la examen scris!*

  Dar înțelegerea conceptelor de atribute ajută la problemele cu cod intermediar.
]

#pagebreak()
