%% Problema 10: f(x) = cos^2(x) + sin^3(x), [-pi,pi], echidistante, m=9, t=pi/5

clear; clc; close all;
format long;

f  = @(x) cos(x).^2 + sin(x).^3;
df = @(x) -sin(2*x) + 3*sin(x).^2 .* cos(x);

a = -pi;  b = pi;
m = 9;           % m+1 = 10 noduri, polinom de grad m
t = pi/5;

% Noduri echidistante x_0,...,x_m
x_nodes = linspace(a, b, m+1)';
y_nodes = f(x_nodes);
dy_nodes = df(x_nodes);
n = m + 1;       % numarul de noduri

ft_exact = f(t);
fprintf('f(pi/5) exact = %.15f\n\n', ft_exact);

%% -----------------------------------------------------------------------
%% Diferente divizate Newton pentru Lagrange
%% -----------------------------------------------------------------------
dd = zeros(n, n);
dd(:,1) = y_nodes;
for j = 2:n
    for i = 1:n-j+1
        dd(i,j) = (dd(i+1,j-1) - dd(i,j-1)) / (x_nodes(i+j-1) - x_nodes(i));
    end
end

% Evaluare la punct scalar tp (forma Newton)
function val = eval_newton(dd_row, x_nodes, tp)
    n = length(x_nodes);
    val = dd_row(n);
    for k = n-1:-1:1
        val = val * (tp - x_nodes(k)) + dd_row(k);
    end
end

% Evaluare la vector (pentru grafic)
function vals = eval_newton_vec(dd_col, x_nodes, tp_vec)
    n = length(x_nodes);
    vals = zeros(size(tp_vec));
    for idx = 1:length(tp_vec)
        tp = tp_vec(idx);
        v = dd_col(1);
        omega = 1;
        for j = 2:n
            omega = omega * (tp - x_nodes(j-1));
            v = v + dd_col(j) * omega;
        end
        vals(idx) = v;
    end
end

L_t = eval_newton(dd(1,:), x_nodes, t);

fprintf('=== (b) Lagrange ===\n');
fprintf('  L_9(pi/5)   = %.15f\n', L_t);
fprintf('  Eroare pract = %.6e\n\n', abs(L_t - ft_exact));

%% -----------------------------------------------------------------------
%% Hermite prin noduri dublate + diferente divizate
%% z = [x0,x0, x1,x1, ..., xm,xm]  (2n noduri)
%% -----------------------------------------------------------------------
N = 2*n;
z  = zeros(N,1);
fz = zeros(N,1);
for i = 1:n
    z(2*i-1)  = x_nodes(i);
    z(2*i)    = x_nodes(i);
    fz(2*i-1) = y_nodes(i);
    fz(2*i)   = y_nodes(i);
end

hdd = zeros(N,N);
hdd(:,1) = fz;
for j = 2:N
    for i = 1:N-j+1
        if abs(z(i+j-1) - z(i)) < 1e-14
            % Nod dublu: limita diferentei divizate = derivata
            hdd(i,j) = df(z(i));
        else
            hdd(i,j) = (hdd(i+1,j-1) - hdd(i,j-1)) / (z(i+j-1) - z(i));
        end
    end
end

% Evaluare Hermite (forma Newton cu noduri dublate)
function val = eval_hermite(hdd_row, z, tp)
    N = length(z);
    val = hdd_row(1);
    omega = 1;
    for j = 2:N
        omega = omega * (tp - z(j-1));
        val = val + hdd_row(j) * omega;
    end
end

function vals = eval_hermite_vec(hdd_col, z, tp_vec)
    N = length(z);
    vals = zeros(size(tp_vec));
    for idx = 1:length(tp_vec)
        tp = tp_vec(idx);
        v = hdd_col(1);
        omega = 1;
        for j = 2:N
            omega = omega * (tp - z(j-1));
            v = v + hdd_col(j) * omega;
        end
        vals(idx) = v;
    end
end

H_t = eval_hermite(hdd(1,:), z, t);

fprintf('=== (b) Hermite ===\n');
fprintf('  H_19(pi/5)  = %.15f\n', H_t);
fprintf('  Eroare pract = %.6e\n\n', abs(H_t - ft_exact));

%% -----------------------------------------------------------------------
%% (c) Erori teoretice
%% f^(n)(x) = 2^(n-1)*cos(2x+n*pi/2) + (3/4)*sin(x+n*pi/2) - (3^n/4)*sin(3x+n*pi/2)
%% max|f^(n)| <= 2^(n-1) + 3/4 + 3^n/4
%% -----------------------------------------------------------------------
fn_max = @(nn) 2^(nn-1) + 3/4 + 3^nn/4;

omega_t   = prod(t - x_nodes);          % omega_{m+1}(t)
omega_t2  = omega_t^2;

% Lagrange: |R_m(t)| <= |omega_{m+1}(t)| / (m+1)! * max|f^(m+1)|
err_lag_teor = abs(omega_t) / factorial(m+1) * fn_max(m+1);

% Hermite: |R_{2m+1}(t)| <= omega_{m+1}^2(t) / (2m+2)! * max|f^(2m+2)|
err_herm_teor = abs(omega_t2) / factorial(2*m+2) * fn_max(2*m+2);

fprintf('=== (c) Erori teoretice (margini superioare) ===\n');
fprintf('  Lagrange  |omega_10(t)| = %.6e\n', abs(omega_t));
fprintf('  max|f^10|               = %.6e\n', fn_max(m+1));
fprintf('  Eroare teor Lagrange   <= %.6e\n', err_lag_teor);
fprintf('  Eroare pract Lagrange   = %.6e\n\n', abs(L_t - ft_exact));

fprintf('  Hermite   omega_10^2(t) = %.6e\n', abs(omega_t2));
fprintf('  max|f^20|               = %.6e\n', fn_max(2*m+2));
fprintf('  Eroare teor Hermite    <= %.6e\n', err_herm_teor);
fprintf('  Eroare pract Hermite    = %.6e\n\n', abs(H_t - ft_exact));

%% -----------------------------------------------------------------------
%% (a) Grafic: f, Lagrange, Hermite
%% -----------------------------------------------------------------------
x_plot = linspace(a, b, 600);
y_f    = f(x_plot);
y_Lp   = eval_newton_vec(dd(1,:)', x_nodes, x_plot);
y_Hp   = eval_hermite_vec(hdd(1,:)', z, x_plot);

figure('Name','Problema 10','Position',[100 100 950 500]);
plot(x_plot, y_f,  'k-',  'LineWidth', 2.0); hold on;
plot(x_plot, y_Lp, 'b--', 'LineWidth', 1.5);
plot(x_plot, y_Hp, 'r:',  'LineWidth', 1.8);
plot(x_nodes, y_nodes, 'ko', 'MarkerSize',7, 'MarkerFaceColor','k');
plot(t, ft_exact, 'g*', 'MarkerSize',12, 'LineWidth',2);
ylim([-2.5 2.5]);
xlabel('x'); ylabel('y');
title('f(x) = cos^2(x) + sin^3(x) — Lagrange si Hermite, m=9, echidistante');
legend('f(x)', 'Lagrange L_9', 'Hermite H_{19}', ...
       'Noduri', 't = \pi/5', 'Location','NorthEast');
grid on;

print('-dpng', 'problema10_interp.png');
fprintf('Grafic salvat: problema10_interp.png\n');
close all;
