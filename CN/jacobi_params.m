function [a_diag, b_off, mu0] = jacobi_params(n, alpha, beta)
%% Coeficientii recurentei Golub-Welsch pentru polinoame ortogonale Jacobi
%% cu ponderea (1-x)^alpha * (1+x)^beta pe [-1,1].
%%
%% Recurenta 3 termeni (polinoame monice):
%%   p_{k+1}(x) = (x - a_k) p_k(x) - b_k^2 p_{k-1}(x)
%%
%%   a_k = (beta^2 - alpha^2) / ((2k+alpha+beta)(2k+alpha+beta+2))
%%   b_k^2 = 4k(k+alpha)(k+beta)(k+alpha+beta) / ((2k+a+b)^2 ((2k+a+b)^2 - 1))
%%
%% mu0 = integral_{-1}^{1} (1-x)^alpha (1+x)^beta dx
%%     = 2^{alpha+beta+1} * B(alpha+1, beta+1)

    a_diag = zeros(1, n);
    b_off  = zeros(1, n-1);

    for k = 0:n-1
        s = 2*k + alpha + beta;
        if abs(s) < 1e-14 || abs(s + 2) < 1e-14
            a_diag(k+1) = 0;
        else
            a_diag(k+1) = (beta^2 - alpha^2) / (s * (s + 2));
        end
        if k >= 1
            num = 4*k * (k + alpha) * (k + beta) * (k + alpha + beta);
            den = s^2 * (s^2 - 1);
            b_off(k) = sqrt(num / den);
        end
    end

    mu0 = 2^(alpha + beta + 1) * gamma(alpha + 1) * gamma(beta + 1) / gamma(alpha + beta + 2);
end
