function val = my_serie_exp_sqrt(u, N)
% 2 * sum_{n=0}^{N} u^{2n}/n! = seria trunchiata a lui 2*exp(u^2)
    val = zeros(size(u));
    for i = 1:numel(u)
        s = 0;
        termen = 1;
        for n = 0:N
            s = s + termen;
            termen = termen * u(i)^2 / (n + 1);
        end
        val(i) = 2 * s;
    end
end
