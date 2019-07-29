using BenchmarkTools, Statistics, Seaborn; const sns = Seaborn
sns.set()

# Diffrent ways tp create an incrementing list of integers
n = 10^6;
a1 = @time [x for x = 1:n];
a2 = @time [1:n...];
a3 = @time collect(1:n);
a4 = @time push!([],1:n...);
a5 = @time cat(1:n; dims=1);
a6 = @time cat(1:n...; dims=1);
a7 = @time map(x->x, 1:n);

@assert a1 == a2 == a3 == a4 == a5 == a6 == a7

b1 = @benchmark [x for x = 1:n];
b2 = @benchmark [1:n...];
b3 = @benchmark collect(1:n);
b4 = @benchmark push!([],1:n...);
b5 = @benchmark cat(1:n; dims=1);
b6 = @benchmark cat(1:n...; dims=1);
b7 = @benchmark map(x->x, 1:n);

d = Dict()
d["[x for x = 1:n]"] = minimum(b1.times) / 1e6;
d["[1:n...]"] = minimum(b2.times) / 1e6;
d["collect(1:n)"] = minimum(b3.times) / 1e6;
d["push!([],1:n...)"] = minimum(b4.times) / 1e6;
d["cat(1:n; dims=1)"] = minimum(b5.times) / 1e6;
d["cat(1:n...; dims=1)"] = minimum(b6.times) / 1e6;
d["map(x->x, 1:n)"] = minimum(b7.times) / 1e6;

println("minimum values")
for (key, value) in sort(collect(d), by=last)
    println(rpad(key, 25, "."), lpad(round(value; digits=1), 6, "."))
end

# minimum execution time for n = 10^3, in milliseconds
#
# collect(1:n)  ................1.2 | 7 allocations: 7.630 MiB
# cat(1:n; dims=1)  ............1.2 | 26 allocations: 7.630 MiB
# map(x->x, 1:n)  ..............2.1 | 62.82 k allocations: 10.761 MiB
# [x for x = 1:n]  .............2.2 | 53.28 k allocations: 10.251 MiB
# [1:n...]  ..................269.3 | 3.00 M allocations: 79.900 MiB
# push!([],1:n...)  ..........423.8 | 4.00 M allocations: 110.410 MiB
# cat(1:n...; dims=1)  .......508.4 | 5.00 M allocations: 171.438 MiB


log_b3 = log.(b3.times)
clf();
xlim((0.9minimum(log_b3),(1.1maximum(log_b3))))
violinplot(x=log_b3); 
display(gcf())