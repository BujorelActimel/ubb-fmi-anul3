# 1

# a)
ode := x*diff(y(x), x) + k*y(x) = x^4 + y(x);
dsolve(ode, y(x));

# b)
sol_c := dsolve({ode, y(1) = 1/(k+3)}, y(x));
k_val := solve(subs(x = 3, rhs(sol_c)) = 81, k);
print("k =", k_val);
sol_specifica := subs(k = k_val, rhs(sol_c));
print("Solutia:", sol_specifica);


# 2
# a)
restart;
ode := x^2*diff(y(x),x,x) + 2*x*diff(y(x),x) + 4*y(x) = 0;
dsolve(ode, y(x));

# b)
sol_c := dsolve({ode, y(1) = 1, D(y)(1) = 1}, y(x));
print("Solutia Cauchy:", rhs(sol_c));
plotsetup(ps, plotoutput="plots/test/2.ps");
plot(rhs(sol_c), x = 1..20);
plotsetup(default);

# 3
# a)
restart;
ode := diff(x(t), t) = (3-x(t))*(x(t)+1)*x(t);
f := x -> (3-x)*(x+1)*x;
eq_pts := solve(f(x) = 0, x);
print("Puncte echilibru:", eq_pts);
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

# b)
plotsetup(ps, plotoutput="plots/test/3.ps");
DEtools[DEplot](ode, x(t), t = 0..2,
    [[0,-1],[0,-1/2],[0,0],[0,1/2],[0,1],[0,3/2],[0,2]],
    x = 0..2,
    arrows = medium);
plotsetup(default);
