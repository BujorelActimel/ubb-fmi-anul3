# Documentatie tema 4

## Rezultate

Sequential: 0.000382 seconds

Parallel:

| Configuration | Time (s) | Speed_diff | Valid | T_seq/T_par |
|---------------|----------|------------|-------|-------------|
| p= 4, p_r=1, p_w= 3 | 0.000643 | -0.000261 | OK | 0.594 |
| p= 4, p_r=2, p_w= 2 | 0.000516 | -0.000134 | OK | 0.740 |
| p= 8, p_r=1, p_w= 7 | 0.000667 | -0.000285 | OK | 0.573 |
| p= 8, p_r=2, p_w= 6 | 0.000649 | -0.000267 | OK | 0.588 |
| p=16, p_r=1, p_w=15 | 0.000906 | -0.000524 | OK | 0.421 |
| p=16, p_r=2, p_w=14 | 0.001908 | -0.001526 | OK | 0.200 |

## Implementare

La implementarea secventiala(`sequential.c`), se creeaza o lista inlantuita, se
citeste din fiecare fisier pe rand linie cu linie, se cauta id-ul curent in lista,
daca exista se cumuleaza notele, daca nu exista se creeaza un nod nou si se adauga
in lista. La final se scriu rezultatele in `rezultate.txt`.

La implemenarea paralela(`parallel.c`), se creeaza un ThreadSafeList de data asta, care
este un wrapper peste lista folosita la implementarea secventiala care are si un mutex.
Pe langa lista se mai creeaza si un queue. Se imparte numarul de fisiere la readeri, iar fiecare
reader citeste linie cu linie din fisierele sale si le adauga in queue. Workerii, iau din queue
elemente, si le adauga in lista. Dupa ce isi termina executia toti readerii, vor seta variabila
`readers_done` la true, iar workerii termina executia atunci cand queue-ul ramane gol si `readers_done`
este true.

## Analysis

La marimea data-setului de 200 de elevi si (80-200 note per proiect) overhead-ul
crearii thread-urilor este mai mare decat beneficiile aduse de paralelism si vedem
concret ca varianta secventiala este, in cazul asta, intre 2-5x mai rapida decat cea
paralela.
