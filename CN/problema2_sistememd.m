%% Problema 2: Descompuneri LUP si Cholesky - Matrice Structurata
%%
%% Matricea A (n x n, n par):
%%   - 3 pe diagonala principala
%%   - -1 pe super- si subdiagonala
%%   - 1/2 pe antidiagonala (pozitia (i, n+1-i)), EXCEPTIE i = n/2 si i = n/2+1
%%     (exceptiile coincid exact cu pozitiile unde antidiagonala s-ar suprapune
%%      cu super/subdiagonala, deci structura ramane consistenta)
%%
%% Vectorul b:  [2.5, 1.5, ..., 1.5, 1.0, 1.0, 1.5, ..., 1.5, 2.5]^T
%%   1.5 se repeta de n-4 ori, 1.0 apare de doua ori (pozitiile n/2 si n/2+1)

clear; clc;
format long;

% -----------------------------------------------------------------------
function A = build_A(n)
    A = diag(3*ones(n,1)) + diag(-ones(n-1,1),1) + diag(-ones(n-1,1),-1);
    for i = 1:n
        j = n + 1 - i;
        if i ~= n/2 && i ~= n/2 + 1
            A(i, j) = 0.5;
        end
    end
end

function b = build_b(n)
    b         = 1.5 * ones(n, 1);
    b(1)      = 2.5;
    b(n)      = 2.5;
    b(n/2)    = 1.0;
    b(n/2+1)  = 1.0;
end
% -----------------------------------------------------------------------

fprintf('=======================================================\n');
fprintf('  PROBLEMA 2: LUP si CHOLESKY - Matrice Structurata\n');
fprintf('=======================================================\n\n');

%% =====================================================================
%% (a) Descompuneri LUP si Cholesky pentru n = 12
%% =====================================================================
n = 12;
A = build_A(n);
b = build_b(n);

fprintf('--- (a) Descompuneri pentru n = %d ---\n\n', n);

% Proprietati matrice
ev = eig(A);
fprintf('Simetrica:            %d  (||A - A^T||_F = %.2e)\n', ...
    norm(A - A','fro') < 1e-12, norm(A - A','fro'));
fprintf('Pozitiv definita:     %d  (toate val. proprii > 0)\n', all(ev > 0));
fprintf('Val. proprii:         min = %.6f,  max = %.6f\n', min(ev), max(ev));
fprintf('Numar conditionare:   %.6f\n\n', cond(A));

% --- Descompunere LUP: PA = LU ---
[L, U, P] = lu(A);

fprintf('Descompunere LUP  (PA = LU):\n');
fprintf('  ||PA - LU||_F          = %.2e\n', norm(P*A - L*U, 'fro'));
fprintf('  L inferior triungh.:   ||L - tril(L)||_F = %.2e\n', norm(L - tril(L),'fro'));
fprintf('  U superior triungh.:   ||U - triu(U)||_F = %.2e\n', norm(U - triu(U),'fro'));
fprintf('  Diag(L) (trebuie = 1): ');
fprintf('%.4f ', diag(L)');
fprintf('\n\n');

fprintf('  L (primele 4 x 4):\n');
disp(round(L(1:4,1:4)*1e6)/1e6);
fprintf('  U (primele 4 x 4):\n');
disp(round(U(1:4,1:4)*1e6)/1e6);

% --- Descompunere Cholesky: A = R^T * R ---
[R, flag_chol] = chol(A);

if flag_chol == 0
    fprintf('Descompunere Cholesky  (A = R^T * R):\n');
    fprintf('  ||A - R^T R||_F = %.2e\n', norm(A - R'*R, 'fro'));
    fprintf('  Diag(R) (trebuie > 0): ');
    fprintf('%.4f ', diag(R)');
    fprintf('\n\n');
    fprintf('  R (primele 4 x 4):\n');
    disp(round(R(1:4,1:4)*1e6)/1e6);
else
    fprintf('Cholesky: ESUAT (matricea nu este pozitiv definita, flag=%d)\n\n', flag_chol);
end

%% =====================================================================
%% (b) Rezolvare Ax = b pentru n = 100
%% =====================================================================
n = 100;
A = build_A(n);
b = build_b(n);

fprintf('--- (b) Rezolvare Ax = b,  n = %d ---\n\n', n);

x_ref = A \ b;   % referinta cu backslash (LAPACK)

% Rezolvare LUP: PA = LU
%   Ly = Pb  (substitutie directa)
%   Ux = y   (substitutie inversa)
[L, U, P] = lu(A);
y_lup = L \ (P * b);
x_lup = U \ y_lup;

% Rezolvare Cholesky: A = R'*R
%   R'*y = b  (substitutie directa)
%   R*x  = y  (substitutie inversa)
[R, flag_chol] = chol(A);
if flag_chol == 0
    y_chol = R' \ b;
    x_chol = R  \ y_chol;
else
    x_chol = NaN(n,1);
    fprintf('ATENTIE: Cholesky a esuat pentru n=%d (flag=%d)\n\n', n, flag_chol);
end

fprintf('  %-20s  %-15s  %-15s\n', 'Metoda', '||Ax - b||', '||x - x_ref||');
fprintf('  %-20s  %-15.2e  %-15.2e\n', 'LUP', ...
    norm(A*x_lup - b), norm(x_lup - x_ref));
if flag_chol == 0
    fprintf('  %-20s  %-15.2e  %-15.2e\n', 'Cholesky', ...
        norm(A*x_chol - b), norm(x_chol - x_ref));
end

fprintf('\n  Primele 5 componente ale solutiei:\n');
fprintf('  %-5s  %-15s  %-15s  %-15s\n', 'i', 'x_ref', 'x_LUP', 'x_Chol');
for i = 1:5
    if flag_chol == 0
        fprintf('  %-5d  %-15.8f  %-15.8f  %-15.8f\n', ...
            i, x_ref(i), x_lup(i), x_chol(i));
    else
        fprintf('  %-5d  %-15.8f  %-15.8f\n', i, x_ref(i), x_lup(i));
    end
end

fprintf('\nConcluzii:\n');
fprintf('  - Matricea A este simetrica pozitiv definita (SPD) => Cholesky aplicabila\n');
fprintf('  - Ambele metode produc solutii precise (erori de ordinul eps masina)\n');
fprintf('  - Cholesky: ~n^3/6 flops vs ~2n^3/3 pentru LUP => factor ~4 mai rapid\n');
fprintf('  - Pentru matrice SPD, Cholesky este metoda optima\n');
