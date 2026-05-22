%% Problema 4 (Testul 4): Sisteme liniare - metode iterative
% A bloc-tridiagonala N×N, N = n^2 = 200^2 = 40000
% Blocuri: X (n×n tridiag: -4 pe diag, 1 pe off-diag) si I (identitate)
% b = A*ones(N,1)  =>  solutia exacta este x* = ones(N,1)

clear; clc; close all;

n   = 200;
N   = n^2;
tol = 1e-6;
max_iter = 2000;

%% Constructia matricei A (sparse)
fprintf('Construiesc A (%d x %d sparse)...\n', N, N);
t_build = tic;

e   = ones(n, 1);
X   = spdiags([e, -4*e, e], [-1, 0, 1], n, n);   % bloc X
T   = spdiags([e,  0*e, e], [-1, 0, 1], n, n);   % off-diag blocuri I
I_n = speye(n);

% A = diag bloc(X,...,X) + tridiag bloc(I,...,I)
A = kron(I_n, X) + kron(T, I_n);
b = A * ones(N, 1);       % b = suma randurilor; sol exacta: ones(N,1)
x_exact = ones(N, 1);

fprintf('  nnz(A) = %d  (%.1f intrari/rand)  timp: %.2f s\n\n', ...
        nnz(A), nnz(A)/N, toc(t_build));

%% Raza spectrala si omega optim
% Pentru Laplacianul 2D: rho_J = cos(pi/(n+1))
% omega_opt = 2 / (1 + sin(pi/(n+1)))
rho_J     = cos(pi / (n+1));
omega_opt = 2 / (1 + sqrt(1 - rho_J^2));   % = 2/(1+sin(pi/(n+1)))

fprintf('Parametri teoretici:\n');
fprintf('  rho(B_Jacobi)     = %.8f\n', rho_J);
fprintf('  rho(B_GS)         = %.8f  (= rho_J^2)\n', rho_J^2);
fprintf('  omega optim SOR   = %.8f\n', omega_opt);
fprintf('  rho(B_SOR_opt)    = %.8f  (= omega_opt - 1)\n', omega_opt - 1);
fprintf('\nIter. teoretice pana la tol=%.0e:\n', tol);
fprintf('  Jacobi:        ~%d\n', ceil(log(tol) / log(rho_J)));
fprintf('  Gauss-Seidel:  ~%d\n', ceil(log(tol) / log(rho_J^2)));
fprintf('  SOR optim:     ~%d\n\n', ceil(log(tol) / log(omega_opt-1)));

%% Jacobi
fprintf('--- Jacobi (max %d iter) ---\n', max_iter);
t0 = tic;
[x_J, iter_J, res_J] = my_jacobi(A, b, tol, max_iter);
tJ = toc(t0);
err_J = norm(x_J - x_exact) / norm(x_exact);
fprintf('  Iteratii: %d/%d  |  Reziduu: %.2e  |  Eroare: %.2e  |  Timp: %.1f s\n\n', ...
        iter_J, max_iter, res_J(end), err_J, tJ);

%% Gauss-Seidel
fprintf('--- Gauss-Seidel (max %d iter) ---\n', max_iter);
t0 = tic;
[x_GS, iter_GS, res_GS] = my_gauss_seidel(A, b, tol, max_iter);
tGS = toc(t0);
err_GS = norm(x_GS - x_exact) / norm(x_exact);
fprintf('  Iteratii: %d/%d  |  Reziduu: %.2e  |  Eroare: %.2e  |  Timp: %.1f s\n\n', ...
        iter_GS, max_iter, res_GS(end), err_GS, tGS);

%% SOR cu omega optim
fprintf('--- SOR (omega=%.5f, max %d iter) ---\n', omega_opt, max_iter);
t0 = tic;
[x_SOR, iter_SOR, res_SOR] = my_sor(A, b, omega_opt, tol, max_iter);
tSOR = toc(t0);
err_SOR = norm(x_SOR - x_exact) / norm(x_exact);
fprintf('  Iteratii: %d/%d  |  Reziduu: %.2e  |  Eroare: %.2e  |  Timp: %.1f s\n\n', ...
        iter_SOR, max_iter, res_SOR(end), err_SOR, tSOR);

%% Rezumat
fprintf('=== REZUMAT ===\n');
fprintf('%-15s %8s %12s %12s %10s\n', 'Metoda', 'Iter', 'Reziduu', 'Eroare', 'Timp(s)');
fprintf('%-15s %8d %12.2e %12.2e %10.1f\n', 'Jacobi',       iter_J,   res_J(end),   err_J,   tJ);
fprintf('%-15s %8d %12.2e %12.2e %10.1f\n', 'Gauss-Seidel', iter_GS,  res_GS(end),  err_GS,  tGS);
fprintf('%-15s %8d %12.2e %12.2e %10.1f\n', 'SOR',          iter_SOR, res_SOR(end), err_SOR, tSOR);

%% Grafic convergenta
figure('Name','Convergenta','Position',[100 100 900 500]);
semilogy(1:length(res_J),   res_J,   'b-', 'LineWidth', 1.5); hold on;
semilogy(1:length(res_GS),  res_GS,  'r-', 'LineWidth', 1.5);
semilogy(1:length(res_SOR), res_SOR, 'g-', 'LineWidth', 2.0);
yline(tol, 'k--', 'LineWidth', 1);
xlabel('Iteratie');
ylabel('||b - Ax^{(k)}|| / ||b||');
title(sprintf('Convergenta metodelor iterative (n=%d, N=%d)', n, N));
legend(sprintf('Jacobi (%d iter)', iter_J), ...
       sprintf('Gauss-Seidel (%d iter)', iter_GS), ...
       sprintf('SOR \\omega=%.4f (%d iter)', omega_opt, iter_SOR), ...
       sprintf('tol = %.0e', tol), ...
       'Location', 'SouthWest');
grid on;

print('-dpng', 'problema4_convergenta.png');
fprintf('\nGrafic salvat: problema4_convergenta.png\n');
close all;
