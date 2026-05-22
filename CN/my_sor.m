function [x, iter, res_hist] = my_sor(A, b, omega, tol, max_iter)
% SOR: (D + omega*L)*x^(k+1) = omega*b + ((1-omega)*D - omega*U)*x^(k)
    N = length(b);
    d = diag(A);
    D   = spdiags(d, 0, N, N);
    L   = tril(A, -1);     % L strict inferior
    U   = triu(A, 1);      % U strict superior

    D_omL = D + omega * L;                   % coef. lhs (triunghiular inf.)
    M     = (1 - omega) * D - omega * U;     % coef. rhs

    x = zeros(N, 1);
    b_norm = norm(b);
    res_hist = zeros(max_iter, 1);

    for iter = 1:max_iter
        x = D_omL \ (omega * b + M * x);
        r = norm(b - A*x) / b_norm;
        res_hist(iter) = r;
        if r < tol, break; end
    end
    res_hist = res_hist(1:iter);
end
