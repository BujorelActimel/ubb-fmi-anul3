function [r1, r2] = quadratic_stable(a, b, c)
%% Rezolvare stabila a ecuatiei ax^2 + bx + c = 0
%%
%% Trateaza 3 cazuri problematice:
%%   1. b^2 >> 4ac  : anulare la radacina mica  → fix: formula lui Vieta
%%   2. b^2 ≈ 4ac   : anulare la discriminant   → fix: Kahan EFT (two_prod)
%%   3. b^2 overflow: b*b = Inf                 → fix: normalizare coeficienti
%%
%% Ref: W. Kahan (1972), S. Boldo et al. IEEE TC 58(2):220-228, 2009.

    % ----------------------------------------------------------------
    % Pas 1: normalizare DOAR daca exista risc de overflow
    % (normalizarea inutila ar strica acuratetea EFT in cazul b^2~4ac)
    % ----------------------------------------------------------------
    THRESH = sqrt(realmax) / 2;    % ~ 6.7e153
    if max(abs([a, b, c])) > THRESH
        s  = max(abs([a, b, c]));
        a  = a/s;  b = b/s;  c = c/s;
        % Dupa normalizare max coef <= 1, deci b^2 <= 1, fara overflow
    end

    % ----------------------------------------------------------------
    % Pas 2: discriminant D = b^2 - 4ac prin algoritmul lui Kahan (EFT)
    %        Eroare garantata <= 2*ulp(D)  [Boldo 2009, Program 1]
    % ----------------------------------------------------------------
    D = kahan_D(a, b, c);

    % ----------------------------------------------------------------
    % Pas 3: radacini
    % ----------------------------------------------------------------
    if D < 0
        sd = sqrt(-D);
        r1 = (-b + 1i*sd) / (2*a);
        r2 = conj(r1);
        return;
    end

    sd = sqrt(D);

    if b == 0
        r1 =  sqrt(-c/a);
        r2 = -r1;
        return;
    end

    % Alegem semnul care evita anularea:
    % q are modul maxim => radacina mare fara anulare
    q  = -0.5 * (b + sign(b)*sd);
    r1 = q / a;
    % Radacina mica: prin relatia lui Vieta  r1*r2 = c/a  => r2 = c/(a*r1) = c/q
    if abs(q) > eps * abs(a)
        r2 = c / q;
    else
        r2 = r1;   % radacina dubla
    end
end

% -----------------------------------------------------------------------
% Discriminant Kahan: D = b^2 - 4*a*c cu eroare <= 2*ulp(D)
% Daca b^2 si 4ac sunt departe (caz 1), simpla diferenta e suficienta.
% Daca b^2 ≈ 4ac (caz 2), EFT two_prod corecteaza erorile de rotunjire.
% -----------------------------------------------------------------------
function D = kahan_D(a, b, c)
    p  = b * b;           % fl(b^2)
    q  = a * c;           % fl(a*c)
    q4 = 4 * q;           % fl(4*a*c) = 4*fl(a*c), exact (inmultire cu putere a lui 2)

    % Conditia Kahan: daca p si q4 sunt suficient de diferite,
    % simpla scadere p - q4 nu sufera de anulare semnificativa
    if p + q4 <= 3 * abs(p - q4)
        D = p - q4;
    else
        % EFT: calculeaza erorile exacte de rotunjire (Veltkamp splitting)
        [~, dp]  = two_prod(b, b);    % dp  = b*b - p    (exact)
        [~, dq]  = two_prod(a, c);    % dq  = a*c - q    (exact)
        dq4 = 4 * dq;                 % 4*a*c - q4 = 4*dq  (exact)
        % D = (b^2 - 4ac) = (p + dp) - (q4 + dq4)
        %   = (p - q4) + (dp - dq4)   <- corectie de ordinul ulp
        D = (p - q4) + (dp - dq4);
    end
end

% -----------------------------------------------------------------------
% two_prod(a, b): returneaza h = fl(a*b) si t = a*b - h (exact, fara rotunjire)
% Algoritm: Veltkamp splitting  [nu necesita FMA]
% -----------------------------------------------------------------------
function [h, t] = two_prod(a, b)
    h = a * b;
    C = 2^27 + 1;       % factor de taiere pentru prec. 53 biti (double)
    % Split a = ah + al  (ah are bitii superiori, al cei inferiori)
    ca = C * a;  ah = ca - (ca - a);  al = a - ah;
    % Split b = bh + bl
    cb = C * b;  bh = cb - (cb - b);  bl = b - bh;
    % a*b - h = (ah+al)*(bh+bl) - h  (exact prin formula Dekker)
    t = ((ah*bh - h) + ah*bl + al*bh) + al*bl;
end
