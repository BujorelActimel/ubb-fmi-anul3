%% Cuadraturi de tip Gauss
%% Testul 3 — 7 probleme

clear; clc; close all;
format long;

fprintf('=== CUADRATURI DE TIP GAUSS ===\n\n');

%% =====================================================================
%% PROBLEMA 1: Gauss-Legendre n=10
%% I1 = integral_0^pi sin^2(t) dt  si  I2 = integral_0^pi cos^2(t) dt
%% =====================================================================
%%
%% Gauss-Legendre pe [-1,1]: pondere w(x)=1, mu0=2
%%   a_k = 0   (diagonal zero)
%%   b_k = k / sqrt(4k^2 - 1),  k=1,...,n-1  (subdiagonala)
%%
%% Schimbare de variabila: t = pi*(1+s)/2, dt = pi/2 ds, s in [-1,1]
%%   integral_0^pi f(t) dt = pi/2 * integral_{-1}^{1} f(pi*(1+s)/2) ds
%%   => aprox. prin GL: pi/2 * sum(w_i * f(pi*(1+x_i)/2))
%%
%% Valorile exacte: integral_0^pi sin^2(t)dt = pi/2, integral_0^pi cos^2(t)dt = pi/2

fprintf('--- Problema 1: Gauss-Legendre n=10 ---\n');
fprintf('    Transf.: t = pi*(1+s)/2 mapeaza [0,pi] -> [-1,1]\n');
fprintf('    I = pi/2 * sum(w_i * f(pi*(1+x_i)/2))\n\n');

n1 = 10;
a_gl = zeros(1, n1);
b_gl = zeros(1, n1-1);
for k = 1:n1-1
    b_gl(k) = k / sqrt(4*k^2 - 1);
end
[x_gl, w_gl] = golub_welsch(a_gl, b_gl, 2);

t_gl = pi * (1 + x_gl) / 2;
I1_sin2 = (pi/2) * sum(w_gl .* sin(t_gl).^2);
I1_cos2 = (pi/2) * sum(w_gl .* cos(t_gl).^2);
I1_exact = pi/2;

fprintf('  integral_0^pi sin^2(t) dt:\n');
fprintf('    GL-10  = %.15f\n', I1_sin2);
fprintf('    Exact  = %.15f  (pi/2)\n', I1_exact);
fprintf('    Eroare = %.3e\n', abs(I1_sin2 - I1_exact));
fprintf('  integral_0^pi cos^2(t) dt:\n');
fprintf('    GL-10  = %.15f\n', I1_cos2);
fprintf('    Exact  = %.15f  (pi/2)\n', I1_exact);
fprintf('    Eroare = %.3e\n\n', abs(I1_cos2 - I1_exact));

%% =====================================================================
%% PROBLEMA 2: Gauss-Chebyshev tip 1, precizie eps=1e-10
%% I = integral_{-2}^{2} cos(t) / sqrt(4-t^2) dt
%% =====================================================================
%%
%% Schimbare t = 2s, dt = 2 ds, s in [-1,1]:
%%   integral = integral_{-1}^{1} cos(2s) / sqrt(4 - 4s^2) * 2 ds
%%            = integral_{-1}^{1} cos(2s) / sqrt(1-s^2) ds
%%
%% Gauss-Chebyshev tip 1: integral_{-1}^{1} f(s)/sqrt(1-s^2) ds = sum(w_k * f(x_k))
%%   Noduri:  x_k = cos((2k-1)*pi/(2n)),  k=1,...,n
%%   Ponderi: w_k = pi/n
%%
%% Valoare exacta: integral_{-1}^{1} cos(2s)/sqrt(1-s^2) ds = pi * J_0(2)
%%   (J_0 = functia Bessel de ordinul 0, prin definitia integrala a lui Bessel)

fprintf('--- Problema 2: Gauss-Chebyshev tip 1 (eps=1e-10) ---\n');
fprintf('    Transf.: t=2s => integral_{-1}^{1} cos(2s)/sqrt(1-s^2) ds (GC tip 1)\n');
fprintf('    Mareste n pana |I_n - I_{n-1}| < eps\n\n');

I2_exact = pi * besselj(0, 2);
I2_prev = Inf;
for n2 = 1:10000
    k_gc1 = (1:n2)';
    x_gc1 = cos((2*k_gc1 - 1) * pi / (2*n2));
    w_gc1 = (pi/n2) * ones(n2, 1);
    I2 = sum(w_gc1 .* cos(2*x_gc1));
    if abs(I2 - I2_prev) < 1e-10, break; end
    I2_prev = I2;
end

fprintf('  integral_{-2}^{2} cos(t)/sqrt(4-t^2) dt:\n');
fprintf('    GC1 (n=%d)   = %.15f\n', n2, I2);
fprintf('    Exact pi*J0(2) = %.15f\n', I2_exact);
fprintf('    Eroare = %.3e\n\n', abs(I2 - I2_exact));

%% =====================================================================
%% PROBLEMA 3: Gauss-Chebyshev tip 2, precizie eps=1e-10
%% I = integral_1^2 sqrt(3t-t^2-2) * sin(t) dt
%% =====================================================================
%%
%% Analiza integranda:
%%   3t-t^2-2 = -(t-1)(t-2) = (t-1)(2-t) >= 0 pe [1,2]
%%
%% Schimbare: t = 3/2 + s/2, s in [-1,1], dt = 1/2 ds
%%   t-1 = (1+s)/2,  2-t = (1-s)/2
%%   (t-1)(2-t) = (1-s^2)/4  =>  sqrt(3t-t^2-2) = sqrt(1-s^2)/2
%%
%%   integral = integral_{-1}^{1} (sqrt(1-s^2)/2) * sin(3/2+s/2) * (1/2) ds
%%            = 1/4 * integral_{-1}^{1} sqrt(1-s^2) * sin(3/2+s/2) ds
%%
%% Gauss-Chebyshev tip 2: integral_{-1}^{1} f(s)*sqrt(1-s^2) ds = sum(w_k * f(x_k))
%%   Noduri:  x_k = cos(k*pi/(n+1)),  k=1,...,n
%%   Ponderi: w_k = pi/(n+1) * sin^2(k*pi/(n+1))

fprintf('--- Problema 3: Gauss-Chebyshev tip 2 (eps=1e-10) ---\n');
fprintf('    3t-t^2-2 = (t-1)(2-t); transf. t=3/2+s/2\n');
fprintf('    => 1/4 * integral_{-1}^1 sqrt(1-s^2)*sin(3/2+s/2) ds (GC tip 2)\n\n');

I3_ref = quadgk(@(t) sqrt(max(3*t - t.^2 - 2, 0)) .* sin(t), 1, 2, 'AbsTol', 1e-14);
I3_prev = Inf;
for n3 = 1:10000
    k_gc2 = (1:n3)';
    x_gc2 = cos(k_gc2 * pi / (n3+1));
    w_gc2 = pi/(n3+1) * sin(k_gc2 * pi / (n3+1)).^2;
    I3 = (1/4) * sum(w_gc2 .* sin(3/2 + x_gc2/2));
    if abs(I3 - I3_prev) < 1e-10, break; end
    I3_prev = I3;
end

fprintf('  integral_1^2 sqrt(3t-t^2-2)*sin(t) dt:\n');
fprintf('    GC2 (n=%d)  = %.15f\n', n3, I3);
fprintf('    Ref (quadgk) = %.15f\n', I3_ref);
fprintf('    Eroare = %.3e\n\n', abs(I3 - I3_ref));

%% =====================================================================
%% PROBLEMA 4: Gauss-Hermite, precizie eps=1e-7
%% I = integral_{-inf}^{inf} e^{-t^2-t} * t^2 * cos(t) dt
%% =====================================================================
%%
%% Completarea patratului: -t^2 - t = -(t + 1/2)^2 + 1/4
%% Substitutie u = t + 1/2, t = u - 1/2, dt = du:
%%   I = e^{1/4} * integral_{-inf}^{inf} e^{-u^2} * (u-1/2)^2 * cos(u-1/2) du
%%
%% Gauss-Hermite: integral_{-inf}^{inf} e^{-u^2} f(u) du, mu0 = sqrt(pi)
%%   Recurenta: a_k = 0  (simetrie),  b_k = sqrt(k/2),  k=1,...,n-1
%%   => I ~ e^{1/4} * sum(w_i * (x_i-1/2)^2 * cos(x_i-1/2))
%%
%% Valoare exacta (calcul analitic):
%%   Folosind integral e^{-u^2}cos(au)du = sqrt(pi)*e^{-a^2/4} si derivate:
%%   integral e^{-u^2}*u^2*cos(u)du = sqrt(pi)*e^{-1/4}/4
%%   integral e^{-u^2}*u*sin(u)du   = sqrt(pi)*e^{-1/4}/2   (functii pare/impare)
%%   I_exact = (sqrt(pi)/2) * (cos(0.5) - sin(0.5))

fprintf('--- Problema 4: Gauss-Hermite (eps=1e-7) ---\n');
fprintf('    -t^2-t = -(t+1/2)^2 + 1/4; subst. u=t+1/2\n');
fprintf('    I = e^{1/4} * sum(w_i * (x_i-1/2)^2 * cos(x_i-1/2))\n\n');

I4_exact = sqrt(pi)/2 * (cos(0.5) - sin(0.5));
I4_prev = Inf;
for n4 = 1:200
    a_gh = zeros(1, n4);
    b_gh = sqrt((1:n4-1) / 2);
    [x_gh, w_gh] = golub_welsch(a_gh, b_gh, sqrt(pi));
    I4 = exp(0.25) * sum(w_gh .* (x_gh - 0.5).^2 .* cos(x_gh - 0.5));
    if abs(I4 - I4_prev) < 1e-7, break; end
    I4_prev = I4;
end

fprintf('  integral_{-inf}^{inf} e^{-t^2-t}*t^2*cos(t) dt:\n');
fprintf('    GH (n=%d)    = %.15f\n', n4, I4);
fprintf('    Exact (analitic) = %.15f\n', I4_exact);
fprintf('    I_exact = sqrt(pi)/2*(cos(0.5)-sin(0.5))\n');
fprintf('    Eroare = %.3e\n\n', abs(I4 - I4_exact));

%% =====================================================================
%% PROBLEMA 5: Gauss-Laguerre n=8
%% I(x,y) = integral_0^inf e^{-xt} / (y+t) dt,  x=2, y=5
%% =====================================================================
%%
%% Substitutie u = x*t, t = u/x, dt = du/x:
%%   I = (1/x) * integral_0^inf e^{-u} / (y + u/x) du
%%     = integral_0^inf e^{-u} / (x*y + u) du
%%
%% Gauss-Laguerre: integral_0^inf e^{-u} f(u) du, mu0 = 1
%%   Recurenta: a_k = 2k-1,  b_k = sqrt(k),  k=1,...,n-1
%%   => I ~ sum(w_i / (x*y + x_i))   cu x_i nodurile Laguerre
%%
%% Valoare exacta: I(x,y) = e^{xy} * E_1(xy)
%%   unde E_1 = functia integrala exponentiala de ordin 1

fprintf('--- Problema 5: Gauss-Laguerre n=8 ---\n');
fprintf('    Subst. u=xt => integral_0^inf e^{-u}/(xy+u) du (Gauss-Laguerre)\n\n');

n5 = 8;
a_lag = 2*(1:n5) - 1;        % 1, 3, 5, ..., 2n-1
b_lag = sqrt(1:(n5-1));      % sqrt(1), ..., sqrt(n-1)
[x_lag, w_lag] = golub_welsch(a_lag, b_lag, 1);

xp = 2;  yp = 5;
xy5 = xp * yp;   % = 10
I5 = sum(w_lag ./ (xy5 + x_lag));
I5_exact = exp(xy5) * expint(xy5);   % e^{xy} * E_1(xy)

fprintf('  integral_0^inf e^{-2t}/(5+t) dt  (x=2, y=5, xy=10):\n');
fprintf('    GL-8   = %.15f\n', I5);
fprintf('    Exact (e^{xy}*E1(xy)) = %.15f\n', I5_exact);
fprintf('    Eroare = %.3e\n\n', abs(I5 - I5_exact));

%% =====================================================================
%% PROBLEMA 6: Gauss-Jacobi cu alpha=beta=2
%% I = integral_0^pi f(t) * (cos(t/2))^2 * (sin(t/2))^2 dt,
%%     f(t) = cos(t) / (2 + cos(t))
%% =====================================================================
%%
%% Schimbare x = cos(t), t = arccos(x), dt = -dx/sqrt(1-x^2):
%%   (cos t/2)^2 = (1+x)/2,  (sin t/2)^2 = (1-x)/2
%%   produsul ponderilor: (1+x)(1-x)/4 = (1-x^2)/4
%%
%%   I = integral_{-1}^{1} f(arccos x) * (1-x^2)/4 * dx/sqrt(1-x^2)
%%     = 1/4 * integral_{-1}^{1} f(arccos x) * sqrt(1-x^2) dx
%%
%% f(arccos x) = cos(arccos x)/(2+cos(arccos x)) = x/(2+x)
%%
%% Aceasta este Gauss-Chebyshev tip 2 cu g(x) = x/(2+x), scala 1/4.
%% (Ponderea sqrt(1-x^2) corespunde GC2, care e Jacobi cu alpha=beta=1/2.)
%% Nota: (cos t/2)^2*(sin t/2)^2 = sin^2(t)/4 — ponderea generata de subst. x=cos(t)
%%   se simplifica la GC2 pt alpha=beta=2.

fprintf('--- Problema 6: Gauss-Jacobi alpha=beta=2 (reduce la GC2) ---\n');
fprintf('    Subst. x=cos(t): I = 1/4 * integral_{-1}^1 (x/(2+x))*sqrt(1-x^2) dx\n\n');

I6_ref = quadgk(@(t) cos(t)./(2+cos(t)) .* (cos(t/2)).^2 .* (sin(t/2)).^2, 0, pi);
I6_prev = Inf;
for n6 = 1:10000
    k6 = (1:n6)';
    x6 = cos(k6 * pi / (n6+1));
    w6 = pi/(n6+1) * sin(k6 * pi / (n6+1)).^2;
    I6 = (1/4) * sum(w6 .* (x6 ./ (2 + x6)));
    if abs(I6 - I6_prev) < 1e-10, break; end
    I6_prev = I6;
end

fprintf('  integral_0^pi cos(t)/(2+cos(t)) * (cos t/2)^2 * (sin t/2)^2 dt:\n');
fprintf('    GC2 (n=%d)    = %.15f\n', n6, I6);
fprintf('    Ref (quadgk)  = %.15f\n', I6_ref);
fprintf('    Eroare = %.3e\n\n', abs(I6 - I6_ref));

%% =====================================================================
%% PROBLEMA 7: Ic = integral_0^1 cos(x)/sqrt(x) dx
%%             Is = integral_0^1 sin(x)/sqrt(x) dx
%% =====================================================================
%%
%% Ambele integrale au singularitate integrala la x=0 (1/sqrt(x) -> inf,
%% dar integral_0^1 1/sqrt(x) dx = 2 < inf — singularitate integrala).

fprintf('--- Problema 7: Ic = integral_0^1 cos(x)/sqrt(x) dx ---\n');
fprintf('              Is = integral_0^1 sin(x)/sqrt(x) dx\n');
fprintf('    (singularitate integrala la x=0: 1/sqrt(x) -> inf, dar integrala conv.)\n\n');

Ic_ref = quadgk(@(x) cos(x) ./ sqrt(x), 0, 1, 'AbsTol', 1e-14);
Is_ref = quadgk(@(x) sin(x) ./ sqrt(x), 0, 1, 'AbsTol', 1e-14);
fprintf('  Referinta (quadgk): Ic = %.15f\n', Ic_ref);
fprintf('                      Is = %.15f\n\n', Is_ref);

%% --- 7(a): Cuadratura adaptiva ---
%%
%% Folosim cuadratura adaptiva Gauss-Kronrod (quadgk) care trateaza
%% singularitati integrable la capete. Aceasta rafineaza intervalele
%% adaptiv si evalueaza corect limita la x->0+.

fprintf('  (a) Cuadratura adaptiva (Gauss-Kronrod):\n');
Ic_a = quadgk(@(x) cos(x) ./ sqrt(x), 0, 1, 'AbsTol', 1e-10);
Is_a = quadgk(@(x) sin(x) ./ sqrt(x), 0, 1, 'AbsTol', 1e-10);
fprintf('      Ic = %.15f  eroare = %.3e\n', Ic_a, abs(Ic_a - Ic_ref));
fprintf('      Is = %.15f  eroare = %.3e\n\n', Is_a, abs(Is_a - Is_ref));

%% --- 7(b): Gauss-Legendre cu schimbare x = t^2 ---
%%
%% Schimbare: x = t^2, dx = 2t dt, t in [0,1]
%%   integral_0^1 cos(x)/sqrt(x) dx = integral_0^1 cos(t^2)/t * 2t dt
%%                                  = 2 * integral_0^1 cos(t^2) dt   <- NETEDA!
%%   integral_0^1 sin(x)/sqrt(x) dx = 2 * integral_0^1 sin(t^2) dt
%%
%% Functii Fresnel: integral_0^1 cos(t^2) dt, integral_0^1 sin(t^2) dt
%% Integrandul e acum neted pe [0,1] => GL converge rapid.
%%
%% Aplicam GL pe [0,1]: mapare t = (1+s)/2 pt s in [-1,1]
%%   2*integral_0^1 g(t)dt = integral_{-1}^{1} g((1+s)/2) ds = sum(w_i * g((1+x_i)/2))

fprintf('  (b) GL cu x=t^2 (integrand neted):\n');
fprintf('      cos(x)/sqrt(x) dx -> 2*cos(t^2) dt (fara singularitate!)\n\n');

n7b = 10;
a_gl7 = zeros(1, n7b);
b_gl7 = zeros(1, n7b-1);
for k = 1:n7b-1
    b_gl7(k) = k / sqrt(4*k^2 - 1);
end
[x_gl7, w_gl7] = golub_welsch(a_gl7, b_gl7, 2);

t7 = (1 + x_gl7) / 2;   % t in [0,1]
Ic_b = sum(w_gl7 .* cos(t7.^2));   % = 2*integral_0^1 cos(t^2) dt
Is_b = sum(w_gl7 .* sin(t7.^2));   % = 2*integral_0^1 sin(t^2) dt

fprintf('      GL-10: Ic = %.15f  eroare = %.3e\n', Ic_b, abs(Ic_b - Ic_ref));
fprintf('             Is = %.15f  eroare = %.3e\n\n', Is_b, abs(Is_b - Is_ref));

%% --- 7(c): Gauss-Jacobi cu alpha=0, beta=-1/2 ---
%%
%% Schimbare: x = (1+t)/2, dx = 1/2 dt, t in [-1,1]
%%   sqrt(x) = sqrt((1+t)/2) = (1+t)^{1/2} / sqrt(2)
%%   1/sqrt(x) = sqrt(2) * (1+t)^{-1/2}
%%
%%   integral_0^1 cos(x)/sqrt(x) dx
%%     = integral_{-1}^{1} cos((1+t)/2) * sqrt(2)*(1+t)^{-1/2} * (1/2) dt
%%     = (1/sqrt(2)) * integral_{-1}^{1} cos((1+t)/2) * (1-t)^0 * (1+t)^{-1/2} dt
%%
%% Aceasta este Gauss-Jacobi cu alpha=0, beta=-1/2, scala 1/sqrt(2).
%%   mu0 = integral_{-1}^1 (1+t)^{-1/2} dt = [2*sqrt(1+t)]_{-1}^{1} = 2*sqrt(2)

fprintf('  (c) Gauss-Jacobi cu alpha=0, beta=-1/2:\n');
fprintf('      x=(1+t)/2 => (1/sqrt(2)) * integral_{-1}^1 f(t)*(1+t)^{-1/2} dt\n\n');

n7c = 10;
[a_jac, b_jac, mu0_jac] = jacobi_params(n7c, 0, -0.5);
[x_jac, w_jac] = golub_welsch(a_jac, b_jac, mu0_jac);

Ic_c = (1/sqrt(2)) * sum(w_jac .* cos((1 + x_jac) / 2));
Is_c = (1/sqrt(2)) * sum(w_jac .* sin((1 + x_jac) / 2));

fprintf('      GJacobi-10: Ic = %.15f  eroare = %.3e\n', Ic_c, abs(Ic_c - Ic_ref));
fprintf('                  Is = %.15f  eroare = %.3e\n\n', Is_c, abs(Is_c - Is_ref));

%% Comparatie metode pentru Problema 7
fprintf('  Comparatie metode pt Ic:\n');
fprintf('  %-20s  %-20s  %-12s\n', 'Metoda', 'Ic', 'Eroare');
fprintf('  %-20s  %-20.15f  %.3e\n', 'Adaptiva (quadgk)', Ic_a, abs(Ic_a - Ic_ref));
fprintf('  %-20s  %-20.15f  %.3e\n', 'GL-10 x=t^2', Ic_b, abs(Ic_b - Ic_ref));
fprintf('  %-20s  %-20.15f  %.3e\n', 'GJacobi-10', Ic_c, abs(Ic_c - Ic_ref));
fprintf('\n  Comentariu:\n');
fprintf('  - Metoda (a): functioneaza, dar refineaza zona x~0 intensiv.\n');
fprintf('  - Metoda (b): elimina singularitatea, GL converge rapid (integrand neted).\n');
fprintf('  - Metoda (c): ponderea (1+t)^{-1/2} absorbe singularitatea exacta => n mic.\n');

fprintf('\n=== SFARSIT ===\n');
