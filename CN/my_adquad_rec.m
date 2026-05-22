function [val, neval] = my_adquad_rec(f, a, b, fa, fm, fb, S_old, tol, depth)
% Pas recursiv. Estimez eroarea cu regula 1/15, aplic corectia Richardson.
    max_depth = 50;
    m = (a + b) / 2;
    h = (b - a) / 2;

    fm1 = f((a + m) / 2);
    fm2 = f((m + b) / 2);
    neval = 2;

    S_left = h/6 * (fa + 4*fm1 + fm);
    S_right = h/6 * (fm + 4*fm2 + fb);
    S_new = S_left + S_right;

    err = abs(S_new - S_old) / 15;

    if err < tol || depth >= max_depth
        val = S_new + (S_new - S_old) / 15;
    else
        [val_l, ne_l] = my_adquad_rec(f, a, m, fa, fm1, fm, S_left, tol/2, depth+1);
        [val_r, ne_r] = my_adquad_rec(f, m, b, fm, fm2, fb, S_right, tol/2, depth+1);
        val = val_l + val_r;
        neval = neval + ne_l + ne_r;
    end
end
