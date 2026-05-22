function [val, iter, err] = my_romberg(f, a, b, tol, nmax)
% Metoda Romberg. Coloana 1 = trapez repetat, restul = extrapolare Richardson.
    R = zeros(nmax, nmax);
    R(1,1) = (b - a) / 2 * (f(a) + f(b));

    for i = 2:nmax
        n_sub = 2^(i-1);
        h = (b - a) / n_sub;

        suma_noua = 0;
        for k = 1:2:(n_sub-1)
            suma_noua = suma_noua + f(a + k * h);
        end
        R(i,1) = R(i-1,1)/2 + h * suma_noua;

        for j = 2:i
            R(i,j) = (4^(j-1) * R(i,j-1) - R(i-1,j-1)) / (4^(j-1) - 1);
        end

        err = abs(R(i,i) - R(i-1,i-1));
        if err < tol
            val = R(i,i);
            iter = i;
            return;
        end
    end

    val = R(nmax, nmax);
    iter = nmax;
    err = abs(R(nmax, nmax) - R(nmax-1, nmax-1));
end
