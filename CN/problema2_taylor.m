%% Testul 2: Problema 3 (Higham) + Problema 4 (Lorentz)
%% Ref: N.J. Higham, "Accuracy and Stability of Numerical Algorithms", 2002.

clear; clc; close all;
format long;

%% =====================================================================
%% PROBLEMA 3 - Functia Higham
%% =====================================================================
fprintf('=== PROBLEMA 3: Functia Higham ===\n');
fprintf('Algoritm: aplica sqrt de 52 ori, apoi ridica la patrat de 52 ori.\n');
fprintf('Teoretic: (x^(1/2^52))^(2^52) = x pentru orice x > 0.\n\n');

fprintf('--- Ce se intampla ---\n\n');

fprintf('Pasul 1: dupa 52 sqrt, valoarea intermediara este:\n');
fprintf('   y_inter = fl(x^(2^-52))\n');
fprintf('   Teoretic: x^(2^-52) = 1 + ln(x)/2^52 + O(ln(x)^2 / 2^104)  (Taylor in 1)\n\n');

fprintf('Pasul 2: in IEEE 754 double, numerele din vecinatatea lui 1.0 sunt:\n');
fprintf('   ..., 1-eps, 1.0, 1+eps, 1+2*eps, ...\n');
fprintf('   unde eps = 2^-52 = %.4e (epsilon masina).\n', eps);
fprintf('   Cel mai mic numar > 1.0: 1 + eps = 1 + 2^-52.\n');
fprintf('   ORICE valoare din (1.0, 1.0 + eps/2) se rotunjeste la 1.0 exact.\n\n');

fprintf('Pasul 3: y_inter se rotunjeste la 1.0 daca si numai daca\n');
fprintf('   ln(x)/2^52 < eps/2 = 2^-53\n');
fprintf('   <=>  ln(x) < 1/2\n');
fprintf('   <=>  x < e^(1/2) = %.10f\n\n', exp(0.5));

fprintf('Pasul 4: pentru x suficient de mare, y_inter = 1 + k*eps, k = 1,2,...\n');
fprintf('   Dupa 52 patrate: y_inter^(2^52) = (1 + k*eps)^(2^52)\n');
fprintf('   Deoarece (1+t)^(1/t) -> e cand t->0, avem:\n');
fprintf('   (1 + k*eps)^(2^52) = (1 + k*eps)^(1/(k*eps)) ^k = e^k (aproximativ)\n');
fprintf('   Deci Higham(x) ≈ e^k, unde k = nr. de eps-uri in y_inter.\n\n');

% Calculul lui k in functie de x
fprintf('--- Identificarea pragului si comportamentului pe trepte ---\n\n');

x_thresh = exp(0.5);
fprintf('Pragul teoretic (rounding teoretic, fara erori de sqrt): e^(1/2) = %.6f\n', x_thresh);
fprintf('(In practica, erorile acumulate in 52 sqrt pot deplasa pragul usor.)\n\n');

fprintf('Valori intermediare si nr. de eps:\n');
fprintf('  %-8s  %-10s  %-14s  %-18s  %-12s\n', ...
        'x', 'y-1 (eps)', 'k = round', 'Higham(x)', 'Higham ≈ e^k?');
for xv = [1.2, 1.5, exp(0.5), 1.7, 2.0, exp(1), 3.0, exp(1.5), 5.0, exp(2), 10.0]
    y_inter = xv;
    for i=1:52, y_inter = sqrt(y_inter); end
    k_float  = (y_inter - 1) / eps;
    k_int    = round(k_float);
    hv       = Higham(xv);
    ek       = exp(k_int);
    if k_int == 0
        interp = 'DA -> rotunjit la 1.0!';
    else
        interp = sprintf('Higham≈e^%d=%.3f', k_int, ek);
    end
    fprintf('  %-8.4f  %-10.4f  %-14d  %-18.6f  %s\n', ...
            xv, k_float, k_int, hv, interp);
end
fprintf('\n');

fprintf('CONCLUZIE:\n');
fprintf('  (a) Pentru x < e^(1/2) ≈ 1.649: y_inter = 1.0 exact,\n');
fprintf('      deci Higham(x) = 1^(2^52) = 1 ≠ x. Informatia despre x e PIERDUTA.\n\n');
fprintf('  (b) Pentru x mai mare: y_inter = 1 + k*eps (k = 1, 2, 3, ...)\n');
fprintf('      Higham(x) ≈ e^k, care DIFERA de x in general.\n');
fprintf('      Functia ia valori DISCRETE: 1, e, e^2, e^3, ...\n\n');
fprintf('  (c) y ≈ x NUMAI in punctele x ≈ e^k (unde treapta intalneste dreapta y=x):\n');
fprintf('      x ≈ 1, e ≈ 2.718, e^2 ≈ 7.389, ...\n\n');
fprintf('  (d) Fenomenul se datoreaza preciziei finite a virgulei flotante:\n');
fprintf('      exponentul lui x (informatia in ln(x)) se "cuantizeaza"\n');
fprintf('      la multipli de eps * ln2 = ln(1+eps) in double precision.\n\n');

%% --- Grafic ---
x = logspace(0, 1, 2013);
y = Higham(x);

figure('Position',[100 100 900 480]);
plot(x, y, 'b.', 'MarkerSize', 4); hold on;
plot(x, x, 'r--', 'LineWidth', 1.5);
% Marcam valorile discrete e^k
for k=0:2
    yline(exp(k), 'g:', 'LineWidth', 1.2);
    text(9.5, exp(k)+0.15, sprintf('e^{%d}=%.2f', k, exp(k)), ...
         'Color','g','FontSize',8);
end
% Marcam x≈e^k pe axa x
for k=1:2
    xline(exp(k), 'm:', 'LineWidth', 1.2);
end
xlabel('x'); ylabel('Higham(x)');
title({'Higham(x): functie cu trepte datorate preciziei double', ...
       'Higham(x) ≈ e^k (discret), y ≈ x numai la x ≈ e^k'});
legend('Higham(x)', 'y=x (ideal)', 'Valori discrete e^k', ...
       'Location','northwest');
grid on;  ylim([0 11]);
print('-dpng','problema3_higham.png');
fprintf('Grafic salvat: problema3_higham.png\n\n');
close all;

%% =====================================================================
%% PROBLEMA 4 - Factorul Lorentz
%% =====================================================================
fprintf('=== PROBLEMA 4: Factorul Lorentz ===\n\n');
fprintf('Calculam gamma = 1/sqrt(1 - v^2/c^2) pentru v = 100.000 km/h.\n\n');

c = 299792458;
v_kmh = 100000;            % 100.000 km/h
v     = v_kmh * 1000/3600; % m/s
r     = v / c;

fprintf('Date: v = 100.000 km/h = %.10f m/s,  c = %d m/s\n', v, c);
fprintf('  r = v/c = %.15e\n', r);
fprintf('  r^2    = %.15e\n\n', r^2);

%% --- Cifre semnificative ---
fprintf('--- Cifre semnificative ale datei de intrare ---\n\n');
fprintf('"100.000 km/h": punctul zecimal indica 6 cifre semnificative.\n');
fprintf('  Eroare relativa in v:      delta_v/v ~ 5e-6\n');
fprintf('  Eroare relativa in r=v/c:  delta_r/r ~ 5e-6  (aceeasi)\n');
fprintf('  Eroare relativa in r^2:    delta_r2/r2 = 2*delta_r/r ~ 1e-5\n');
fprintf('  Eroare relativa in gamma-1 ≈ r^2/2:  ~ 1e-5\n');
fprintf('  => Din punct de vedere FIZIC avem nevoie de max. ~5 cifre in gamma-1.\n\n');

%% --- Analiza numerica ---
fprintf('--- Analiza anularii (catastrophic cancellation) ---\n\n');

fprintf('Formula directa calculeaza  1 - r^2:\n');
fprintf('  r^2           = %.15e\n', r^2);
fprintf('  1 - r^2       = %.15f\n', 1 - r^2);
fprintf('\n');
fprintf('CE SE INTAMPLA: 1.0 si r^2 ≈ 8.6e-9 se scad. In double, 1.0 e stocat cu\n');
fprintf('precizie eps ≈ 2.2e-16 (relativ). Deci 1.0 are eroare absoluta ~ eps ≈ 2.2e-16.\n');
fprintf('Dar r^2 ≈ 8.6e-9 >> eps, deci prima zecimala semnificativa a lui 1-r^2\n');
fprintf('apare la pozitia %d, iar precizia double ofera doar ~%d cifre semnif. in 1-r^2.\n\n', ...
        ceil(-log10(r^2)), round(15 + log10(r^2)));

n_pierdute = ceil(-log10(r^2)) - 1;   % cate cifre s-au anulat
n_ramase   = 15 - n_pierdute;

fprintf('  Cifre totale double:        ~15\n');
fprintf('  Cifre anulate de 1.0:       ~%d  (primele zecimale sunt 0.9999...)\n', n_pierdute);
fprintf('  Cifre semnificative in (1-r^2): ~%d\n', n_ramase);
fprintf('  Cifre semnificative in gamma-1 (formula directa): ~%d\n\n', n_ramase);

%% --- Calcule ---
gamma_direct  = 1 / sqrt(1 - r^2);
gamma_t2      = 1 + r^2/2;
gamma_t4      = 1 + r^2/2 + 3*r^4/8;
gamma_ref     = 1 + r^2/2 + 3*r^4/8 + 5*r^6/16 + 35*r^8/128;  % ord 8

fprintf('--- Rezultate (gamma si gamma-1) ---\n\n');
fprintf('  %-32s  %-24s  %-20s\n', 'Metoda', 'gamma', 'gamma - 1');
fprintf('  %-32s  %-24.15f  %.15e\n', '1/sqrt(1-r^2)  (directa)', ...
        gamma_direct, gamma_direct - 1);
fprintf('  %-32s  %-24.15f  %.15e\n', '1 + r^2/2  (Taylor ord.2)', ...
        gamma_t2, r^2/2);
fprintf('  %-32s  %-24.15f  %.15e\n', '1 + r^2/2 + 3r^4/8  (ord.4)', ...
        gamma_t4, gamma_t4 - 1);
fprintf('  %-32s  %-24.15f  %.15e\n', 'Referinta (Taylor ord.8)', ...
        gamma_ref, gamma_ref - 1);
fprintf('\n');

trunc_t2 = 3*r^4/8;  % eroarea de trunchiere Taylor ord.2

fprintf('Comparatie gamma-1 (valori absolute, mai relevante decat gamma):\n');
fprintf('  Taylor ord 2 - direct:  %.3e  (= eroarea de trunchiere 3r^4/8 = %.3e)\n', ...
        abs(r^2/2 - (gamma_direct-1)), trunc_t2);
fprintf('  Taylor ord 4 - direct:  %.3e\n\n', abs((gamma_t4-1) - (gamma_direct-1)));
fprintf('Obs: pentru v = 100 km/h, toate formulele dau acelasi rezultat double\n');
fprintf('deoarece r = v/c este inca suficient de mare. Exemplu extrem:\n');
r_mic = (1000/3600) / 299792458;  % v = 1 km/h
fprintf('  v = 1 km/h: r = %.3e, r^2 = %.3e\n', r_mic, r_mic^2);
fprintf('  1 - r^2 = %.15f  (pierde ~%d cifre!)\n', 1-r_mic^2, round(-log10(r_mic^2)));
fprintf('  gamma-1 direct  = %.15e\n', 1/sqrt(1-r_mic^2) - 1);
fprintf('  gamma-1 Taylor2 = %.15e\n\n', r_mic^2/2);

%% --- Este MATLAB suficient de precis? ---
fprintf('--- Raspuns la intrebare: este MATLAB suficient de precis? ---\n\n');
fprintf('Datele de intrare (v = 100.000 km/h) au ~6 cifre semnificative.\n');
fprintf('Efectul relativist de interes: gamma-1 ≈ %.3e.\n', gamma_ref - 1);
fprintf('Eroarea fizica in gamma-1 (datorata preciziei lui v): ~ 1e-5 * %.3e = %.3e\n', ...
        gamma_ref-1, 1e-5*(gamma_ref-1));
fprintf('\n');
fprintf('Formula directa    ofera ~%d cifre semnif. in gamma-1 => ', n_ramase);
if n_ramase >= 5
    fprintf('SUFICIENTA, dar fara rezerva.\n');
else
    fprintf('INSUFICIENTA!\n');
end
fprintf('Taylor ord 2       ofera ~15 cifre semnif. in gamma-1 => MULT mai precisa.\n');
fprintf('\n');
fprintf('CONCLUZIE: formula directa sufera de anulare si pierde ~%d cifre,\n', n_pierdute);
fprintf('dar ramane suficienta pentru precizia fizica data de v (6 cifre).\n');
fprintf('Taylor elimina anularea: calculeaza gamma-1 = r^2/2 DIRECT, fara\n');
fprintf('scadere din 1, pastrind precizia completa a lui r^2.\n');
fprintf('RECOMANDAT: Taylor ord 2  pentru orice v << c.\n');
