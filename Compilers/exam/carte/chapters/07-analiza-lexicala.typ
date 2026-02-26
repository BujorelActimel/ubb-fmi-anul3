// ============================================================================
// CAPITOLUL 7: ANALIZA LEXICALĂ
// ============================================================================

#import "../lib/template.typ": *

= Analiza Lexicală

#atentie[
  *Acest capitol NU apare la examenul scris!*

  Este inclus doar pentru înțelegerea generală a procesului de compilare.
  Flex/Lex nu se cer la examen.
]

== Rolul Analizorului Lexical

#definitie(title: "Analizor Lexical (Scanner/Lexer)")[
  *Analizorul lexical* este prima fază a unui compilator. El:
  - Citește caracterele din codul sursă
  - Grupează caracterele în *lexeme* (unități lexicale)
  - Produce o secvență de *tokeni* pentru analizorul sintactic
  - Elimină spațiile albe și comentariile
  - Raportează erorile lexicale
]

== Concepte de Bază

#definitie(title: "Token, Lexemă, Pattern")[
  - *Token* = categorie de unități lexicale (ex: IDENTIFIER, NUMBER, IF)
  - *Lexemă* = secvența concretă de caractere (ex: "count", "42", "if")
  - *Pattern* = regula care descrie lexemele unui token (expresie regulară)
]

#exemplu[
  În instrucțiunea `if (count > 10) x = 5;`

  #table(
    columns: (auto, auto, auto),
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
    [*Lexemă*], [*Token*], [*Pattern*],
    [`if`], [IF], [`if`],
    [`(`], [LPAREN], [`(`],
    [`count`], [IDENTIFIER], [`[a-zA-Z_][a-zA-Z0-9_]*`],
    [`>`], [GT], [`>`],
    [`10`], [NUMBER], [`[0-9]+`],
    [`)`], [RPAREN], [`)`],
    [`x`], [IDENTIFIER], [`[a-zA-Z_][a-zA-Z0-9_]*`],
    [`=`], [ASSIGN], [`=`],
    [`5`], [NUMBER], [`[0-9]+`],
    [`;`], [SEMICOLON], [`;`],
  )
]

== Structura unui Fișier Flex (.l)

```
%{
/* Declarații C (include, variabile globale) */
#include <stdio.h>
%}

/* Definiții Flex (macros) */
DIGIT    [0-9]
LETTER   [a-zA-Z]

%%
/* Reguli: pattern { acțiune } */

{DIGIT}+        { printf("NUMBER: %s\n", yytext); }
{LETTER}+       { printf("WORD: %s\n", yytext); }
[ \t\n]         { /* ignoră spații */ }
.               { printf("UNKNOWN: %s\n", yytext); }

%%
/* Cod C suplimentar */
int main() {
    yylex();
    return 0;
}
```

== Variabile și Funcții Flex

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
  [*Nume*], [*Descriere*],
  [`yytext`], [Pointer la lexema curentă (șir de caractere)],
  [`yyleng`], [Lungimea lexemei curente],
  [`yylval`], [Valoarea semantică a tokenului (pentru Bison)],
  [`yylex()`], [Funcția principală - returnează următorul token],
  [`yyin`], [Fișierul de intrare (implicit stdin)],
)

== Expresii Regulate în Flex

#table(
  columns: (auto, 1fr, auto),
  stroke: 0.5pt,
  fill: (x, y) => if y == 0 { rgb("#e3f2fd") } else { white },
  [*Pattern*], [*Semnificație*], [*Exemplu*],
  [`x`], [Caracterul x], [`a` potrivește "a"],
  [`.`], [Orice caracter (nu newline)], [`.` potrivește "x"],
  [`[xyz]`], [Unul din x, y, z], [`[abc]` potrivește "a"],
  [`[^xyz]`], [Orice în afară de x, y, z], [`[^0-9]` potrivește "a"],
  [`[a-z]`], [Interval de caractere], [`[a-z]` potrivește "m"],
  [`r*`], [Zero sau mai multe r], [`a*` potrivește "aaa"],
  [`r+`], [Una sau mai multe r], [`a+` potrivește "aaa"],
  [`r?`], [Zero sau una r], [`a?` potrivește "" sau "a"],
  [`r{n}`], [Exact n repetări], [`a{3}` potrivește "aaa"],
  [`r{n,m}`], [Între n și m repetări], [`a{2,4}` potrivește "aa"],
  [`r1r2`], [Concatenare], [`ab` potrivește "ab"],
  [`r1|r2`], [Alternare], [`a|b` potrivește "a" sau "b"],
  [`(r)`], [Grupare], [`(ab)+` potrivește "abab"],
  [`"..."`], [Șir literal], [`"if"` potrivește "if"],
)

== Legătura Flex-Bison

Analizorul lexical (Flex) produce tokeni care sunt consumați de analizorul sintactic (Bison):

```c
// În fișierul .l (Flex)
%{
#include "parser.tab.h"  // Header generat de Bison
%}

%%
"if"        { return IF; }
"else"      { return ELSE; }
[0-9]+      { yylval.num = atoi(yytext); return NUMBER; }
[a-z]+      { strcpy(yylval.str, yytext); return IDENTIFIER; }
```

#truc[
  Deși Flex/Lex nu apare la examen, înțelegerea conceptelor ajută la:
  - Identificarea elementelor lexicale într-un program
  - Înțelegerea cum se tokenizează intrarea pentru analiza sintactică
]

#pagebreak()
