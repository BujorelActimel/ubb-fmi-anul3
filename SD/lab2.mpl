# Laborator 2

# 1) Solutii generale si reprezentare cateva solutii:
# a) y' = 2x(1 + y^2)
restart;
ode := diff(y(x), x) = 2*x*(1 + y(x)^2);
dsolve(ode, y(x));
plotsetup(ps, plotoutput="plots/lab2/1a.ps");
DEtools[DEplot](ode, y(x), x=-2..2, [[0,-1],[0,0],[0,1]], y=-3..3);
plotsetup(default);
# b) (x^2-1)*y' + 2x*y^2 = 0
restart;
ode := (x^2 - 1)*diff(y(x), x) + 2*x*y(x)^2 = 0;
dsolve(ode, y(x));
plotsetup(ps, plotoutput="plots/lab2/1b.ps");
DEtools[DEplot](ode, y(x), x=-0.9..0.9, [[0,0.5],[0,1],[0,-0.5]], y=-3..3);
plotsetup(default);
# c) 2x^2*y' = x^2 + y^2
restart;
ode := 2*x^2*diff(y(x), x) = x^2 + y(x)^2;
dsolve(ode, y(x));
plotsetup(ps, plotoutput="plots/lab2/1c.ps");
DEtools[DEplot](ode, y(x), x=0.5..3, [[1,0.5],[1,1],[1,-0.5]], y=-3..3);
plotsetup(default);
# d) y' = -x/y
restart;
ode := diff(y(x), x) = -x/y(x);
dsolve(ode, y(x));
plotsetup(ps, plotoutput="plots/lab2/1d.ps");
DEtools[DEplot](ode, y(x), x=-2..2, [[0,1],[0,2],[0,1.5]], y=-3..3);
plotsetup(default);
# e) y' = -x/y^3
restart;
ode := diff(y(x), x) = -x/y(x)^3;
dsolve(ode, y(x));
plotsetup(ps, plotoutput="plots/lab2/1e.ps");
DEtools[DEplot](ode, y(x), x=-2..2, [[0,1],[0,2],[0,1.5]], y=-3..3);
plotsetup(default);
# f) y' = -(x+y)/y
restart;
ode := diff(y(x), x) = -(x + y(x))/y(x);
dsolve(ode, y(x));
plotsetup(ps, plotoutput="plots/lab2/1f.ps");
DEtools[DEplot](ode, y(x), x=-2..2, [[0,1],[0,2],[0,1.5]], y=-3..3);
plotsetup(default);
# g) y' + y*tan(x) = 1/cos(x)
restart;
ode := diff(y(x), x) + y(x)*tan(x) = 1/cos(x);
dsolve(ode, y(x));
plotsetup(ps, plotoutput="plots/lab2/1g.ps");
DEtools[DEplot](ode, y(x), x=-1.4..1.4, [[0,0],[0,1],[0,-1]], y=-3..3);
plotsetup(default);
# h) y' + (2/x)*y = x^3
restart;
ode := diff(y(x), x) + (2/x)*y(x) = x^3;
dsolve(ode, y(x));
plotsetup(ps, plotoutput="plots/lab2/1h.ps");
DEtools[DEplot](ode, y(x), x=0.5..3, [[1,0],[1,1],[1,-1]], y=-3..3);
plotsetup(default);
# i) y'' + y = sin(x) + cos(x)
restart;
ode := diff(y(x), x, x) + y(x) = sin(x) + cos(x);
dsolve(ode, y(x));
s1 := rhs(dsolve({ode, y(0)=0, D(y)(0)=0}, y(x)));
s2 := rhs(dsolve({ode, y(0)=1, D(y)(0)=0}, y(x)));
s3 := rhs(dsolve({ode, y(0)=0, D(y)(0)=1}, y(x)));
plotsetup(ps, plotoutput="plots/lab2/1i.ps");
plot([s1, s2, s3], x=-3..3, y=-5..5);
plotsetup(default);
# j) y'' - y = e^(2x)
restart;
ode := diff(y(x), x, x) - y(x) = exp(2*x);
dsolve(ode, y(x));
s1 := rhs(dsolve({ode, y(0)=0, D(y)(0)=0}, y(x)));
s2 := rhs(dsolve({ode, y(0)=1, D(y)(0)=0}, y(x)));
s3 := rhs(dsolve({ode, y(0)=0, D(y)(0)=1}, y(x)));
plotsetup(ps, plotoutput="plots/lab2/1j.ps");
plot([s1, s2, s3], x=-2..2, y=-5..5);
plotsetup(default);
# k) y'' + 4y = 1/cos(2x)
restart;
ode := diff(y(x), x, x) + 4*y(x) = 1/cos(2*x);
dsolve(ode, y(x));
s1 := rhs(dsolve({ode, y(0)=0, D(y)(0)=0}, y(x)));
s2 := rhs(dsolve({ode, y(0)=1, D(y)(0)=0}, y(x)));
s3 := rhs(dsolve({ode, y(0)=0, D(y)(0)=1}, y(x)));
plotsetup(ps, plotoutput="plots/lab2/1k.ps");
plot([s1, s2, s3], x=-0.7..0.7, y=-5..5);
plotsetup(default);
# l) y'' - y' = 1/(1+e^x)
restart;
ode := diff(y(x), x, x) - diff(y(x), x) = 1/(1 + exp(x));
dsolve(ode, y(x));
s1 := rhs(dsolve({ode, y(0)=0, D(y)(0)=0}, y(x)));
s2 := rhs(dsolve({ode, y(0)=1, D(y)(0)=0}, y(x)));
s3 := rhs(dsolve({ode, y(0)=0, D(y)(0)=1}, y(x)));
plotsetup(ps, plotoutput="plots/lab2/1l.ps");
plot([s1, s2, s3], x=-3..3, y=-5..5);
plotsetup(default);


# 2) Probleme Cauchy:
# a) y' = 1 + y^2, y(0) = 1
restart;
ode := diff(y(x), x) = 1 + y(x)^2;
sol := dsolve({ode, y(0) = 1}, y(x));
plotsetup(ps, plotoutput="plots/lab2/2a.ps");
plot(rhs(sol), x=-0.5..0.5);
plotsetup(default);
# b) y' = 1/(1-x^2)*y + 1 + x, y(0) = 0
restart;
ode := diff(y(x), x) = 1/(1 - x^2)*y(x) + 1 + x;
sol := dsolve({ode, y(0) = 0}, y(x));
plotsetup(ps, plotoutput="plots/lab2/2b.ps");
plot(rhs(sol), x=-0.9..0.9);
plotsetup(default);
# c) y' - 2y = -x^2, y(0) = 1/4
restart;
ode := diff(y(x), x) - 2*y(x) = -x^2;
sol := dsolve({ode, y(0) = 1/4}, y(x));
plotsetup(ps, plotoutput="plots/lab2/2c.ps");
plot(rhs(sol), x=-2..2);
plotsetup(default);
# d) y'' - 5y' + 4y = 0, y(0) = 5, y'(0) = 8
restart;
ode := diff(y(x), x, x) - 5*diff(y(x), x) + 4*y(x) = 0;
sol := dsolve({ode, y(0) = 5, D(y)(0) = 8}, y(x));
plotsetup(ps, plotoutput="plots/lab2/2d.ps");
plot(rhs(sol), x=0..2);
plotsetup(default);
# e) y'' - 4y' + 5y = 2x^2*e^x, y(0) = 2, y'(0) = 3
restart;
ode := diff(y(x), x, x) - 4*diff(y(x), x) + 5*y(x) = 2*x^2*exp(x);
sol := dsolve({ode, y(0) = 2, D(y)(0) = 3}, y(x));
plotsetup(ps, plotoutput="plots/lab2/2e.ps");
plot(rhs(sol), x=0..3);
plotsetup(default);
# f) y'' + 4y = 4*(sin(2x) + cos(2x)), y(Pi) = 2*Pi, y'(Pi) = 2*Pi
restart;
ode := diff(y(x), x, x) + 4*y(x) = 4*(sin(2*x) + cos(2*x));
sol := dsolve({ode, y(Pi) = 2*Pi, D(y)(Pi) = 2*Pi}, y(x));
plotsetup(ps, plotoutput="plots/lab2/2f.ps");
plot(rhs(sol), x=0..2*Pi);
plotsetup(default);


# 3) y'(x) - (1/2)*y(x) = cos(x)
# a) Campul de directii
restart;
ode := diff(y(x), x) - y(x)/2 = cos(x);
plotsetup(ps, plotoutput="plots/lab2/3a.ps");
DEtools[dfieldplot](ode, y(x), x=-3..3, y=-3..3);
plotsetup(default);
# b) a astfel incat solutia cu y(0) = a sa fie periodica (termenul exp(x/2) dispare)
sol_gen := dsolve(ode, y(x));
part := subs(_C1 = 0, rhs(sol_gen));
a_periodic := subs(x = 0, part);
print("a pentru solutie periodica:", a_periodic);


# 4) y'(x) = a*y(x) + b, a in R*, b in R
# a) Solutia generala
restart;
ode := diff(y(x), x) = a*y(x) + b;
sol_gen := dsolve(ode, y(x));
# b) m pentru solutii constante: y' = 0 => a*y + b = 0 => y = -b/a
m_const := -b/a;
print("m pentru solutii constante:", m_const);
# c) a si b cu y(0) = 1 si trece prin (2, 2e^2-1) si (3, 2e^3-1)
sol_cauchy := dsolve({ode, y(0) = 1}, y(x));
eq1 := subs(x = 2, rhs(sol_cauchy)) = 2*exp(2) - 1;
eq2 := subs(x = 3, rhs(sol_cauchy)) = 2*exp(3) - 1;
params := solve({eq1, eq2}, {a, b});
sol_specific := subs(params, rhs(sol_cauchy));
plotsetup(ps, plotoutput="plots/lab2/4c.ps");
plot(sol_specific, x=0..4);
plotsetup(default);


# 5) y'' - y' - 2y = 0, y(0) = a, y'(0) = 2, y(x)->0 pentru x->+inf
restart;
ode := diff(y(x), x, x) - diff(y(x), x) - 2*y(x) = 0;
sol_gen := dsolve(ode, y(x));
eq_y0  := subs(x = 0, rhs(sol_gen)) = a;
eq_dy0 := subs(x = 0, diff(rhs(sol_gen), x)) = 2;
ICs := solve({eq_y0, eq_dy0}, {c__1, c__2});
a_val := solve(subs(ICs, c__1) = 0, a);
print("a =", a_val);
sol_final := simplify(subs(a = a_val, subs(ICs, rhs(sol_gen))));
plotsetup(ps, plotoutput="plots/lab2/5.ps");
plot(sol_final, x=0..4);
plotsetup(default);
