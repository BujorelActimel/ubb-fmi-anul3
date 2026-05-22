function [r1, r2] = quadratic_stable(a, b, c)
%% Rezolvare stabila a ecuatiei ax^2 + bx + c = 0
%% Evita:
%%   - Anulare tip 1 (b >> 4ac): formula naiva da cancellation la radacina mica
%%   - Anulare tip 2 (b^2 ~ 4ac): discriminant ~ 0, radacini aproape egale
%%   - Depasire (overflow): b^2 poate depasi realmax

    % Normalizare pentru a evita overflow
    s = max(abs([a, b, c]));
    if s == 0, error('Toti coeficientii sunt zero.'); end
    an = a/s;  bn = b/s;  cn = c/s;

    % Discriminantul normalizat
    disc = bn^2 - 4*an*cn;

    if disc < 0
        % Radacini complexe
        sd = sqrt(-disc);
        r1 = (-bn + 1i*sd) / (2*an);
        r2 = conj(r1);
        return;
    end

    sd = sqrt(disc);

    % Alegem semnul care evita anularea (q are modulul maxim)
    % sign(b)=0 cand b=0 => luam +sd => r = sqrt(-c/a)
    q = -0.5 * (bn + sign(bn)*sd);

    if bn == 0
        % Caz special b=0: x = +/-sqrt(-c/a), fara anulare
        if an*cn > 0
            sd2 = sqrt(disc);  % disc = -4*an*cn, dar am verificat disc>=0 deja
        end
        r1 =  sqrt(-cn/an);
        r2 = -sqrt(-cn/an);
        return;
    end

    % Radacina cu modul mare: fara anulare
    r1 = q / an;
    % Radacina cu modul mic: prin formula lui Vieta (r1*r2 = c/a => r2 = c/(a*r1) = cn/q)
    if abs(q) > eps * abs(an)
        r2 = cn / q;
    else
        r2 = r1;  % radacina dubla
    end
end
