function [x, iter, res_hist] = my_jacobi(A, b, tol, max_iter)
% Metoda Jacobi: x^(k+1) = x^(k) + D^{-1}(b - A*x^(k))
    N = length(b);
    d = diag(A);                          % vectorul diagonalei
    R = A - spdiags(d, 0, N, N);          % A fara diagonala
    x = zeros(N, 1);
    b_norm = norm(b);
    res_hist = zeros(max_iter, 1);

    for iter = 1:max_iter
        x = (b - R*x) ./ d;
        r = norm(b - A*x) / b_norm;
        res_hist(iter) = r;
        if r < tol, break; end
    end
    res_hist = res_hist(1:iter);
end
