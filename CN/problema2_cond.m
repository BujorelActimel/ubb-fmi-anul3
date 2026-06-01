%% Problema 2 (Testul 1): Conditionarea ecuatiei de gradul 2
%% ax^2 + bx + c = 0
%%
%% Ref: W. Kahan (1972); S. Boldo et al., IEEE TC 58(2):220-228, 2009.

clear; clc; close all;
format long;

fprintf('=======================================================\n');
fprintf('  PROBLEMA 2: Ecuatia de gradul 2 ax^2+bx+c=0\n');
fprintf('=======================================================\n\n');

%% =====================================================================
%% SECTIUNEA 1: Formula de conditionare in functie de a, b, c
%% =====================================================================
fprintf('--- 1. Numere de conditionare relative ---\n\n');

fprintf('Derivare implicita din f(r; a,b,c) = a*r^2 + b*r + c = 0:\n');
fprintf('  df/dr = 2a*r + b,  df/da = r^2,  df/db = r,  df/dc = 1\n');
fprintf('  => dr/da = -r^2/(2ar+b),  dr/db = -r/(2ar+b),  dr/dc = -1/(2ar+b)\n\n');
fprintf('  Notand D = b^2-4ac  si  sqrt(D) = |2ar+b| (pt radacini reale):\n\n');
fprintf('  FORMULE DE CONDITIONARE (in a, b, c):\n\n');
fprintf('    kappa(r, a) = |a*r|     / sqrt(b^2 - 4ac)\n');
fprintf('    kappa(r, b) = |b|       / sqrt(b^2 - 4ac)\n');
fprintf('    kappa(r, c) = |c|/(|r|) / sqrt(b^2 - 4ac)\n\n');
fprintf('  Substituind r_{1,2} = (-b +/- sqrt(D)) / (2a):\n\n');
fprintf('    kappa(r1, a) = |-b + sqrt(D)| / (2*sqrt(D))\n');
fprintf('    kappa(r2, a) = |-b - sqrt(D)| / (2*sqrt(D))\n');
fprintf('    kappa(r,  b) = |b| / sqrt(D)          <- dominant, acelasi pt ambele\n');
fprintf('    kappa(r1, c) = 2|ac| / (|-b+sqrt(D)|*sqrt(D))\n\n');
fprintf('  CONCLUZIE: toate numerele de conditionare -> inf cand D = b^2-4ac -> 0\n');
fprintf('  => radacina dubla (b^2 = 4ac) = problema slab conditionata.\n\n');

function afis_cond(a, b, c, label)
    D   = b^2 - 4*a*c;
    sqD = sqrt(max(D, 0));
    if D > 0
        r1 = (-b + sqD)/(2*a);
        r2 = (-b - sqD)/(2*a);
    else
        r1 = -b/(2*a);  r2 = r1;
    end
    ka = @(r) abs(a*r)      / max(sqD, eps);
    kb =      abs(b)        / max(sqD, eps);
    kc = @(r) abs(c)        / max(abs(r)*sqD, eps);
    fprintf('  %-26s  D = %+.3e\n', label, D);
    fprintf('    r1=%+.6e  kappa_a=%.2e  kappa_b=%.2e  kappa_c=%.2e\n', ...
            r1, ka(r1), kb, kc(r1));
    fprintf('    r2=%+.6e  kappa_a=%.2e  kappa_b=%.2e  kappa_c=%.2e\n\n', ...
            r2, ka(r2), kb, kc(r2));
end

afis_cond(1, -5,      6,       'Normal (r=2, 3)');
afis_cond(1,  1e8,    1,       'b>>4ac  (r~-1e8, -1e-8)');
afis_cond(1,  2e8+1,  1e16+1e8,'b^2~4ac (r~1e8, 1e8+1)');
afis_cond(1,  2,      1,       'D=0 exact (radacina dubla)');

%% =====================================================================
%% SECTIUNEA 2: Cazuri problematice si remedii
%% =====================================================================

function [r1, r2] = naive(a, b, c)
    D  = b^2 - 4*a*c;
    r1 = (-b + sqrt(D)) / (2*a);
    r2 = (-b - sqrt(D)) / (2*a);
end

%% ----------------------------------------------------------------
%% CAZ 1: b^2 >> 4ac  →  anulare la radacina mica
%% ----------------------------------------------------------------
fprintf('--- Caz 1: b^2 >> 4ac  (anulare la radacina mica) ---\n\n');

a=1;  b=1e8;  c=1;
r_mic_exact = -c/b;   % Vieta: r1*r2 = c/a, r1+r2 = -b/a => r_mic ≈ -c/b

[r1n, r2n] = naive(a, b, c);
[r1s, r2s] = quadratic_stable(a, b, c);
r_mic_naiv = max(r1n, r2n);
r_mic_stab = max(r1s, r2s);

fprintf('  Ecuatia: x^2 + 1e8*x + 1 = 0\n');
fprintf('  Radacina mica exacta (Vieta):  r = -c/b = %.15e\n', r_mic_exact);
fprintf('  Naiv:   r_mic = %.15e  (eroare rel = %.3e)\n', ...
        r_mic_naiv, abs(r_mic_naiv/r_mic_exact - 1));
fprintf('  Stabil: r_mic = %.15e  (eroare rel = %.3e)\n\n', ...
        r_mic_stab, abs(r_mic_stab/r_mic_exact - 1));
fprintf('  Fix: calculeaza radacina MARE fara anulare (-b - sign(b)*sqrt(D)),\n');
fprintf('  apoi r_mic = c/(a*r_mare)  [relatia lui Vieta: r1*r2 = c/a].\n\n');

%% ----------------------------------------------------------------
%% CAZ 2: b^2 ≈ 4ac  →  anulare la discriminant
%%         Fix: Kahan EFT simuleaza precizia cvadrupla pt. discriminant
%% ----------------------------------------------------------------
fprintf('--- Caz 2: b^2 ≈ 4ac  (anulare la discriminant, fix: Kahan EFT) ---\n\n');

%% Exemplu clasic (Kahan): radacini exacte r1=1e8, r2=1e8+1
%% D_exact = (r1-r2)^2 = 1, dar b^2 ≈ 4c ≈ 4e16 => ulp(4e16) = 8 => D_naiv = 0!
a = 1;
b = -(2e8 + 1);            % b = -(r1+r2)
c = 1e8 * (1e8 + 1);       % c = r1*r2 = 1e16 + 1e8
r1_exact = 1e8;
r2_exact = 1e8 + 1;
D_exact  = 1;              % b^2 - 4c = (2e8+1)^2 - 4(1e16+1e8) = 1

fprintf('  Ecuatia: x^2 - (2e8+1)*x + (1e16+1e8) = 0\n');
fprintf('  Radacini exacte: r1 = 1e8,  r2 = 1e8+1\n');
fprintf('  D_exact = b^2 - 4ac = %g\n\n', D_exact);

% Discriminant naiv
D_naiv = b^2 - 4*a*c;
fprintf('  fl(b^2)    = %.0f\n', b^2);
fprintf('  fl(4ac)    = %.0f\n', 4*a*c);
fprintf('  D_naiv     = fl(b^2) - fl(4ac) = %g  <-- eroare = %g!\n\n', ...
        D_naiv, D_naiv - D_exact);
fprintf('  Explicatie: ulp(4e16) = 8, deci b^2 si 4ac se rotunjesc la aceeasi\n');
fprintf('  valoare, iar diferenta lor (D_naiv) este 0 in loc de 1.\n\n');

% Kahan EFT discriminant (aplicat pe coeficienti ORIGINALI, fara normalizare)
% Algoritmul: d = (p - q4) + (dp - dq4)
%   p  = fl(b^2),  dp  = b^2 - p   (exact prin two_prod)
%   q4 = fl(4ac),  dq4 = 4ac - q4  (exact: 4*two_prod(a,c))
p  = b * b;
q  = a * c;
q4 = 4 * q;                        % fl(4ac) = 4*fl(ac) (exact, *4 = *2^2)

C  = 2^27 + 1;
bh = C*b - (C*b - b);  bl = b - bh;
dp = ((bh*bh - p) + 2*bh*bl) + bl*bl;  % b^2 - fl(b^2), exact

ah = C*a - (C*a - a);  al = a - ah;
ch = C*c - (C*c - c);  cl = c - ch;
dq  = ((ah*ch - q) + ah*cl + al*ch) + al*cl;  % ac - fl(ac), exact
dq4 = 4 * dq;                                  % 4ac - q4, exact

if p + q4 <= 3 * abs(p - q4)
    D_kahan = p - q4;
else
    D_kahan = (p - q4) + (dp - dq4);
end

fprintf('  Kahan EFT:\n');
fprintf('    dp = b^2 - fl(b^2) = %g  (eroare exacta de inmultire)\n', dp);
fprintf('    dq = ac - fl(ac)   = %g\n', dq);
fprintf('    D_kahan = (fl(b^2)-fl(4ac)) + (dp-4*dq) = %g  (corect!)\n\n', D_kahan);

[r1n, r2n] = naive(a, b, c);
[r1s, r2s] = quadratic_stable(a, b, c);

fprintf('  %-22s  r1 = %.8f   r2 = %.8f\n', 'Exacte:', r1_exact, r2_exact);
fprintf('  %-22s  r1 = %.8f   r2 = %.8f\n', 'Naiv (D=0):', r1n, r2n);
fprintf('  %-22s  r1 = %.8f   r2 = %.8f\n', 'Kahan EFT:', r1s, r2s);
fprintf('\n  Erori relative:\n');
fprintf('    naiv:        r1: %.3e,  r2: %.3e\n', ...
        abs(r1n/r1_exact-1), abs(r2n/r2_exact-1));
fprintf('    Kahan EFT:   r1: %.3e,  r2: %.3e\n\n', ...
        abs(r1s/r1_exact-1), abs(r2s/r2_exact-1));

fprintf('  Concluzie: Kahan EFT calculeaza dp = b*b - fl(b*b) si dq = a*c - fl(a*c)\n');
fprintf('  fara rotunjire (Veltkamp splitting), apoi corecteaza D cu (dp-4dq).\n');
fprintf('  Aceasta simuleaza precizia cvadrupla pentru calculul discriminantului.\n\n');

%% ----------------------------------------------------------------
%% CAZ 3: Depasire (overflow) la calculul b^2
%% ----------------------------------------------------------------
fprintf('--- Caz 3: Depasire la calculul discriminantului ---\n\n');

a=1;  b=1e200;  c=1;

fprintf('  Ecuatia: x^2 + 1e200*x + 1 = 0\n');
fprintf('  realmax = %.3e,   b^2 = 1e400 >> realmax => OVERFLOW\n', realmax);
fprintf('  Radacini exacte: r_mare = -1e200,  r_mica = -1e-200\n\n');

D_naiv3 = b^2 - 4*a*c;
fprintf('  b^2 naiv = %s  (Inf: %d)\n', num2str(b^2), isinf(b^2));
[r1n3, r2n3] = naive(a, b, c);
fprintf('  Naiv:   r1=%s  r2=%s  (Inf sau NaN)\n\n', num2str(r1n3), num2str(r2n3));

[r1s3, r2s3] = quadratic_stable(a, b, c);
fprintf('  Stabil: r1=%.6e  r2=%.6e\n', r1s3, r2s3);
fprintf('  Exact:  r_mare=-1e200,  r_mica=-1e-200\n\n');
fprintf('  Erori: r_mare=%.3e  r_mica=%.3e\n\n', ...
        abs(r1s3/(-1e200)-1), abs(r2s3/(-1e-200)-1));
fprintf('  Fix: normalizam cu s = max(|a|,|b|,|c|) = 1e200.\n');
fprintf('  Coef. normalizati: an=1e-200, bn=1, cn=1e-200 => bn^2=1 (ok).\n\n');

%% =====================================================================
%% SECTIUNEA 3: Grafice comparative
%% =====================================================================

figure('Position',[50 50 1200 420]);

%% Grafic 1: kappa_b in functie de D (conditionare)
subplot(1,3,1);
c_vals = linspace(0, 1-1e-12, 600);
D_vals = max(4 - 4*c_vals, 0);   % a=1, b=2, c variaza spre 1
kb     = 2 ./ max(sqrt(D_vals), eps);
semilogx(D_vals + eps, kb, 'b-', 'LineWidth', 2);
xlabel('D = b^2 - 4ac'); ylabel('\kappa_b = |b|/\surdD');
title('Conditionare: \kappa_b \to \infty cand D \to 0');
grid on; axis tight;

%% Grafic 2: Erori caz 1 (b mare) - naiv vs stabil
subplot(1,3,2);
bv = logspace(1, 14, 200);
en = zeros(size(bv));  es = zeros(size(bv));
for k = 1:numel(bv)
    bk = bv(k);
    [r1_, r2_] = naive(1, bk, 1);
    [r1s_, r2s_] = quadratic_stable(1, bk, 1);
    rm_ex = -1/bk;
    en(k) = max(abs(max(r1_,r2_)/rm_ex - 1), eps);
    es(k) = max(abs(max(r1s_,r2s_)/rm_ex - 1), eps);
end
loglog(bv, en, 'r-', 'LineWidth',2); hold on;
loglog(bv, es, 'g-', 'LineWidth',2);
loglog(bv, eps*ones(size(bv)), 'k--');
xlabel('b  (x^2+bx+1=0)');
ylabel('Eroare relativa r_{mic}');
title('Caz 1: b^2 >> 4ac');
legend('Naiv','Kahan+Vieta','eps masina','Location','northwest');
grid on;

%% Grafic 3: Erori caz 2 (b^2 ~ 4ac) - comparatie discriminant
subplot(1,3,3);
% Radacini -1 si -(1+delta), variind delta
delta_vals = logspace(-14, 0, 200);
en2 = zeros(size(delta_vals));
es2 = zeros(size(delta_vals));
for k = 1:numel(delta_vals)
    dk  = delta_vals(k);
    ak=1; bk=-(2+dk); ck=1+dk;   % radacini: -1 si -(1+dk)
    r2_ex = -(1 + dk);
    [r1_, r2_] = naive(ak, bk, ck);
    [r1s_, r2s_] = quadratic_stable(ak, bk, ck);
    % gasim care radacina e mai aproape de r2_ex
    [~,i1] = min([abs(r1_-r2_ex), abs(r2_-r2_ex)]);
    [~,i2] = min([abs(r1s_-r2_ex), abs(r2s_-r2_ex)]);
    rn=[r1_,r2_]; rs=[r1s_,r2s_];
    en2(k) = max(abs(rn(i1)/r2_ex - 1), eps);
    es2(k) = max(abs(rs(i2)/r2_ex - 1), eps);
end
loglog(delta_vals, en2, 'r-', 'LineWidth',2); hold on;
loglog(delta_vals, es2, 'g-', 'LineWidth',2);
loglog(delta_vals, eps*ones(size(delta_vals)), 'k--');
xlabel('\delta  (radacini -1 si -(1+\delta))');
ylabel('Eroare relativa r_2');
title('Caz 2: b^2 \approx 4ac');
legend('Naiv','Kahan EFT','eps masina','Location','southwest');
grid on;

print('-dpng', 'problema2_cond.png');
fprintf('Grafic salvat: problema2_cond.png\n');
close all;

%% =====================================================================
%% REZUMAT
%% =====================================================================
fprintf('=== REZUMAT ===\n\n');
fprintf('Formula de conditionare (in a, b, c):\n');
fprintf('  kappa(r, a) = |a*r|     / sqrt(b^2-4ac)\n');
fprintf('  kappa(r, b) = |b|       / sqrt(b^2-4ac)\n');
fprintf('  kappa(r, c) = |c|/(|r|) / sqrt(b^2-4ac)\n');
fprintf('  => problema slab conditionata cand b^2 ≈ 4ac\n\n');
fprintf('Cazuri problematice si remedii:\n');
fprintf('  1. b^2 >> 4ac : anulare r_mica  → Vieta: r_mic = c/(a*r_mare)\n');
fprintf('  2. b^2 ≈ 4ac  : anulare in D   → Kahan EFT (Veltkamp two_prod)\n');
fprintf('     D = (p-q4)+(dp-4dq),  dp=b^2-fl(b^2), dq=ac-fl(ac)  exact\n');
fprintf('     Simuleaza precizie cvadrupla pentru calculul discriminantului.\n');
fprintf('  3. Overflow b^2: b*b=Inf → normalizare cu s=max(|a|,|b|,|c|)\n');
