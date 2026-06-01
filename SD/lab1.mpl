# Laborator 1

# 1) Calculati:
# a)
12+4-5;
# b)
2^10;
# c)
sin(0.1);
# d)
simplify((a + b)*(a - b));


# 2) Calculati derivatele functiilor:
# a) y (x) = 3x^3 + 2x^2 - 5
restart;
y := x -> 3*x^3 + 2*x^2 - 5;
diff(y(x), x);
# b) y (x) = sqrt(1 + x^4)
restart;
y := x -> sqrt(1 + x^4);
diff(y(x), x);
# c) y (x) = e^x * sin(x) * cos(x)
restart;
y := x -> exp(x) * sin(x) * cos(x);
diff(y(x), x);


# 3) Calculati integralele:
# a) integral de la 0 la 1 din 3x^3 + 2x^2 - 5
restart;
int(3*x^3 + 2*x^2 - 5, x = 0..1);
# b) integral de la 0 la infinit din 1/x^2
restart;
int(1/x^2, x = 0..infinity);
# c) integral de la -infinit la infinit din e^(-x^2)
restart;
int(exp(-x^2), x = -infinity..infinity);


# 4) Calculati limitele:
# a) lim x->0 sin(x)/x
restart;
limit(sin(x)/x, x = 0);
# b) lim x->infinit (x^3 + 3x^2 - 5) / (2x^3 - 7x)
restart;
limit((x^3 + 3*x^2 - 5) / (2*x^3 - 7*x), x = infinity);
# c) lim x->Pi (cos(x) + 1) / (x - Pi)
restart;
limit((cos(x) + 1) / (x - Pi), x = Pi);


# 5) Reprezentati grafic curbele:
# a) f(x) = e^(-x) - 1, x in [-2, 2]
restart;
plotsetup(ps, plotoutput="plots/lab1/5a.ps");
plot(exp(-x) - 1, x = -2..2);
plotsetup(default);
# b) f(x) = 200*e^(r*x) / (2*(e^(r*x) - 1) + 100), x in [0, 50], r = 0.5 si r = -0.5
restart;
f := (x, r) -> 200*exp(r*x) / (2*(exp(r*x) - 1) + 100);
plotsetup(ps, plotoutput="plots/lab1/5b.ps");
plot([f(x, 0.5), f(x, -0.5)], x = 0..50, legend = ["r=0.5", "r=-0.5"]);
plotsetup(default);
# c) f(x) = x * sin(1/x), x in [-3, 3]
restart;
plotsetup(ps, plotoutput="plots/lab1/5c.ps");
plot(x * sin(1/x), x = -3..3, discont = true);
plotsetup(default);


# 6) Reprezentati grafic curbele date in forma parametrica:
# a) Cardioida: x(t) = (1-cos(t))*cos(t), y(t) = (1-cos(t))*sin(t), t in [0, 2*Pi]
restart;
plotsetup(ps, plotoutput="plots/lab1/6a.ps");
plot([(1 - cos(t))*cos(t), (1 - cos(t))*sin(t), t = 0..2*Pi]);
plotsetup(default);
# b) x(t) = sin(3t)*cos(t), y(t) = sin(3t)*sin(t), t in [0, 2*Pi]
restart;
plotsetup(ps, plotoutput="plots/lab1/6b.ps");
plot([sin(3*t)*cos(t), sin(3*t)*sin(t), t = 0..2*Pi]);
plotsetup(default);
# c) Cicloida: x(t) = t - sin(t), y(t) = 1 - cos(t), t in [0, 6*Pi]
restart;
plotsetup(ps, plotoutput="plots/lab1/6c.ps");
plot([t - sin(t), 1 - cos(t), t = 0..6*Pi]);
plotsetup(default);


# 7) f(t,s) = 1 - s*cos(4t)*cos(t) / sqrt(1 - s^2*cos^2(4t)*sin^2(t))
# curba parametrica: x(t) = f(t - Pi/2, s), y(t) = f(t, s), t in [0, 2*Pi]
restart;
f := (t, s) -> 1 - s*cos(4*t)*cos(t) / sqrt(1 - s^2*cos(4*t)^2*sin(t)^2);
# a) s = 0.5
plotsetup(ps, plotoutput="plots/lab1/7a.ps");
plot([f(t - Pi/2, 0.5), f(t, 0.5), t = 0..2*Pi]);
plotsetup(default);
# b) cele 10 curbe pentru s = 0.1, 0.2, ..., 1
plotsetup(ps, plotoutput="plots/lab1/7b.ps");
plots[display](seq(plot([f(t - Pi/2, s/10), f(t, s/10), t = 0..2*Pi]), s = 1..10));
plotsetup(default);


# 8) Reprezentati grafic curbele date in forma implicita:
# a) x^2 + y^2 - 2x - 4y + 4 = 0
restart;
plotsetup(ps, plotoutput="plots/lab1/8a.ps");
plots[implicitplot](x^2 + y^2 - 2*x - 4*y + 4, x = -2..4, y = -1..5);
plotsetup(default);
# b) x^2 - 2xy - y^2 = 1
restart;
plotsetup(ps, plotoutput="plots/lab1/8b.ps");
plots[implicitplot](x^2 - 2*x*y - y^2 - 1, x = -5..5, y = -5..5);
plotsetup(default);


# 9) Reprezentati grafic suprafetele:
# a) z(x,y) = 4x^2*e^y - 2x^4 - e^(4y), -3<=x<=3, -1<=y<=1
restart;
plotsetup(ps, plotoutput="plots/lab1/9a.ps");
plot3d(4*x^2*exp(y) - 2*x^4 - exp(4*y), x = -3..3, y = -1..1);
plotsetup(default);
# b) z(x,y) = 4x^2 - y^2, -100<=x<=100, -100<=y<=100
restart;
plotsetup(ps, plotoutput="plots/lab1/9b.ps");
plot3d(4*x^2 - y^2, x = -100..100, y = -100..100);
plotsetup(default);


# 10) Algebra liniara:
restart;
with(linalg):
A := matrix([[1,2,-1],[0,1,0],[3,-1,2]]);
B := matrix([[1,2,3],[1,1,2],[2,1,1]]);
C := matrix([[2,1,1],[0,1,-1],[4,2,2]]);
# a) 2A - BC
evalm(2*A - B &* C);
# b) B^(-1)
inverse(B);
# c) valorile si vectorii proprii ai matricii C
eigenvalues(C);
eigenvectors(C);
