# Laborator 3: Sisteme de ecuatii diferentiale

# Exercise 1: Solutii generale:
# a) x' = x + 4y, y' = x + y
restart;
sys := {diff(x(t),t) = x(t) + 4*y(t), diff(y(t),t) = x(t) + y(t)};
dsolve(sys, {x(t), y(t)});
# b) x' = 2x - y, y' = x + 2y
restart;
sys := {diff(x(t),t) = 2*x(t) - y(t), diff(y(t),t) = x(t) + 2*y(t)};
dsolve(sys, {x(t), y(t)});
# c) x' = x - y + z, y' = x + y + z, z' = -y + 2z
restart;
sys := {diff(x(t),t) = x(t) - y(t) + z(t), diff(y(t),t) = x(t) + y(t) + z(t), diff(z(t),t) = -y(t) + 2*z(t)};
dsolve(sys, {x(t), y(t), z(t)});
# d) x' = 5x + 3y + 1, y' = -6x - 4y + e^(-t)
restart;
sys := {diff(x(t),t) = 5*x(t) + 3*y(t) + 1, diff(y(t),t) = -6*x(t) - 4*y(t) + exp(-t)};
dsolve(sys, {x(t), y(t)});
# e) x' = x + 3y + cos(t), y' = x - y + 2t
restart;
sys := {diff(x(t),t) = x(t) + 3*y(t) + cos(t), diff(y(t),t) = x(t) - y(t) + 2*t};
dsolve(sys, {x(t), y(t)});
# f) x' = x - 2y - 2z + e^(-t), y' = -2x + y + 2z, z' = 2x - y - 3z + e^(-t)
restart;
sys := {diff(x(t),t) = x(t) - 2*y(t) - 2*z(t) + exp(-t), diff(y(t),t) = -2*x(t) + y(t) + 2*z(t), diff(z(t),t) = 2*x(t) - y(t) - 3*z(t) + exp(-t)};
dsolve(sys, {x(t), y(t), z(t)});


# Exercise 2: Probleme Cauchy cu reprezentare grafica:
# a) x' = x + 4y, y' = x + y, x(0)=1, y(0)=2
restart;
sys := {diff(x(t),t) = x(t) + 4*y(t), diff(y(t),t) = x(t) + y(t)};
sol := dsolve({op(sys), x(0)=1, y(0)=2}, {x(t), y(t)});
xt := subs(sol, x(t));  yt := subs(sol, y(t));
plotsetup(ps, plotoutput="plots/lab3/2a.ps");
plot([xt, yt], t=0..1, legend=["x(t)", "y(t)"]);
plotsetup(default);
# b) x' = x - y + t - 1, y' = -2x + 4y + cos(t), x(0)=0, y(0)=1
restart;
sys := {diff(x(t),t) = x(t) - y(t) + t - 1, diff(y(t),t) = -2*x(t) + 4*y(t) + cos(t)};
sol := dsolve({op(sys), x(0)=0, y(0)=1}, {x(t), y(t)});
xt := subs(sol, x(t));  yt := subs(sol, y(t));
plotsetup(ps, plotoutput="plots/lab3/2b.ps");
plot([xt, yt], t=0..1, legend=["x(t)", "y(t)"]);
plotsetup(default);
# c) x' = x + 2y + e^(-t), y' = -2x + y + 1, x(0)=0, y(0)=1
restart;
sys := {diff(x(t),t) = x(t) + 2*y(t) + exp(-t), diff(y(t),t) = -2*x(t) + y(t) + 1};
sol := dsolve({op(sys), x(0)=0, y(0)=1}, {x(t), y(t)});
xt := subs(sol, x(t));  yt := subs(sol, y(t));
plotsetup(ps, plotoutput="plots/lab3/2c.ps");
plot([xt, yt], t=0..2, legend=["x(t)", "y(t)"]);
plotsetup(default);
# d) x' = -x + 3y + 3z + 27t^2, y' = 2x - 2y - 5z + 3t, z' = -2x + 3y + 6z + 3
# x(0)=50, y(0)=-30, z(0)=26
restart;
sys := {diff(x(t),t) = -x(t) + 3*y(t) + 3*z(t) + 27*t^2, diff(y(t),t) = 2*x(t) - 2*y(t) - 5*z(t) + 3*t, diff(z(t),t) = -2*x(t) + 3*y(t) + 6*z(t) + 3};
sol := dsolve({op(sys), x(0)=50, y(0)=-30, z(0)=26}, {x(t), y(t), z(t)});
xt := subs(sol, x(t));  yt := subs(sol, y(t));  zt := subs(sol, z(t));
plotsetup(ps, plotoutput="plots/lab3/2d.ps");
plot([xt, yt, zt], t=0..2, legend=["x(t)", "y(t)", "z(t)"]);
plotsetup(default);


# Exercise 3: x'(t) = x(t) + y(t), y'(t) = -2x(t) + 4y(t)
restart;
sys := {diff(x(t),t) = x(t) + y(t), diff(y(t),t) = -2*x(t) + 4*y(t)};
# a) Solutii pentru 4 conditii initiale
sol1 := dsolve({op(sys), x(0)=3,  y(0)=0},  {x(t), y(t)});
sol2 := dsolve({op(sys), x(0)=0,  y(0)=3},  {x(t), y(t)});
sol3 := dsolve({op(sys), x(0)=-3, y(0)=0},  {x(t), y(t)});
sol4 := dsolve({op(sys), x(0)=0,  y(0)=-3}, {x(t), y(t)});
print("Sol1:", sol1);
print("Sol2:", sol2);
print("Sol3:", sol3);
print("Sol4:", sol4);
# b) Limitele pentru t->+inf
print("Sol1 lim x:", limit(subs(sol1, x(t)), t=infinity));
print("Sol1 lim y:", limit(subs(sol1, y(t)), t=infinity));
print("Sol2 lim x:", limit(subs(sol2, x(t)), t=infinity));
print("Sol2 lim y:", limit(subs(sol2, y(t)), t=infinity));
print("Sol3 lim x:", limit(subs(sol3, x(t)), t=infinity));
print("Sol3 lim y:", limit(subs(sol3, y(t)), t=infinity));
print("Sol4 lim x:", limit(subs(sol4, x(t)), t=infinity));
print("Sol4 lim y:", limit(subs(sol4, y(t)), t=infinity));
# c) Portretul fazic cu cele 4 orbite
plotsetup(ps, plotoutput="plots/lab3/3c.ps");
DEtools[phaseportrait]([op(sys)], [x(t), y(t)], t=-0.8..0.8,
    [[0,3,0], [0,0,3], [0,-3,0], [0,0,-3]],
    x=-5..5, y=-5..5);
plotsetup(default);


# Exercise 4: x'(t) = y(t), y'(t) = -x(t) - 2y(t)
restart;
sys := {diff(x(t),t) = y(t), diff(y(t),t) = -x(t) - 2*y(t)};
# a) Solutia generala (val proprie -1 dubla)
sol_gen := dsolve(sys, {x(t), y(t)});
print("Solutia generala:", sol_gen);
# b) Limitele pentru t->+inf
xt_gen := subs(sol_gen, x(t));
yt_gen := subs(sol_gen, y(t));
print("lim x(t):", limit(xt_gen, t=infinity));
print("lim y(t):", limit(yt_gen, t=infinity));
# c) Portretul fazic (nod stabil degenerat)
plotsetup(ps, plotoutput="plots/lab3/4c.ps");
DEtools[phaseportrait]([op(sys)], [x(t), y(t)], t=0..8,
    [[0,2,0], [0,-2,0], [0,0,2], [0,0,-2],
     [0,1,1], [0,-1,-1], [0,2,-2], [0,-2,2]],
    x=-3..3, y=-3..3);
plotsetup(default);


# Exercise 5: Portrete fazice
# Sisteme ce admit lim x(t)=0, lim y(t)=0: (b), (d), (e)
# a) x' = 2x + y, y' = x + 2y (val proprii 1, 3 > 0 => diverge)
restart;
sys := {diff(x(t),t) = 2*x(t) + y(t), diff(y(t),t) = x(t) + 2*y(t)};
plotsetup(ps, plotoutput="plots/lab3/5a.ps");
DEtools[phaseportrait]([op(sys)], [x(t), y(t)], t=-0.5..0.5,
    [[0,1,0], [0,-1,0], [0,0,1], [0,0,-1],
     [0,1,1], [0,-1,-1], [0,1,-1], [0,-1,1]],
    x=-3..3, y=-3..3);
plotsetup(default);
# b) x' = -x - y, y' = x - y (val proprii -1+/-i => spirala stabila => lim=0)
restart;
sys := {diff(x(t),t) = -x(t) - y(t), diff(y(t),t) = x(t) - y(t)};
plotsetup(ps, plotoutput="plots/lab3/5b.ps");
DEtools[phaseportrait]([op(sys)], [x(t), y(t)], t=0..5,
    [[0,2,0], [0,-2,0], [0,0,2], [0,0,-2],
     [0,1,1], [0,-1,-1], [0,2,-2], [0,-2,2]],
    x=-3..3, y=-3..3);
plotsetup(default);
# c) x' = y, y' = -x (val proprii +/-i => centru => nu converge)
restart;
sys := {diff(x(t),t) = y(t), diff(y(t),t) = -x(t)};
plotsetup(ps, plotoutput="plots/lab3/5c.ps");
DEtools[phaseportrait]([op(sys)], [x(t), y(t)], t=0..2*Pi,
    [[0,0.5,0], [0,1,0], [0,1.5,0], [0,2,0], [0,2.5,0]],
    x=-3..3, y=-3..3);
plotsetup(default);
# d) x' = -2x, y' = -4x - 2y (val proprie -2 dubla => nod stabil => lim=0)
restart;
sys := {diff(x(t),t) = -2*x(t), diff(y(t),t) = -4*x(t) - 2*y(t)};
plotsetup(ps, plotoutput="plots/lab3/5d.ps");
DEtools[phaseportrait]([op(sys)], [x(t), y(t)], t=0..3,
    [[0,2,0], [0,-2,0], [0,0,2], [0,0,-2],
     [0,1,1], [0,-1,-1], [0,1,-1], [0,-1,1]],
    x=-3..3, y=-3..3);
plotsetup(default);
# e) x' = x - 4y, y' = 5x - 3y (val proprii -1+/-4i => spirala stabila => lim=0)
restart;
sys := {diff(x(t),t) = x(t) - 4*y(t), diff(y(t),t) = 5*x(t) - 3*y(t)};
plotsetup(ps, plotoutput="plots/lab3/5e.ps");
DEtools[phaseportrait]([op(sys)], [x(t), y(t)], t=0..3,
    [[0,2,0], [0,-2,0], [0,0,2], [0,0,-2],
     [0,1,1], [0,-1,-1], [0,2,-1], [0,-2,1]],
    x=-3..3, y=-3..3);
plotsetup(default);
# f) x' = 3x - y, y' = y (val proprii 1, 3 > 0 => diverge)
restart;
sys := {diff(x(t),t) = 3*x(t) - y(t), diff(y(t),t) = y(t)};
plotsetup(ps, plotoutput="plots/lab3/5f.ps");
DEtools[phaseportrait]([op(sys)], [x(t), y(t)], t=-0.5..0.5,
    [[0,1,0], [0,-1,0], [0,0,1], [0,0,-1],
     [0,1,1], [0,-1,-1], [0,1,-1], [0,-1,1]],
    x=-3..3, y=-3..3);
plotsetup(default);
