%% Problema 6: Constanta lui Euler - determinare c si d prin CMMP
% gamma - gamma_n ~ c*n^(-d)
% Logaritmand: ln(gamma_n - gamma) = ln(c) - d*ln(n)  =>  regresie liniara

clear; clc; close all;
format long;

gamma_exact = 0.5772156649015328606;

%% Calcul gamma_n pentru n in scara logaritmica
n_vals = unique(round(logspace(1, 4, 150)))';
m = length(n_vals);

gamma_n = zeros(m, 1);
for i = 1:m
    n = n_vals(i);
    gamma_n(i) = sum(1./(1:n)) - log(n);
end

% gamma_n > gamma pentru orice n finit (converge de sus)
err = gamma_n - gamma_exact;

fprintf('Primele valori:\n');
fprintf('%8s  %20s  %15s\n', 'n', 'gamma_n', 'gamma_n - gamma');
for i = 1:5
    fprintf('%8d  %20.15f  %15.2e\n', n_vals(i), gamma_n(i), err(i));
end
fprintf('\n');

%% Regresia liniara log-log: ln(err) = ln(c) - d*ln(n)
X = log(n_vals);
Y = log(err);

% Sistemul supradeterminat: [1, X] * [A; B] = Y  =>  CMMP
A_mat = [ones(m,1), X];
coef = A_mat \ Y;   % echivalent cu (A'A)^{-1} A'Y

A = coef(1);   % = ln(c)
B = coef(2);   % = -d

c = exp(A);
d = -B;

% Eroarea de fit
Y_fit = A + B*X;
reziduu = norm(Y - Y_fit) / sqrt(m);

fprintf('=== Rezultate CMMP ===\n');
fprintf('  c = %.8f   (teoretic: 1/2 = 0.5)\n', c);
fprintf('  d = %.8f   (teoretic: 1)\n', d);
fprintf('  Reziduu RMSE log: %.2e\n\n', reziduu);
fprintf('Interpretare: gamma_n - gamma ≈ %.6f * n^(-%.6f)\n', c, d);

%% Grafice
figure('Name', 'Problema 6 - Euler', 'Position', [100 100 1000 450]);

subplot(1,2,1);
loglog(n_vals, err, 'b.', 'MarkerSize', 5);
hold on;
loglog(n_vals, c * n_vals.^(-d), 'r-', 'LineWidth', 2);
loglog(n_vals, 0.5 * n_vals.^(-1), 'k--', 'LineWidth', 1.2);
xlabel('n');
ylabel('\gamma_n - \gamma');
title('Eroarea \gamma_n - \gamma (scara log-log)');
legend('Date', sprintf('%.5f \\cdot n^{-%.5f}', c, d), ...
       '0.5 \cdot n^{-1} (teoretic)', 'Location', 'SouthWest');
grid on;

subplot(1,2,2);
plot(X, Y, 'b.', 'MarkerSize', 5);
hold on;
plot(X, A + B*X, 'r-', 'LineWidth', 2);
xlabel('ln(n)');
ylabel('ln(\gamma_n - \gamma)');
title(sprintf('Regresia liniara: panta = %.5f', B));
legend('Date', sprintf('Fit: %.4f + %.4f \\cdot ln(n)', A, B), ...
       'Location', 'SouthWest');
grid on;

print('-dpng', 'problema6_euler.png');
fprintf('\nGrafic salvat: problema6_euler.png\n');
close all;
