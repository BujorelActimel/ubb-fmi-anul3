function [x, iter, res_hist] = my_gauss_seidel(A, b, tol, max_iter)
% Gauss-Seidel: (D+L)*x^(k+1) = b - U*x^(k)
    L_D = tril(A);       % D + L (triunghiular inferior cu diagonala)
    U   = triu(A, 1);    % U strict superior
    x = zeros(length(b), 1);
    b_norm = norm(b);
    res_hist = zeros(max_iter, 1);

    for iter = 1:max_iter
        x = L_D \ (b - U*x);
        r = norm(b - A*x) / b_norm;
        res_hist(iter) = r;
        if r < tol, break; end
    end
    res_hist = res_hist(1:iter);
end
