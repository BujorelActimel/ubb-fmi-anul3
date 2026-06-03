# ============================================================
# GHID EXAMEN PRACTIC - Sisteme Dinamice
# ============================================================
# Structura subiectului (9p + 1p oficiu = 10p):
#   Ex 1 (2p) - ODE ord 1 liniara + parametru m
#   Ex 2 (2-3p) - ODE ord 2 tip Euler + Cauchy + grafic
#   Ex 3 (3p) - ODE autonoma: echilibru + stabilitate + grafic
#   Ex 4 (2p) - Sistem ODE: solutie generala + Cauchy
# ============================================================


# ============================================================
# EXERCITIUL 1 (2p)
# Forma: y'(x) - y(x)/x = m*x   sau   x*y'(x) = m*x^2 + y(x)
# (a) Solutia generala
# (b) Gaseste m astfel incat solutia Cauchy sa treaca printr-un punct
# ============================================================
restart;
ode := diff(y(x), x) - y(x)/x = m*x;          # <-- adapteaza ecuatia
# (a) Solutia generala:
dsolve(ode, y(x));
# (b) Cauchy + conditie pe punct:
sol_c := dsolve({ode, y(1) = 1}, y(x));         # <-- adapteaza CI
m_val := solve(subs(x = 2, rhs(sol_c)) = 0, m); # <-- adapteaza punctul A(2,0)
print("m =", m_val);
sol_specifica := subs(m = m_val, rhs(sol_c));
print("Solutia:", sol_specifica);


# ============================================================
# EXERCITIUL 2 (2-3p)
# Forma: x^2*y''(x) + a*x*y'(x) + b*y(x) = 0  (ecuatie Euler)
# (a) Solutia generala
# (b) Solutia Cauchy + grafic pe interval
# ============================================================
restart;
ode := x^2*diff(y(x),x,x) + 3*x*diff(y(x),x) + y(x) = 0; # <-- adapteaza
# (a) Solutia generala:
dsolve(ode, y(x));
# (b) Cauchy + grafic:
sol_c := dsolve({ode, y(1) = 1, D(y)(1) = 1}, y(x));       # <-- adapteaza CI
print("Solutia Cauchy:", rhs(sol_c));
plotsetup(ps, plotoutput="plots/ex2.ps");
plot(rhs(sol_c), x = 1..10);                                # <-- adapteaza intervalul
plotsetup(default);

# NOTA: daca y(1)=1 si y'(1)=1 si solutia are ln(x), foloseste D(y)(1)=1
# NOTA: pentru interval care include x=0, atentie la singularitate


# ============================================================
# EXERCITIUL 3 (3p)
# Forma: x'(t) = f(x(t))  -- ecuatie autonoma scalara
# (a) Puncte de echilibru + stabilitate
# (b) Grafic solutii pentru mai multe CI pe interval
# ============================================================
restart;
ode := diff(x(t), t) = x(t)*(x(t) + 1)*(2 - x(t)); # <-- adapteaza f(x)

# (a) Puncte de echilibru: rezolva f(x) = 0
f := x -> x*(x + 1)*(2 - x);                        # <-- adapteaza
eq_pts := solve(f(x) = 0, x);
print("Puncte echilibru:", eq_pts);

# Stabilitate: f'(xe) < 0 => stabil,  f'(xe) > 0 => instabil
df := unapply(diff(f(x), x), x);
for xe in [eq_pts] do
    val := df(xe);
    if val < 0 then
        print(xe, "- STABIL (asimptotic)");
    elif val > 0 then
        print(xe, "- INSTABIL");
    else
        print(xe, "- necesita analiza suplimentara");
    end if;
end do;

# (b) Grafic solutii pentru multiple CI:
plotsetup(ps, plotoutput="plots/ex3.ps");
DEtools[DEplot](ode, x(t), t = 0..2,        # <-- adapteaza intervalul
    [[0,-1],[0,0],[0,1],[0,2],[0,3]],         # <-- adapteaza CI: [t0, x0]
    x = -2..3,                               # <-- adapteaza y-range
    arrows = medium);
plotsetup(default);


# ============================================================
# EXERCITIUL 4 (2p) - VARIANTA A: Sistem liniar
# Forma: y1' = a*y1 + b*y2,  y2' = c*y1 + d*y2
# (a) Solutia generala
# (b) Solutia Cauchy y1(0)=..., y2(0)=...
# ============================================================
restart;
sys := {diff(y1(t),t) = -7*y1(t) - 6*y2(t),   # <-- adapteaza
        diff(y2(t),t) = 12*y1(t) + 10*y2(t)};
# (a) Solutia generala:
dsolve(sys, {y1(t), y2(t)});
# (b) Cauchy:
sol_c := dsolve({op(sys), y1(0) = 2, y2(0) = 4}, {y1(t), y2(t)}); # <-- CI
print("y1:", subs(sol_c, y1(t)));
print("y2:", subs(sol_c, y2(t)));


# ============================================================
# EXERCITIUL 4 (2p) - VARIANTA B: Sistem neliniar autonom
# Forma: x'(t) = f(x,y),  y'(t) = g(x,y)
# (a) Puncte de echilibru
# (b) Stabilitate si tip (se foloseste matricea Jacobiana)
# ============================================================
restart;
f := (x, y) -> x*y - 1;                    # <-- adapteaza
g := (x, y) -> x^2 - 16*y^2;              # <-- adapteaza

# (a) Puncte de echilibru: f(x,y)=0 si g(x,y)=0
eq_pts := solve({f(x,y) = 0, g(x,y) = 0}, {x, y});
print("Puncte echilibru:", eq_pts);

# (b) Matricea Jacobiana:
J := Matrix([
    [diff(f(x,y), x), diff(f(x,y), y)],
    [diff(g(x,y), x), diff(g(x,y), y)]
]);
print("Jacobian:", J);

# Evalueaza la fiecare punct de echilibru si gaseste val proprii:
with(LinearAlgebra):
for pt in [eq_pts] do
    J_pt := subs(pt, J);
    vals := Eigenvalues(J_pt);
    print("Punct:", pt, "-> val proprii:", vals);
    # Interpretare:
    # Re(lambda) < 0 => stabil (nod/spirala stabila/centru)
    # Re(lambda) > 0 => instabil
    # lambda reale distincte neg => nod stabil
    # lambda reale distincte poz => nod instabil
    # lambda complexe Re<0 => spirala stabila
    # lambda complexe Re>0 => spirala instabila
    # lambda pur imaginare => centru (stabil dar nu asimptotic)
    # lambda reale opuse ca semn => sa (punct saua)
end do;


# ============================================================
# BONUS: Modelul racirii Newton (apare uneori la Ex 1)
# T'(t) = -k*(T(t) - Tm),  T(0) = T0
# ============================================================
restart;
ode := diff(T(t), t) = -k*(T(t) - Tm);
sol := dsolve({ode, T(0) = T0}, T(t));
print("Solutie Newton:", rhs(sol));
# Gaseste k din T(t1) = T1:
# subs(T0=40, Tm=5, t=1, T1=10): 5 + 35*exp(-k) = 10 => k = ln(7)
k_val := solve(subs({T0=40, Tm=5, t=1}, rhs(sol)) = 10, k);
print("k =", k_val);
