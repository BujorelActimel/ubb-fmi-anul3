%% Problema 1: Analiza complexitatii - Metoda Cramer si Eliminare Gaussiana
%% Unitate de masura: flops (operatii flotante: +, -, *, /)
%%
%% CRAMER - regula lui Cramer:
%%   x_i = det(A_i) / det(A),  A_i = A cu coloana i inlocuita de b
%%   Necesita (n+1) determinanti + n impartiri
%%   det(2x2): a11*a22 - a12*a21  =>  2 mult + 1 sub  = 3 flops
%%   det(3x3): 3 minori 2x2 (9) + 3 inmultiri cu elem (3) + 2 combinari = 14 flops
%%
%%   Cramer n=2: 3*3 + 2 = 11 flops
%%   Cramer n=3: 4*14 + 3 = 59 flops
%%   General:    O(n * n!)  -- creste factorial!
%%
%% ELIMINARE GAUSSIANA:
%%   Eliminare inainte (k=1..n-1, i=k+1..n):
%%     - 1 div (multiplicator m_ik = a_ik/a_kk)
%%     - (n-k) perechi (mult+sub) pentru actualizare matrice
%%     - 1 pereche (mult+sub) pentru actualizare rhs
%%   Substitutie inapoi (k=n..1):
%%     - (n-k) mult + (n-k) sub + 1 div = 2(n-k)+1 flops
%%
%%   Gauss n=2:  eliminare=5, substitutie=4  => 9 flops
%%   Gauss n=3:  eliminare=19, substitutie=9 => 28 flops
%%   General:    ~(2/3)n^3 + O(n^2)  -- creste cubic

clear; clc;
format long;

fprintf('=======================================================\n');
fprintf('  ANALIZA COMPLEXITATE: CRAMER vs ELIMINARE GAUSSIANA\n');
fprintf('=======================================================\n\n');

%% Sisteme de test cu solutie cunoscuta
% n=2: sol x = [2; 1]
A2 = [3 1; 1 2];
b2 = [7; 4];
x_ref2 = [2; 1];

% n=3: sol x = [2; 3; -1]
A3 = [2 1 -1; -3 -1 2; -2 1 2];
b3 = [8; -11; -3];
x_ref3 = [2; 3; -1];

%% =====================================================================
%% CRAMER n=2
%% =====================================================================
%  det(A)  = a11*a22 - a12*a21          => 3 flops
%  det(A1) = b1*a22  - a12*b2           => 3 flops   (col 1 <- b)
%  det(A2) = a11*b2  - b1*a21           => 3 flops   (col 2 <- b)
%  x1 = det(A1)/det(A),  x2=det(A2)/detA => 2 flops
%  TOTAL: 11 flops
fc2 = 0;

detA   = A2(1,1)*A2(2,2) - A2(1,2)*A2(2,1);   fc2 = fc2 + 3;
detA1  = b2(1) *A2(2,2)  - A2(1,2)*b2(2);     fc2 = fc2 + 3;
detA2  = A2(1,1)*b2(2)   - b2(1) *A2(2,1);    fc2 = fc2 + 3;
xc2(1) = detA1 / detA;   fc2 = fc2 + 1;
xc2(2) = detA2 / detA;   fc2 = fc2 + 1;

fprintf('--- Cramer n=2 ---\n');
fprintf('  Solutie:  x = [%.6f, %.6f]\n', xc2(1), xc2(2));
fprintf('  Eroare:   %.2e\n', norm(xc2(:) - x_ref2));
fprintf('  Flops:    %d  (teoretic: 11)\n\n', fc2);

%% =====================================================================
%% CRAMER n=3
%% =====================================================================
%  det(3x3) prin dezvoltare dupa prima linie:
%    d = a11*(a22*a33-a23*a32) - a12*(a21*a33-a23*a31) + a13*(a21*a32-a22*a31)
%    3 minori 2x2: 3*3 = 9 flops
%    3 inmultiri cu a1j:         3 flops
%    2 combinari (+/-):          2 flops
%    TOTAL per det: 14 flops
%  4 determinanti + 3 impartiri = 4*14 + 3 = 59 flops
fc3 = 0;

function [d, f] = det3(M)
    % calculeaza det 3x3 si numara flopsurile
    m11 = M(2,2)*M(3,3) - M(2,3)*M(3,2);   % minor (1,1) -- 3 flops
    m12 = M(2,1)*M(3,3) - M(2,3)*M(3,1);   % minor (1,2) -- 3 flops
    m13 = M(2,1)*M(3,2) - M(2,2)*M(3,1);   % minor (1,3) -- 3 flops
    d = M(1,1)*m11 - M(1,2)*m12 + M(1,3)*m13;  % 3 mult + 2 op = 5 flops
    f = 9 + 3 + 2;  % = 14
end

[dA,  f_dA]  = det3(A3);              fc3 = fc3 + f_dA;

A3_1 = A3; A3_1(:,1) = b3;
[dA1, f_dA1] = det3(A3_1);            fc3 = fc3 + f_dA1;

A3_2 = A3; A3_2(:,2) = b3;
[dA2, f_dA2] = det3(A3_2);            fc3 = fc3 + f_dA2;

A3_3 = A3; A3_3(:,3) = b3;
[dA3, f_dA3] = det3(A3_3);            fc3 = fc3 + f_dA3;

xc3(1) = dA1/dA;  fc3 = fc3 + 1;
xc3(2) = dA2/dA;  fc3 = fc3 + 1;
xc3(3) = dA3/dA;  fc3 = fc3 + 1;

fprintf('--- Cramer n=3 ---\n');
fprintf('  Solutie:  x = [%.6f, %.6f, %.6f]\n', xc3(1), xc3(2), xc3(3));
fprintf('  Eroare:   %.2e\n', norm(xc3(:) - x_ref3));
fprintf('  Flops:    %d  (teoretic: 59)\n\n', fc3);

%% =====================================================================
%% ELIMINARE GAUSSIANA n=2
%% =====================================================================
%  k=1: m21=a21/a11 (1 div)
%       a22 -= m21*a12  (2 flops)
%       b2  -= m21*b1   (2 flops)
%  => eliminare: 5 flops
%  Substitutie inapoi:
%       x2 = b2/a22            (1 div)
%       x1 = (b1-a12*x2)/a11   (1 mult + 1 sub + 1 div = 3 flops)
%  => substitutie: 4 flops
%  TOTAL: 9 flops
fg2 = 0;
Ag2 = A2;  bg2 = b2;

% Eliminare
m21 = Ag2(2,1)/Ag2(1,1);              fg2 = fg2 + 1;
Ag2(2,2) = Ag2(2,2) - m21*Ag2(1,2);  fg2 = fg2 + 2;
bg2(2)   = bg2(2)   - m21*bg2(1);    fg2 = fg2 + 2;

% Substitutie inapoi
xg2(2) = bg2(2)/Ag2(2,2);                      fg2 = fg2 + 1;
xg2(1) = (bg2(1) - Ag2(1,2)*xg2(2))/Ag2(1,1); fg2 = fg2 + 3;

fprintf('--- Gauss n=2 ---\n');
fprintf('  Solutie:  x = [%.6f, %.6f]\n', xg2(1), xg2(2));
fprintf('  Eroare:   %.2e\n', norm(xg2(:) - x_ref2));
fprintf('  Flops eliminare:    5  |  substitutie: 4\n');
fprintf('  Flops total:    %d  (teoretic: 9)\n\n', fg2);

%% =====================================================================
%% ELIMINARE GAUSSIANA n=3
%% =====================================================================
%  k=1 (elim col 1 din randurile 2,3):
%    rand 2: 1 div + 2*(2 flops) + 2 flops = 7 flops  [2 el. matrice + 1 rhs]
%    rand 3: la fel = 7 flops
%    subtotal k=1: 14 flops
%  k=2 (elim col 2 din randul 3):
%    rand 3: 1 div + 1*(2 flops) + 2 flops = 5 flops
%    subtotal k=2: 5 flops
%  Eliminare totala: 19 flops
%  Substitutie inapoi:
%    x3 = b3/a33                            => 1 flop
%    x2 = (b2 - a23*x3)/a22                 => 3 flops
%    x1 = (b1 - a12*x2 - a13*x3)/a11       => 5 flops
%    Total: 9 flops
%  TOTAL: 28 flops
fg3 = 0;
Ag3 = A3;  bg3 = b3;

% Eliminare k=1
for i = 2:3
    m = Ag3(i,1)/Ag3(1,1);                        fg3 = fg3 + 1;
    for j = 2:3
        Ag3(i,j) = Ag3(i,j) - m*Ag3(1,j);        fg3 = fg3 + 2;
    end
    bg3(i) = bg3(i) - m*bg3(1);                   fg3 = fg3 + 2;
end
flops_elim1 = fg3;

% Eliminare k=2
m = Ag3(3,2)/Ag3(2,2);                            fg3 = fg3 + 1;
Ag3(3,3) = Ag3(3,3) - m*Ag3(2,3);                fg3 = fg3 + 2;
bg3(3)   = bg3(3)   - m*bg3(2);                   fg3 = fg3 + 2;
flops_elim = fg3;

% Substitutie inapoi
xg3(3) = bg3(3)/Ag3(3,3);                                              fg3 = fg3 + 1;
xg3(2) = (bg3(2) - Ag3(2,3)*xg3(3))/Ag3(2,2);                        fg3 = fg3 + 3;
xg3(1) = (bg3(1) - Ag3(1,2)*xg3(2) - Ag3(1,3)*xg3(3))/Ag3(1,1);    fg3 = fg3 + 5;

fprintf('--- Gauss n=3 ---\n');
fprintf('  Solutie:  x = [%.6f, %.6f, %.6f]\n', xg3(1), xg3(2), xg3(3));
fprintf('  Eroare:   %.2e\n', norm(xg3(:) - x_ref3));
fprintf('  Flops eliminare: %d  |  substitutie: %d\n', flops_elim, fg3-flops_elim);
fprintf('  Flops total:   %d  (teoretic: 28)\n\n', fg3);

%% =====================================================================
%% TABEL COMPARATIV SI COMPLEXITATE GENERALA
%% =====================================================================
fprintf('=======================================================\n');
fprintf('  TABEL COMPARATIV\n');
fprintf('=======================================================\n');
fprintf('%-25s %8s %8s\n', 'Metoda', 'n=2', 'n=3');
fprintf('%-25s %8d %8d\n', 'Cramer',              fc2, fc3);
fprintf('%-25s %8d %8d\n', 'Eliminare Gaussiana', fg2, fg3);
fprintf('\n');

fprintf('Formule generale (flops):\n');
fprintf('  Cramer (cofactori):  (n+1) * T_det(n) + n\n');
fprintf('    T_det(2) = 3,  T_det(3) = 14\n');
fprintf('    Creste FACTORIAL: O(n * n!)\n\n');

fprintf('  Eliminare Gaussiana:\n');
fprintf('    Eliminare:       sum_{k=1}^{n-1} (n-k)*(3+2(n-k))\n');
fprintf('                   = (3/2)n(n-1) + (1/3)(n-1)n(2n-1)\n');
fprintf('                   ~ (2/3)n^3  pentru n mare\n');
fprintf('    Substitutie:     n^2\n');
fprintf('    TOTAL:         ~ (2/3)n^3 + n^2  =>  O(n^3)\n\n');

n_vals = 2:10;
fprintf('  Comparatie asymptotic:\n');
fprintf('  %4s %12s %12s\n', 'n', 'Cramer~n*n!', 'Gauss~(2/3)n^3');
for n = n_vals
    % det(n×n) prin cofactori: T(n) = n*T(n-1) + 2n-1
    T = zeros(1,n);
    T(1) = 0;
    for k = 2:n
        T(k) = k*T(k-1) + 2*k - 1;
    end
    cramer_flops = (n+1)*T(n) + n;
    gauss_flops  = round(2/3*n^3 + n^2);
    fprintf('  %4d %12.0f %12.0f\n', n, cramer_flops, gauss_flops);
end

fprintf('\nConcluzie: pentru n>=4, eliminarea gaussiana este net superioara.\n');
fprintf('La n=10: Cramer ~ %.2e flops vs Gauss ~ %.0f flops\n', ...
    (11*factorial(10)+10), round(2/3*10^3+10^2));
