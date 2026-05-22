%% Teste Cuadratura Numerica - Problema 3 + Problema 10 (obligatorie)

clear; clc; close all;
format long;

% graficul ramane deschis pana se inchide manual
% (altfel Octave il inchide la sfarsitul scriptului)

%% PROBLEMA 10
fprintf('=============================================================\n');
fprintf('  PROBLEMA 10\n');
fprintf('=============================================================\n\n');

%% 10(a) - R(i+1,2) = Simpson repetat
% R(i,1) = T(h), trapez repetat cu pas h = (b-a)/2^(i-1)
% R(i+1,2) = (4*T(h/2) - T(h)) / 3
% Desfacand, se obtine exact Simpson repetat cu pasul h.
% Eliminam termenul O(h^2) din eroare, ramanem cu O(h^4).

fprintf('--- (a): R(i+1,2) = Simpson repetat ---\n\n');
fprintf('R(i+1,2) = (4*T(h/2) - T(h)) / 3\n');
fprintf('= (h/6)*[f(a) + 4f(a+h/2) + 2f(a+h) + ... + f(b)] = Simpson repetat\n\n');

%% 10(b) - R(i,3) = Boole-Villarceau repetat
% R(i,3) = (16*R(i,2) - R(i-1,2)) / 15
% Elimina si termenul O(h^4), ordin O(h^6).
% Coeficientii care ies sunt (7, 32, 12, 32, 7)/90 = Boole elementar.

fprintf('--- (b): R(i,3) = Boole-Villarceau repetat ---\n\n');
fprintf('R(i,3) = (16*R(i,2) - R(i-1,2)) / 15\n');
fprintf('Coeficientii rezultati: (7,32,12,32,7)/90 = Boole elementar repetat\n\n');

%% 10(c) - Verificare practica pe int_1^2 ln(x) dx
% Valoare exacta: 2*ln(2) - 1

fprintf('--- (c): Verificare pe int_1^2 ln(x) dx ---\n\n');

val_exacta = 2*log(2) - 1;
fprintf('Valoare exacta: 2*ln(2) - 1 = %.15f\n\n', val_exacta);

f_log = @(x) log(x);
a_log = 1; b_log = 2;

% Tabelul Romberg complet
n_max_rom = 12;
R = zeros(n_max_rom, n_max_rom);

% Coloana 1: trapez repetat
for i = 1:n_max_rom
    n_sub = 2^(i-1);
    h = (b_log - a_log) / n_sub;
    suma = f_log(a_log)/2 + f_log(b_log)/2;
    for k = 1:(n_sub-1)
        suma = suma + f_log(a_log + k*h);
    end
    R(i,1) = h * suma;
end

% Extrapolarea Richardson
for j = 2:n_max_rom
    for i = j:n_max_rom
        R(i,j) = (4^(j-1) * R(i, j-1) - R(i-1, j-1)) / (4^(j-1) - 1);
    end
end

% Verificare (a): Simpson repetat vs R(i,2)
fprintf('Verificare (a): Simpson repetat vs R(i,2)\n');
fprintf('%5s %20s %20s %15s\n', 'i', 'R(i,2)', 'Simpson_repetat', 'Diferenta');
for i = 2:min(8, n_max_rom)
    n_sub = 2^(i-2);
    h = (b_log - a_log) / n_sub;
    val_simp = 0;
    for k = 0:(n_sub-1)
        x_l = a_log + k*h;
        val_simp = val_simp + (h/6)*(f_log(x_l) + 4*f_log(x_l+h/2) + f_log(x_l+h));
    end
    fprintf('%5d %20.15f %20.15f %15.2e\n', i, R(i,2), val_simp, abs(R(i,2)-val_simp));
end
fprintf('\n');

% Verificare (b): Boole repetat vs R(i,3)
fprintf('Verificare (b): Boole-Villarceau repetat vs R(i,3)\n');
fprintf('%5s %20s %20s %15s\n', 'i', 'R(i,3)', 'Boole_repetat', 'Diferenta');
for i = 3:min(9, n_max_rom)
    n_sub = 2^(i-3);
    h = (b_log - a_log) / n_sub;
    val_boole = 0;
    for k = 0:(n_sub-1)
        x0 = a_log + k*h;
        val_boole = val_boole + (h/90)*(7*f_log(x0) + 32*f_log(x0+h/4) + ...
                    12*f_log(x0+h/2) + 32*f_log(x0+3*h/4) + 7*f_log(x0+h));
    end
    fprintf('%5d %20.15f %20.15f %15.2e\n', i, R(i,3), val_boole, abs(R(i,3)-val_boole));
end
fprintf('\n');

% Erori pentru graficul loglog
h_trap = zeros(n_max_rom, 1);
err_trap = zeros(n_max_rom, 1);
for i = 1:n_max_rom
    h_trap(i) = (b_log - a_log) / 2^(i-1);
    err_trap(i) = abs(R(i,1) - val_exacta);
end

h_simp = zeros(n_max_rom-1, 1);
err_simp = zeros(n_max_rom-1, 1);
for i = 2:n_max_rom
    h_simp(i-1) = (b_log - a_log) / 2^(i-2);
    err_simp(i-1) = abs(R(i,2) - val_exacta);
end

h_boole = zeros(n_max_rom-2, 1);
err_boole = zeros(n_max_rom-2, 1);
for i = 3:n_max_rom
    h_boole(i-2) = (b_log - a_log) / 2^(i-3);
    err_boole(i-2) = abs(R(i,3) - val_exacta);
end

% Grafic loglog
figure('Name', 'Problema 10(c)');

idx_t = err_trap > 0;
idx_s = err_simp > 0;
idx_b = err_boole > 0;

loglog(h_trap(idx_t), err_trap(idx_t), 'bo-', 'LineWidth', 1.5, 'MarkerSize', 8);
hold on;
loglog(h_simp(idx_s), err_simp(idx_s), 'rs-', 'LineWidth', 1.5, 'MarkerSize', 8);
loglog(h_boole(idx_b), err_boole(idx_b), 'g^-', 'LineWidth', 1.5, 'MarkerSize', 8);

% Linii de referinta
h_ref = logspace(log10(min(h_trap)), log10(max(h_trap)), 100);
loglog(h_ref, h_ref.^2 * 0.1, 'b--', 'LineWidth', 0.8);
loglog(h_ref, h_ref.^4 * 0.5, 'r--', 'LineWidth', 0.8);
loglog(h_ref, h_ref.^6 * 2, 'g--', 'LineWidth', 0.8);

legend('Trapez R(i,1)', 'Simpson R(i,2)', 'Boole R(i,3)', ...
       'O(h^2)', 'O(h^4)', 'O(h^6)', 'Location', 'SouthEast');
xlabel('Pasul h');
ylabel('Eroarea absoluta');
title('Problema 10(c): Convergenta pentru \int_1^2 ln(x) dx');
grid on;

% salvez in fisier ca sa ramana si daca se inchide fereastra
print('-dpng', 'problema10c_convergenta.png');
fprintf('Grafic salvat: problema10c_convergenta.png\n');
close all;

% Pante estimate
fprintf('\nPante estimate (polyfit log-log):\n');
if sum(idx_t) >= 2
    p = polyfit(log(h_trap(idx_t)), log(err_trap(idx_t)), 1);
    fprintf('  Trapez:  %.2f (teoretic: 2)\n', p(1));
end
if sum(idx_s) >= 2
    p = polyfit(log(h_simp(idx_s)), log(err_simp(idx_s)), 1);
    fprintf('  Simpson: %.2f (teoretic: 4)\n', p(1));
end
if sum(idx_b) >= 2
    p = polyfit(log(h_boole(idx_b)), log(err_boole(idx_b)), 1);
    fprintf('  Boole:   %.2f (teoretic: 6)\n', p(1));
end
fprintf('\n');

%% PROBLEMA 3 - int_0^1 exp(x)/sqrt(x) dx
fprintf('=============================================================\n');
fprintf('  PROBLEMA 3: int_0^1 exp(x)/sqrt(x) dx\n');
fprintf('=============================================================\n\n');

% Valoare de referinta
val_ref = 2.9253035883926652;
fprintf('Valoare de referinta: %.16f\n\n', val_ref);

f_orig = @(x) exp(x) ./ sqrt(x);

%% 3(a) - rezolvare directa
% f(x) = exp(x)/sqrt(x) are singularitate in x=0.
% Evitam x=0, integram pe [eps, 1].
% Romberg converge lent (Euler-Maclaurin nu e valid pt f neneteda).
% Adaptiva merge mai bine, rafineaza automat zona singularitatii.

fprintf('--- (a) Rezolvare directa ---\n\n');

eps_evit = 1e-12;

fprintf('Romberg pe [%.0e, 1]:\n', eps_evit);
[val_rom_a, iter_rom_a, err_rom_a] = my_romberg(f_orig, eps_evit, 1, 1e-9, 15);
fprintf('  Valoare:      %.16f\n', val_rom_a);
fprintf('  Eroare est.:  %.2e\n', err_rom_a);
fprintf('  Iteratii:     %d\n', iter_rom_a);
fprintf('  Eroare reala: %.2e\n\n', abs(val_rom_a - val_ref));

fprintf('Cuadratura adaptiva pe [%.0e, 1]:\n', eps_evit);
[val_adq_a, neval_adq_a] = my_adquad(f_orig, eps_evit, 1, 1e-9);
fprintf('  Valoare:      %.16f\n', val_adq_a);
fprintf('  Evaluari f:   %d\n', neval_adq_a);
fprintf('  Eroare reala: %.2e\n\n', abs(val_adq_a - val_ref));

%% 3(b) - schimbare de variabila
% u = sqrt(x), x = u^2, dx = 2u du
% => int_0^1 exp(u^2)/u * 2u du = 2 * int_0^1 exp(u^2) du
% Integrandul g(u) = 2*exp(u^2) e neted pe [0,1], fara singularitate.

fprintf('--- (b) Schimbare de variabila: u = sqrt(x) ---\n\n');

g_subst = @(u) 2 * exp(u.^2);

fprintf('Romberg pe 2*exp(u^2), [0,1]:\n');
[val_rom_b, iter_rom_b, err_rom_b] = my_romberg(g_subst, 0, 1, 1e-9, 15);
fprintf('  Valoare:      %.16f\n', val_rom_b);
fprintf('  Eroare est.:  %.2e\n', err_rom_b);
fprintf('  Iteratii:     %d\n', iter_rom_b);
fprintf('  Eroare reala: %.2e\n\n', abs(val_rom_b - val_ref));

fprintf('Cuadratura adaptiva pe 2*exp(u^2), [0,1]:\n');
[val_adq_b, neval_adq_b] = my_adquad(g_subst, 0, 1, 1e-9);
fprintf('  Valoare:      %.16f\n', val_adq_b);
fprintf('  Evaluari f:   %d\n', neval_adq_b);
fprintf('  Eroare reala: %.2e\n\n', abs(val_adq_b - val_ref));

%% 3(c) - dezvoltare in serie
% exp(x) = sum x^n/n! => exp(x)/sqrt(x) = sum x^(n-1/2)/n!
% int_0^1 x^(n-1/2) dx = 2/(2n+1)
% => I = sum_{n>=0} 2/((2n+1)*n!)

fprintf('--- (c) Dezvoltare in serie ---\n\n');

tol_serie = 1e-15;
I_serie = 0;
n_term = 0;
factorial_n = 1;
while true
    termen = 2.0 / ((2*n_term + 1) * factorial_n);
    I_serie = I_serie + termen;
    if abs(termen) < tol_serie
        break;
    end
    n_term = n_term + 1;
    factorial_n = factorial_n * n_term;
end

fprintf('Serie analitica I = sum 2/((2n+1)*n!):\n');
fprintf('  Valoare:      %.16f\n', I_serie);
fprintf('  Termeni:      %d\n', n_term + 1);
fprintf('  Eroare reala: %.2e\n\n', abs(I_serie - val_ref));

% Integram numeric si seria trunchiata (dupa substitutie, e neteda)
N_trunc = 30;
f_serie_trunc = @(x) my_serie_exp_sqrt(x, N_trunc);

fprintf('Romberg pe seria trunchiata (%d termeni), [0,1]:\n', N_trunc);
[val_rom_c, iter_rom_c, err_rom_c] = my_romberg(f_serie_trunc, 0, 1, 1e-9, 25);
fprintf('  Valoare:      %.16f\n', val_rom_c);
fprintf('  Eroare est.:  %.2e\n', err_rom_c);
fprintf('  Iteratii:     %d\n', iter_rom_c);
fprintf('  Eroare reala: %.2e\n\n', abs(val_rom_c - val_ref));

fprintf('Cuadratura adaptiva pe seria trunchiata, [0,1]:\n');
[val_adq_c, neval_adq_c] = my_adquad(f_serie_trunc, 0, 1, 1e-9);
fprintf('  Valoare:      %.16f\n', val_adq_c);
fprintf('  Evaluari f:   %d\n', neval_adq_c);
fprintf('  Eroare reala: %.2e\n\n', abs(val_adq_c - val_ref));

%% Tabel comparativ
fprintf('=== COMPARATIE FINALA ===\n');
fprintf('%-35s %20s %12s %10s\n', 'Metoda', 'Valoare', 'Eroare', 'Efort');
fprintf('%s\n', repmat('-', 1, 80));
fprintf('%-35s %20.12f %12.2e %8d it\n', ...
    '(a) Romberg directa', val_rom_a, abs(val_rom_a-val_ref), iter_rom_a);
fprintf('%-35s %20.12f %12.2e %8d ev\n', ...
    '(a) Adaptiva directa', val_adq_a, abs(val_adq_a-val_ref), neval_adq_a);
fprintf('%-35s %20.12f %12.2e %8d it\n', ...
    '(b) Romberg cu substitutie', val_rom_b, abs(val_rom_b-val_ref), iter_rom_b);
fprintf('%-35s %20.12f %12.2e %8d ev\n', ...
    '(b) Adaptiva cu substitutie', val_adq_b, abs(val_adq_b-val_ref), neval_adq_b);
fprintf('%-35s %20.12f %12.2e %8d t\n', ...
    '(c) Serie analitica', I_serie, abs(I_serie-val_ref), n_term+1);
fprintf('%-35s %20.12f %12.2e %8d it\n', ...
    '(c) Romberg pe serie trunc.', val_rom_c, abs(val_rom_c-val_ref), iter_rom_c);
fprintf('%-35s %20.12f %12.2e %8d ev\n', ...
    '(c) Adaptiva pe serie trunc.', val_adq_c, abs(val_adq_c-val_ref), neval_adq_c);
fprintf('%-35s %20.12f\n', 'Referinta', val_ref);
fprintf('\n');

fprintf('Concluzie:\n');
fprintf('  (a) Romberg converge lent din cauza singularitatii, adaptiva mai bine.\n');
fprintf('  (b) Substitutia elimina singularitatea, ambele metode converg rapid.\n');
fprintf('  (c) Seria I = sum 2/((2n+1)*n!) converge in ~20 termeni.\n');

close all;

% Functiile my_romberg, my_adquad, my_adquad_rec, my_serie_exp_sqrt
% sunt definite in fisiere separate (.m) din acelasi director.
