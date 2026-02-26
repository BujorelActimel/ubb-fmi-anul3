// ============================================================================
// CAPITOLUL 5: GRAMATICI INDEPENDENTE DE CONTEXT
// ============================================================================

#import "../lib/template.typ": *

= Gramatici Independente de Context (GIC)

== Definiție

#definitie(title: "Gramatică Independentă de Context")[
  O gramatică $G = (V_N, V_T, P, S)$ este *independentă de context* (GIC) dacă toate producțiile au forma:

  $A -> alpha$

  unde $A in V_N$ și $alpha in (V_N union V_T)^*$.

  Adică, în partea stângă a fiecărei producții apare *exact un neterminal*.
]

#atentie[
  *Diferența față de gramatici regulare:*
  - Gramatică regulară: $A -> a B$ sau $A -> a$ sau $A -> epsilon$
  - GIC: $A -> alpha$ unde $alpha$ poate fi *orice* combinație de terminale și neterminale

  Exemplu de GIC care NU e regulară: $S -> a S b | epsilon$ (generează $a^n b^n$)
]

== Arbori de Derivare

#definitie(title: "Arbore de Derivare")[
  Un *arbore de derivare* (sau arbore sintactic) pentru o gramatică $G$ este un arbore ordonat în care:
  - Rădăcina este etichetată cu simbolul de start $S$
  - Fiecare nod intern este etichetat cu un neterminal
  - Fiecare frunză este etichetată cu un terminal sau $epsilon$
  - Dacă un nod $A$ are copiii $X_1, X_2, ..., X_k$, atunci $A -> X_1 X_2 ... X_k in P$
]

#definitie(title: "Derivare stânga și dreapta")[
  - *Derivare stânga* (leftmost): la fiecare pas se înlocuiește neterminalul cel mai din stânga
  - *Derivare dreapta* (rightmost): la fiecare pas se înlocuiește neterminalul cel mai din dreapta

  Un arbore de derivare poate corespunde mai multor derivări, dar derivarea stânga și derivarea dreapta sunt unice pentru un arbore dat.
]

== Ambiguitate

#definitie(title: "Gramatică Ambiguă")[
  O gramatică $G$ este *ambiguă* dacă există cel puțin un cuvânt $w in L(G)$ care are două sau mai multe arbori de derivare distincți.

  Echivalent: $w$ are două derivări stânga distincte.
]

#exemplu(title: "Gramatică ambiguă clasică")[
  $S -> S + S | S * S | a$

  Cuvântul $a + a * a$ are doi arbori de derivare:
  - $(a + a) * a$ - adunarea se face prima
  - $a + (a * a)$ - înmulțirea se face prima

  Aceasta reflectă ambiguitatea în precedența operatorilor.
]

#algoritm(title: "Demonstrarea ambiguității")[
  Pentru a demonstra că o gramatică este ambiguă:

  1. Găsește un cuvânt $w in L(G)$
  2. Arată două derivări stânga *diferite* pentru $w$
  3. Sau desenează doi arbori de derivare *diferiți* pentru $w$
]

#exemplu(title: "Demonstrație: $S -> a S b S | a S | c$ este ambiguă")[
  Considerăm cuvântul $w = a a c b c$.

  *Derivarea 1:*
  $S =>_L a S b S =>_L a a S b S b S =>_L a a c b S b S =>_L a a c b c b S =>_L ...$

  Nu merge așa. Să încercăm altfel.

  Considerăm $w = a c b c$:

  *Derivarea 1 (folosind $S -> a S b S$):*
  $S =>_L a S b S =>_L a c b S =>_L a c b c$

  *Derivarea 2 (folosind $S -> a S$ apoi $S -> c$... ):*
  Hmm, să verificăm dacă putem genera $a c b c$ altfel.

  De fapt, să luăm $w = a a c c$:

  *Derivarea 1:*
  $S =>_L a S =>_L a a S =>_L a a c$ - generează doar $a a c$, nu $a a c c$.

  Să luăm $w = a c b a c$:

  *Derivarea 1:*
  $S => a S b S => a c b S => a c b a S => a c b a c$

  *Derivarea 2:*
  $S => a S => a S b S => a c b S => a c b a S => a c b a c$

  Ambele derivări sunt diferite! Deci gramatica este ambiguă.
]

== Eliminarea Ambiguității

#truc[
  *Tehnici pentru eliminarea ambiguității:*

  1. *Stabilirea precedenței*: pentru expresii cu operatori, creăm neterminale separate pentru fiecare nivel de precedență

  2. *Stabilirea asociativității*: folosim recursie la stânga pentru asociativitate la stânga

  3. *Regula "else" se leagă de cel mai apropiat "if"*: restructurăm gramatica
]

#exemplu(title: "Eliminarea ambiguității pentru expresii aritmetice")[
  *Gramatică ambiguă:*
  $E -> E + E | E * E | (E) | a$

  *Gramatică neambiguă (cu precedență și asociativitate):*
  - $E -> E + T | T$ (adunare, asociativă la stânga, precedență mică)
  - $T -> T * F | F$ (înmulțire, asociativă la stânga, precedență mare)
  - $F -> (E) | a$ (factor: paranteze sau atom)

  Acum $a + a * a$ are o singură derivare: $a + (a * a)$.
]

== Forma Normală Chomsky (CNF)

#definitie(title: "Forma Normală Chomsky")[
  O GIC este în *Forma Normală Chomsky* (CNF) dacă toate producțiile au una din formele:
  - $A -> B C$ (doi neterminali)
  - $A -> a$ (un terminal)
  - $S -> epsilon$ (doar pentru simbolul de start, dacă $epsilon in L(G)$)
]

#teorema[
  Orice GIC care nu generează limbajul vid poate fi transformată într-o gramatică echivalentă în CNF.
]

== Lema de Pompare pentru LIC

#teorema(title: "Lema de Pompare pentru Limbaje Independente de Context")[
  Fie $L$ un limbaj independent de context. Atunci există o constantă $n >= 1$ astfel încât pentru orice cuvânt $w in L$ cu $|w| >= n$, există o descompunere $w = u v x y z$ cu:

  1. $|v x y| <= n$
  2. $|v y| >= 1$ (adică $v != epsilon$ sau $y != epsilon$)
  3. Pentru orice $i >= 0$: $u v^i x y^i z in L$

  Observație: $v$ și $y$ se pompează *simultan* și de același număr de ori.
]

#atentie[
  *Diferența față de lema de pompare pentru limbaje regulare:*

  - Limbaje regulare: $w = x y z$, pompăm doar $y$
  - LIC: $w = u v x y z$, pompăm $v$ și $y$ *împreună*
]

#exemplu(title: "Demonstrație: $L = {a^n b^n c^n | n >= 0}$ nu este LIC")[
  *Demonstrație prin contradicție:*

  1. Presupunem că $L$ este LIC. Fie $p$ constanta din lema de pompare.

  2. Alegem $w = a^p b^p c^p in L$.

  3. Fie $w = u v x y z$ cu $|v x y| <= p$ și $|v y| >= 1$.

  4. Deoarece $|v x y| <= p$, subșirul $v x y$ nu poate conține simultan $a$, $b$ și $c$ (sunt la distanță $>= p$ între ele).

  5. Deci $v y$ conține cel mult două tipuri de simboluri.

  6. Când pompăm ($i = 2$): $u v^2 x y^2 z$ va avea mai multe din cel mult două tipuri de simboluri, dar nu din al treilea.

  7. Deci numărul de $a$, $b$, $c$ nu mai este egal. Contradicție! $square$
]

#exemplu(title: "Aplicare: $L = {w w | w in {a,b}^*}$ nu este LIC")[
  Alegem $w = a^p b^p a^p b^p$.

  Orice descompunere $u v x y z$ cu $|v x y| <= p$ va avea $v x y$ fie în prima jumătate, fie la mijloc.

  Pomparea va strica simetria dintre cele două jumătăți.

  Deci $L$ nu este independent de context.
]

=== Exercițiu Tip Examen: Descompunere Pompabilă (LIC)

#exercitiu(1)[
  Fie gramatica:
  - $S -> 0 A 1$
  - $A -> 0 S$
  - $A -> a$

  și secvența $w = 0 0 0 a 1 1$.

  Puteți să dați o descompunere a secvenței care să poată fi "pompată" conform lemei de pompare pentru LIC?
]

#rezolvare[
  *Pas 1: Verificăm că $w in L(G)$*

  $S => 0 A 1 => 0 dot 0 S dot 1 => 0 0 dot 0 A 1 dot 1 => 0 0 0 a 1 1$ ✓

  *Pas 2: Identificăm limbajul*

  Gramatica generează $L = {0^n a 1^n | n >= 1}$.

  *Pas 3: Găsim descompunere pompabilă*

  Pentru $w = 0 0 0 a 1 1$, căutăm $w = u v x y z$ cu:
  - $|v x y| <= n$ (constanta din lema de pompare)
  - $|v y| >= 1$
  - $u v^i x y^i z in L$ pentru orice $i >= 0$

  *Descompunerea:* $u = 0$, $v = 0$, $x = 0 a 1$, $y = 1$, $z = epsilon$

  Verificare:
  - $|v x y| = |0 dot 0 a 1 dot 1| = 5$
  - $|v y| = |0 1| = 2 >= 1$ ✓
  - $u v^i x y^i z = 0 dot 0^i dot 0 a 1 dot 1^i = 0^(i+2) a 1^(i+1)$

  Pentru $i = 0$: $0^2 a 1^1 = 0 0 a 1 in L$ ✓
  Pentru $i = 1$: $0^3 a 1^2 = 0 0 0 a 1 1 in L$ ✓ (cuvântul original)
  Pentru $i = 2$: $0^4 a 1^3 = 0 0 0 0 a 1 1 1 in L$ ✓

  *Observație importantă:* Pentru ca pomparea să funcționeze, $v$ și $y$ trebuie să conțină același număr de $0$ și $1$ (sau proporțional), pentru a păstra egalitatea $n = n$.

  Aici avem $v = 0$ și $y = 1$, deci pompăm un $0$ și un $1$ simultan, păstrând egalitatea.
]

#truc[
  *Pentru descompuneri pompabile în LIC:*

  1. Identificați structura repetitivă a limbajului
  2. Alegeți $v$ și $y$ astfel încât să "compenseze" unul pe celălalt
  3. Pentru $L = {a^n b^n}$: $v$ conține $a$-uri, $y$ conține $b$-uri
  4. Verificați că $u v^0 x y^0 z$ (cazul $i = 0$) rămâne în limbaj!
]

== Forma Normală Greibach (GNF)

#definitie(title: "Forma Normală Greibach")[
  O GIC este în *Forma Normală Greibach* (GNF) dacă toate producțiile au forma:

  $A -> a alpha$

  unde $a in V_T$ (terminal) și $alpha in V_N^*$ (zero sau mai mulți neterminali).

  Adică: fiecare producție începe cu exact un terminal, urmat de zero sau mai mulți neterminali.
]

#exemplu(title: "Gramatică în GNF")[
  - $S -> a A B$
  - $A -> b S | c$
  - $B -> d$

  Fiecare producție începe cu un terminal.
]

#truc[
  *Utilitatea GNF:*
  - Facilitează construcția APD-urilor
  - Fiecare pas de derivare consumă exact un terminal
  - Numărul de pași în derivare = lungimea cuvântului
]

== Ierarhia Chomsky și Gramatici Dependente de Context

#definitie(title: "Ierarhia Chomsky")[
  Gramaticile se clasifică în 4 tipuri:

  - *Tip 0* (Nerestricționate): $alpha -> beta$, fără restricții
  - *Tip 1* (Dependente de context): $alpha A beta -> alpha gamma beta$ cu $|gamma| >= 1$, sau forma $|alpha| <= |beta|$ (monotonă)
  - *Tip 2* (Independente de context): $A -> alpha$
  - *Tip 3* (Regulare): $A -> a B$ sau $A -> a$ sau $A -> epsilon$

  Incluziune: $cal(L)_3 subset cal(L)_2 subset cal(L)_1 subset cal(L)_0$
]

#definitie(title: "Gramatică Dependentă de Context")[
  O gramatică este *dependentă de context* (tip 1) dacă producțiile au forma:

  $alpha A beta -> alpha gamma beta$

  unde $A in V_N$, $alpha, beta in (V_N union V_T)^*$, și $gamma in (V_N union V_T)^+$ (cel puțin un simbol).

  Interpretare: $A$ se poate înlocui cu $gamma$ doar în *contextul* $alpha ... beta$.
]

#definitie(title: "Gramatică Monotonă")[
  O gramatică este *monotonă* (sau *necrescătoare*) dacă pentru orice producție $alpha -> beta$:

  $|alpha| <= |beta|}$

  Adică, partea dreaptă nu este mai scurtă decât partea stângă.

  *Excepție:* $S -> epsilon$ este permisă doar dacă $S$ nu apare în partea dreaptă a niciunei producții.
]

#teorema[
  Gramaticile dependente de context și gramaticile monotone generează aceeași clasă de limbaje.
]

#exemplu(title: "Exercițiu de examen: clasificare gramatică")[
  Fie gramatica:
  - $S -> a b c$
  - $S -> a S B c$
  - $c B -> B c$
  - $b B -> b b$

  *a) Este independentă de context?*

  *NU.* Producțiile $c B -> B c$ și $b B -> b b$ au *doi* simboluri în partea stângă. În GIC, partea stângă trebuie să fie un singur neterminal.

  *b) Este dependentă de context?*

  *DA.* Verificăm forma $alpha A beta -> alpha gamma beta$:
  - $c B -> B c$: $c B -> c$ nu se potrivește exact, dar avem $|c B| = 2 <= |B c| = 2$ ✓
  - $b B -> b b$: $|b B| = 2 <= |b b| = 2$ ✓

  *c) Este monotonă?*

  *DA.* Pentru fiecare producție, $|"stânga"| <= |"dreapta"|$:
  - $|S| = 1 <= |a b c| = 3$ ✓
  - $|S| = 1 <= |a S B c| = 4$ ✓
  - $|c B| = 2 <= |B c| = 2$ ✓
  - $|b B| = 2 <= |b b| = 2$ ✓
]

#atentie[
  *Cum recunoști tipul gramaticii:*

  1. Verifică dacă *toate* părțile stângi sunt un singur neterminal → GIC (tip 2)
  2. Dacă nu, verifică dacă $|alpha| <= |beta|$ pentru toate producțiile → Monotonă/DC (tip 1)
  3. Verifică dacă producțiile sunt de forma $A -> a B$, $A -> a$, $A -> epsilon$ → Regulară (tip 3)
]

== Algoritmul CYK (Cocke-Younger-Kasami)

#definitie(title: "Algoritmul CYK")[
  Algoritmul CYK verifică dacă un cuvânt $w$ aparține limbajului generat de o GIC $G$ aflată în *Forma Normală Chomsky*.

  Este un algoritm de *programare dinamică* cu complexitate $O(n^3 dot |G|)$.
]

#algoritm(title: "CYK - Construcția tabelului")[
  *Input:* GIC $G$ în CNF, cuvânt $w = a_1 a_2 ... a_n$

  *Output:* $w in L(G)$?

  *Construim tabelul* $T = (t_(i,j))$ unde:

  $t_(i,j) = {A in V_N | A =>^* a_i a_(i+1) ... a_(i+j-1)}$

  *Pași:*
  1. *Baza:* $t_(i,1) = {A in V_N | A -> a_i in P}$

  2. *Recurență:* Pentru $j = 2, 3, ..., n$:

     $t_(i,j) = union.big_(k=1)^(j-1) {A in V_N | A -> B C in P, B in t_(i,k), C in t_(i+k, j-k)}$

  *Rezultat:* $w in L(G)$ dacă și numai dacă $S in t_(1,n)$
]

#exemplu(title: "CYK pentru $w = a b a a b$")[
  Gramatica în CNF:
  - $S -> A A | A S | b$
  - $A -> S A | A S | a$

  Construim tabelul pornind de jos în sus:

  #table(
    columns: (auto, auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    [], [a], [b], [a], [a], [b],
    [j=1], [{A}], [{S}], [{A}], [{A}], [{S}],
    [j=2], [{S,A}], [{A}], [{S,A}], [{S,A}], [],
    [j=3], [{S,A}], [{S,A}], [{S,A}], [], [],
    [j=4], [{S,A}], [{S,A}], [], [], [],
    [j=5], [{S,A}], [], [], [], [],
  )

  $S in t_(1,5)$ $=>$ $a b a a b in L(G)$ $checkmark$
]

#truc[
  *Când se folosește CYK:*
  - Pentru GIC care nu sunt LL(k) sau LR(k)
  - Pentru verificarea apartenenței unui cuvânt la un limbaj
  - Gramatica trebuie să fie în CNF!
]

== Proprietăți de Închidere ale LIC

#teorema(title: "Proprietăți de închidere")[
  Limbajele independente de context sunt închise la:
  - *Reuniune*: $L_1 union L_2$
  - *Concatenare*: $L_1 L_2$
  - *Stea Kleene*: $L^*$

  Limbajele independente de context *NU sunt* închise la:
  - *Intersecție*: $L_1 inter L_2$ poate să nu fie LIC
  - *Complementare*: $overline(L)$ poate să nu fie LIC
]

#exemplu(title: "Intersecția a două LIC nu este neapărat LIC")[
  Fie:
  - $L_1 = {a^n b^n c^m | n, m >= 0}$ (LIC)
  - $L_2 = {a^m b^n c^n | n, m >= 0}$ (LIC)

  Atunci:
  - $L_1 inter L_2 = {a^n b^n c^n | n >= 0}$

  Dar $L_1 inter L_2$ *nu este LIC* (demonstrat mai sus cu lema de pompare).
]

#pagebreak()
