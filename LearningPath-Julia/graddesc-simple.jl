using ForwardDiff
function gradientDescent(f, X0::Real, ϵ, ħ)
    g = x -> ForwardDiff.derivative(f, x); # g = ∇f

    X = X0

    for k = 1:ħ
        g1 = g(X)
        X = X - ϵ*g1
        println("Iter: $(k), Grad: $(g1), Function: $(f(X))")
    end
    return f(X), X
end

f(x::Real) = 5(3 - x)^2 + 3(3 - x) + 100;
x = rand(1)[1]
result, x = gradientDescent(f, x, 0.01, 400)

using Seaborn; const sns = Seaborn
sns.set()

xrange = (x - 0.2x):0.01:(x + 0.2x);

clf()
plot(xrange,map(f, xrange));
display(gcf())
