function [x, w] = golub_welsch(a_diag, b_off, mu0)
%% Algoritmul Golub-Welsch: noduri si ponderi pentru cuadratura Gauss.
%% Nodurile sunt valorile proprii ale matricei tridiagonale Jacobi,
%% ponderile sunt mu0 * v(1,i)^2, unde v sunt vectorii proprii normati.
%%   a_diag : vectorul diagonal (n elemente)
%%   b_off  : vectorul subdiagonal = sqrt(beta_k), k=1..n-1
%%   mu0    : integrala functiei de pondere (masa totala)
    n = length(a_diag);
    J = diag(a_diag) + diag(b_off, 1) + diag(b_off, -1);
    [V, D] = eig(J);
    [x, idx] = sort(diag(D));
    V = V(:, idx);
    w = mu0 * V(1, :)'.^2;
end
