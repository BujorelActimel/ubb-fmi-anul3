function [val, neval] = my_adquad(f, a, b, tol)
% Cuadratura adaptiva pe baza de Simpson.
    fa = f(a);
    fb = f(b);
    m = (a + b) / 2;
    fm = f(m);

    S_tot = (b - a) / 6 * (fa + 4*fm + fb);
    neval = 3;

    [val, neval_rec] = my_adquad_rec(f, a, b, fa, fm, fb, S_tot, tol, 0);
    neval = neval + neval_rec;
end
