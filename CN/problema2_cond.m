%% Problema 2 (Testul 2): Conditionarea ecuatiei de gradul 2
%% ax^2 + bx + c = 0

clear; clc; close all;
format long;

fprintf('=======================================================\n');
fprintf('  PROBLEMA 2: Ecuatia de gradul 2 ax^2 + bx + c = 0\n');
fprintf('=======================================================\n\n');

%% =====================================================================
%% PARTEA 1: Analiza conditionarii
%% =====================================================================
%%
%% Din a*r^2 + b*r + c = 0, derivand implicit fata de fiecare coeficient:
%%   dr/da = -r^2  / (2ar+b)
%%   dr/db = -r    / (2ar+b)
%%   dr/dc = -1    / (2ar+b)
%%
%% Deoarece r1,2 = (-b ± sqrt(D)) / (2a) cu D = b^2 - 4ac:
%%   2a*r1 + b = +sqrt(D),   2a*r2 + b = -sqrt(D)
%%
%% Numere de conditionare RELATIVE (|perturbatie relativa coef| → |eroare rel radacina|):
%%   kappa(r,a) = |a/r| * |dr/da| = |a*r|    / sqrt(D)
%%   kappa(r,b) = |b/r| * |dr/db| = |b|      / sqrt(D)
%%   kappa(r,c) = |c/r| * |dr/dc| = |c|      / (|r| * sqrt(D))
%%
%% CONCLUZIE: kappa → inf cand D → 0 (radacina dubla = problema slab conditionata)

fprintf('--- Partea 1: Numere de conditionare relative ---\n\n');

function afis_cond(a, b, c, label)
    D = b^2 - 4*a*c;
    if D <= 0
        r1_re = -b/(2*a);
        r2_re = r1_re;
        sqD = sqrt(max(D, 0));
    else
        sqD = sqrt(D);
        r1_re = (-b + sqD)/(2*a);
        r2_re = (-b - sqD)/(2*a);
    end

    k1a = abs(a*r1_re) / max(sqD, eps);
    k1b = abs(b)       / max(sqD, eps);
    k1c = abs(c)       / (abs(r1_re) * max(sqD, eps));
    k2a = abs(a*r2_re) / max(sqD, eps);
    k2b = abs(b)       / max(sqD, eps);
    k2c = abs(c)       / (abs(r2_re) * max(sqD, eps));

    fprintf('%s: a=%g, b=%g, c=%g,  D=%.3e\n', label, a, b, c, D);
    fprintf('  r1=%-12.6g  kappa_a=%.3e  kappa_b=%.3e  kappa_c=%.3e\n', ...
            r1_re, k1a, k1b, k1c);
    fprintf('  r2=%-12.6g  kappa_a=%.3e  kappa_b=%.3e  kappa_c=%.3e\n\n', ...
            r2_re, k2a, k2b, k2c);
end

afis_cond(1, -5, 6,       'Caz normal    (r=2,3)');
afis_cond(1,  1e8, 1,     'b >> 4ac      (r~-1e8,-1e-8)');
afis_cond(1,  2, 1-1e-8,  'D mic (dubla) (r~-1,-1)');
afis_cond(1,  2, 1,       'D=0 exact     (dubla r=-1)');

%% Grafic: kappa_b in functie de D/b^2 (masura a apropierii de radacina dubla)
fprintf('Grafic: kappa_b = |b|/sqrt(D) in functie de D...\n\n');
b_fix = 2;  a_fix = 1;
c_vals = linspace(1-0.9999, 1-1e-14, 500);   % c → 1 deci D = 4-4c → 0
D_vals = b_fix^2 - 4*a_fix*c_vals;
D_vals = max(D_vals, 0);
kappa_b_vals = abs(b_fix) ./ max(sqrt(D_vals), eps);

figure('Name','Conditionare ecuatie grad 2','Position',[100 100 850 400]);
subplot(1,2,1);
loglog(D_vals+eps, kappa_b_vals, 'b-', 'LineWidth', 2);
xlabel('\Delta = b^2 - 4ac'); ylabel('\kappa_b = |b|/\sqrt{\Delta}');
title('kappa_b diverge cand \Delta \to 0');
grid on;

%% =====================================================================
%% PARTEA 2: Implementare numerica stabila
%% =====================================================================
fprintf('--- Partea 2: Formula stabila vs formula naiva ---\n\n');

function [r1n, r2n] = quadratic_naive(a, b, c)
    D = b^2 - 4*a*c;
    r1n = (-b + sqrt(D)) / (2*a);
    r2n = (-b - sqrt(D)) / (2*a);
end

%% Test 1: Caz normal
fprintf('TEST 1 - Normal: x^2 - 5x + 6 = 0  (radacini exacte: 2, 3)\n');
a=1; b=-5; c=6;
[r1n, r2n] = quadratic_naive(a,b,c);
[r1s, r2s] = quadratic_stable(a,b,c);
fprintf('  Naiv:   r1=%.15f  r2=%.15f\n', r1n, r2n);
fprintf('  Stabil: r1=%.15f  r2=%.15f\n\n', r1s, r2s);

%% Test 2: Anulare tip 1 (b >> 4ac)
%% b=1e8 >> 4*1*1: radacina mica ~ -1/b = -1e-8
%% Formula naiva: (-b + sqrt(b^2-4)) / 2 = cancellation!
fprintf('TEST 2 - Anulare tip 1: x^2 + 1e8*x + 1 = 0  (r_mic ~ -1e-8)\n');
a=1; b=1e8; c=1;
[r1n, r2n] = quadratic_naive(a,b,c);
[r1s, r2s] = quadratic_stable(a,b,c);
r_mic_exact = -c/b;   % Vieta: r1*r2=c/a=1, r1+r2=-b/a=-1e8 => r_mic ~ -1e-8
fprintf('  Exact (Vieta):  r_mic = %.15e\n', r_mic_exact);
fprintf('  Naiv:   r1=%.15e  r2=%.15e\n', r1n, r2n);
fprintf('  Stabil: r1=%.15e  r2=%.15e\n', r1s, r2s);
fprintf('  Eroare naiva:   %.3e   Eroare stabila: %.3e\n\n', ...
        abs(max(abs([r1n,r2n]))/1e8 - 1), abs(min(abs([r1s,r2s]))/1e-8 - 1));

%% Test 3: Anulare tip 2 (b^2 ~ 4ac, radacini aproape egale)
fprintf('TEST 3 - Anulare tip 2: x^2 + 2x + (1-1e-14) = 0  (radacini ~ -1)\n');
a=1; b=2; c=1-1e-14;
[r1n, r2n] = quadratic_naive(a,b,c);
[r1s, r2s] = quadratic_stable(a,b,c);
r_exact_1 = -1 + sqrt(1e-14);   % radacina mai mare
r_exact_2 = -1 - sqrt(1e-14);   % radacina mai mica
fprintf('  Exact:  r1=%.15f  r2=%.15f\n', r_exact_1, r_exact_2);
fprintf('  Naiv:   r1=%.15f  r2=%.15f\n', r1n, r2n);
fprintf('  Stabil: r1=%.15f  r2=%.15f\n', r1s, r2s);
fprintf('  (Ambele formule sunt limitate de conditionarea proasta: kappa~1e7)\n\n');

%% Test 4: Depasire (overflow) b^2
fprintf('TEST 4 - Depasire: x^2 + 1e200*x + 1 = 0  (b^2 overflows)\n');
a=1; b=1e200; c=1;
try
    [r1n, r2n] = quadratic_naive(a,b,c);
    fprintf('  Naiv:   r1=%.6e  r2=%.6e\n', r1n, r2n);
    if isnan(r1n) || isinf(r1n)
        fprintf('  Naiv: NaN/Inf (overflow la b^2=1e400 > realmax~1.8e308)!\n');
    end
catch e
    fprintf('  Naiv: Eroare: %s\n', e.message);
end
[r1s, r2s] = quadratic_stable(a,b,c);
fprintf('  Stabil: r1=%.6e  r2=%.6e\n', r1s, r2s);
fprintf('  Exact:  r_mare ~ %.6e,  r_mic ~ %.6e\n\n', -b/a, -c/b);

%% Grafic comparativ erori test 2
b_vals = logspace(1, 15, 100);
err_naiv  = zeros(size(b_vals));
err_stab  = zeros(size(b_vals));
for i = 1:length(b_vals)
    bv = b_vals(i);
    [r1n_, r2n_] = quadratic_naive(1, bv, 1);
    [r1s_, r2s_] = quadratic_stable(1, bv, 1);
    r_mic = -1/bv;   % Vieta exact
    err_naiv(i) = abs(max(r1n_, r2n_) - r_mic) / abs(r_mic);
    err_stab(i) = abs(max(r1s_, r2s_) - r_mic) / abs(r_mic);
end

subplot(1,2,2);
loglog(b_vals, err_naiv, 'r-', 'LineWidth', 2); hold on;
loglog(b_vals, err_stab, 'g-', 'LineWidth', 2);
loglog(b_vals, eps*ones(size(b_vals)), 'k--');
xlabel('b  (b >> 4ac = 4)');
ylabel('Eroare relativa radacina mica');
title('Formula naiva vs stabila (r_{mic} \approx -1/b)');
legend('Formula naiva', 'Formula stabila (Vieta)', 'eps masina', ...
       'Location','NorthWest');
grid on;

print('-dpng', 'problema2_cond.png');
fprintf('Grafic salvat: problema2_cond.png\n');
close all;

fprintf('=== REZUMAT ===\n');
fprintf('Conditionare:\n');
fprintf('  kappa_b = |b|/sqrt(D) -> inf cand D->0 (radacina dubla)\n');
fprintf('  Problema este slab conditionata cand b^2 ~ 4ac\n\n');
fprintf('Stabilitate numerica (independenta de conditionare):\n');
fprintf('  Anulare tip 1 (b>>4ac): formula naiva pierde cifre la radacina mica\n');
fprintf('  Fix: calculeaza intai radacina mare, apoi r_mic = c/(a*r_mare) [Vieta]\n');
fprintf('  Depasire: normalizeaza coeficientii cu max(|a|,|b|,|c|)\n');
