%% Testul 2: Problema 3 (Higham) + Problema 4 (Lorentz)

clear; clc; close all;
format long;

%% =====================================================================
%% PROBLEMA 3 - Functia Higham: 52 radacini patrate urmate de 52 patrate
%% =====================================================================
%
% Teoretic: (x^(1/2^52))^(2^52) = x pentru orice x > 0.
% Practic: reprezentarea virgula flotanta introduce erori de rotunjire.
%
% Analiza:
%   Dupa 52 radacini patrate: y = x^(2^-52)
%   Deoarece 2^-52 = eps ≈ 2.22e-16 (epsilon masina), pentru x in [1,10]:
%     y = x^(2^-52) = 1 + ln(x)/2^52 + O((ln x)^2/2^104)
%
%   In virgula flotanta, numerele > 1 se reprezinta ca 1 + k*eps, k=1,2,...
%   Cel mai mic numar reprezentabil > 1 este 1 + eps = 1 + 2^-52.
%   Valoarea 1 + delta se rotunjeste la 1.0 exact daca delta < eps/2 = 2^-53.
%
%   Conditia ca x^(2^-52) sa se rotunjeasca la 1.0:
%     ln(x)/2^52 < 2^-53  <=>  ln(x) < 1/2  <=>  x < e^(1/2) ≈ 1.6487
%
%   => Pentru x < e^(1/2) ≈ 1.649: dupa 52 sqrt, y = 1.0 exact in float.
%      Cele 52 patrate ulterioare dau 1^2^52 = 1, nu x.
%      Deci Higham(x) = 1, independent de x!
%
%   => Pentru x > e^(1/2): y = x^(2^-52) > 1 + eps/2, deci y != 1.0 exact.
%      Cele 52 patrate recupereaza partial x, cu erori de rotunjire acumulate.

fprintf('=== PROBLEMA 3: Functia Higham ===\n\n');

x_thresh = exp(0.5);
fprintf('Pragul teoretic: x_thresh = e^(1/2) = %.6f\n', x_thresh);
fprintf('  - Pentru x < %.4f: Higham(x) = 1 (x^(2^-52) se rotunjeste la 1.0)\n', x_thresh);
fprintf('  - Pentru x > %.4f: Higham(x) ≈ x (cu erori de rotunjire acumulate)\n\n', x_thresh);

% Verificare numerica pentru cateva valori
test_vals = [1.2, 1.5, x_thresh, 1.7, 2.0, 5.0, 10.0];
fprintf('  %-10s  %-20s  %-15s\n', 'x', 'Higham(x)', 'Diferenta');
for xv = test_vals
    hv = Higham(xv);
    fprintf('  %-10.4f  %-20.15f  %+.3e\n', xv, hv, hv - xv);
end
fprintf('\n');

% Verificare: dupa 52 sqrt, valoarea intermediara
fprintf('Valori intermediare dupa 52 radacini patrate:\n');
fprintf('  %-8s  %-22s  %-12s  %s\n', 'x', 'x^(2^-52)', '1+ln(x)/2^52', 'Egale cu 1?');
for xv = [1.2, 1.5, x_thresh, 1.7, 2.0]
    y_inter = xv;
    for i=1:52, y_inter = sqrt(y_inter); end
    teoretic = 1 + log(xv)/2^52;
    if y_inter == 1.0, status = 'DA -> Higham=1'; else, status = 'NU -> recuperat'; end
    fprintf('  %-8.4f  %-22.15f  %-12.15f  %s\n', xv, y_inter, teoretic, status);
end
fprintf('\n');

% Grafic
x = logspace(0, 1, 2013);
y = Higham(x);

figure('Name','Problema 3 - Higham','Position',[100 100 800 450]);
plot(x, y, 'b.', 'MarkerSize', 4); hold on;
plot(x, x, 'r--', 'LineWidth', 1.5);
xline(x_thresh, 'g-', 'LineWidth', 2);
xlabel('x'); ylabel('Higham(x)');
title('Higham(x): y=x teoretic, y=1 pentru x < e^{1/2} ≈ 1.649 in float');
legend('Higham(x)', 'y = x (ideal)', ...
       sprintf('x_{thresh} = e^{1/2} \\approx %.4f', x_thresh), ...
       'Location','NorthWest');
grid on;
text(1.1, 7, sprintf('Zona problematica:\nHigham(x)=1 \\neq x\npentru x < %.3f', x_thresh), ...
     'FontSize', 10, 'Color', 'red');
print('-dpng', 'problema3_higham.png');
fprintf('Grafic salvat: problema3_higham.png\n\n');
close all;

%% =====================================================================
%% PROBLEMA 4 - Factorul Lorentz si precizia virgulei flotante
%% =====================================================================
%
% gamma = 1 / sqrt(1 - v^2/c^2)
%
% v = 100.000 km/h = 100000 * 1000/3600 m/s ≈ 27777.78 m/s
% c = 299,792,458 m/s
% r = v/c ≈ 9.2657e-5   (r << 1, efect relativist mic)
%
% PROBLEMA NUMERICA (anulare / cancellation):
%   1 - r^2 = 1 - 8.585e-9 ≈ 0.9999999914...
%   Scazand un numar mic din 1, se pierd ~9 zecimale de precizie.
%   gamma = 1/sqrt(1-r^2) ≈ 1.0000000042930... (corectia e ≈ 4.29e-9)
%
%   In double: gamma are ~15 cifre semnificative (relative la gamma~1).
%   Corectia (gamma-1) ≈ 4.29e-9 are doar ~15-9 = 6-7 cifre semnificative
%   cand e calculata prin (gamma_direct - 1).
%
% SOLUTIE: seria Taylor (1-x^2)^(-1/2) = 1 + x^2/2 + 3x^4/8 + ...
%   Calculam gamma-1 ≈ r^2/2 direct, fara anulare => precizie completa.
%
% INTREBAREA PROBLEMEI: Are MATLAB suficienta precizie pt efectul relativist?
%   v = 100.000 km/h are ~6 cifre semnificative.
%   => eroarea relativa in r este ~5e-6, deci in gamma-1 este ~1e-5.
%   => avem nevoie de ~5 cifre semnificative in gamma-1.
%   Ambele formule (directa si Taylor ordin 2) ofera >6 cifre => SUFICIENT.
%   Dar formula directa pierde precizie inutil prin anulare.

fprintf('=== PROBLEMA 4: Factorul Lorentz ===\n\n');

c = 299792458;
v = 100000 * 1000 / 3600;
r = v / c;

fprintf('Date:\n');
fprintf('  v = %.6f m/s = 100.000 km/h\n', v);
fprintf('  c = %d m/s\n', c);
fprintf('  r = v/c = %.6e\n', r);
fprintf('  r^2    = %.6e\n\n', r^2);

% Analiza anularii
fprintf('Analiza numerica:\n');
fprintf('  1 - r^2 = %.15f\n', 1 - r^2);
fprintf('  Anulare: scazand %.3e din 1, se pierd aprox. %d zecimale de precizie\n', ...
        r^2, floor(-log10(r^2)));
fprintf('  Eroarea relativa in (1-r^2): ~eps / (1-r^2) * (1/r^2) ≈ %.2e\n\n', ...
        eps / (1-r^2) / r^2 * r^2);

% Formula directa
gamma_direct = 1 / sqrt(1 - r^2);
fprintf('Formula directa:  gamma = 1/sqrt(1-r^2)\n');
fprintf('  gamma          = %.15f\n', gamma_direct);
fprintf('  gamma - 1      = %.6e  (corectia relativista)\n', gamma_direct - 1);
fprintf('  Cifre semnif. in (gamma-1): aprox. %d\n\n', ...
        floor(15 - log10(1/r^2)));

% Taylor ordin 2: (1-x^2)^(-1/2) = 1 + x^2/2 + O(x^4)
gamma_t2 = 1 + r^2/2;
err_t2   = abs(gamma_t2 - gamma_direct);
fprintf('Taylor ordin 2:  gamma ≈ 1 + r^2/2\n');
fprintf('  gamma          = %.15f\n', gamma_t2);
fprintf('  gamma - 1      = %.6e\n', r^2/2);
fprintf('  Eroare vs direct: %.3e  (negl. pt r << 1)\n\n', err_t2);

% Taylor ordin 4: (1-x^2)^(-1/2) = 1 + x^2/2 + 3x^4/8 + O(x^6)
gamma_t4 = 1 + r^2/2 + 3*r^4/8;
err_t4   = abs(gamma_t4 - gamma_direct);
fprintf('Taylor ordin 4:  gamma ≈ 1 + r^2/2 + 3r^4/8\n');
fprintf('  gamma          = %.15f\n', gamma_t4);
fprintf('  Eroare vs direct: %.3e\n\n', err_t4);

% Concluzie
fprintf('Concluzie:\n');
fprintf('  v = 100.000 km/h are ~6 cifre semnif. => eroare relativa ~1e-5 in gamma-1.\n');
fprintf('  Formula directa  da gamma-1 cu ~%d cifre semnif. => suficienta.\n', ...
        max(1, floor(15 - log10(1/(r^2)))));
fprintf('  Taylor ordin 2   da gamma-1 = r^2/2 cu ~15 cifre semnif. => mai precisa.\n');
fprintf('  Recomandare: folositi Taylor pentru v << c (evita anularea inutila).\n');

% Higham(x) definita in Higham.m (fisier separat)
