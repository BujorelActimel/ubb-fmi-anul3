# Documentatie tema

benchmark script: benchmaprk.py
rezultate benchmark: benchmark_results.md

## Varianta 0 - secvential
Parcurg primele `min(a.len, b.len)` cifre ale numerelor a si b in paralel, fac suma (cu tot cu carry), setez
cifra rezultarului ca `suma % 10`, iar carry ca `suma / 10`. La final acopar cazul in care carry este 1, in
care se adauga un 1 la cea mai semnificativa cifra(ultima din `digits`)

## Varianta 1 - com. standard
Impart numerele a si b in chunkuri inegale (primele `remainder` chunkuri au o cifra in plus). 
Procesul master trimite la toti workerii lungimile lui a si b, cate cifre va calcula, si bufferul in sine.
Se face calculul secvential local, iar carryul se trimite la urmatorul worker. Aceast transfer de carry este
blocking. La final, procesul master primeste toate rezultatele, iar in cazul in care final avem carry, mai adaugam
un 1 la cifra cea mai semnificativa.

## Varianta 1.1 - optimizare: calcul speculativ
O optimizare pentru implementarea de mai sus este ca fiecare worker sa inceapa calculul local speculativ, sperand
sa primeasca carry 0 de la vecin. In cazul in care totusi primeste carry 1 de la vecin, recalculeaza si trimite
la master, dar daca primeste carry 0, workerul a calculat deja si poate trimite deja rezultatul.

## varianta 2 - scatter/gather
Se aduc numerele la acelasi numar de cifre (padding) pentru a se putea face scatter egal la toate procesele, se calculeaza
si se transmite carry-ul la fel ca in varianta 1, iar la final se face gather la rezultate.
