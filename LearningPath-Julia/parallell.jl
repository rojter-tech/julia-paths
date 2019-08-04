using Distributed
basepath = "/home/dreuter/Github/julia-paths"
thispath = "/LearningPath-Julia/"
fullpath = string(basepath,thispath)
cd(fullpath)
@everywhere include(string("/home/dreuter/Github/julia-paths/LearningPath-Julia/","Counter.jl"))

n = Int(1e9)

function parallel_map(n)
    a = @spawn Counter.count_heads(n);
    b = @spawn Counter.count_heads(n);
    return fetch(a) + fetch(b)
end

## Compare with and without parallell workers
@time parallel_map(n)

@time Counter.count_heads(n) + Counter.count_heads(n)

## Distributed package
using Distributed
n = Int(1e8)

@time nheads1 = @distributed (+) for i = 1:n; rand(Bool); end

nheads2 = 0
@time for i = 1:n; global nheads2+=rand(Bool); end
println(nheads2)

## Show what worker thas was involved
n = 32
a = zeros(n);
Threads.@threads for i = 1:n
    a[i] = Threads.threadid()
end
println(a)

# Find out number of threads
Threads.nthreads()

# Distribute workers within for loop (Experimental only!)

n = Int(1e8)

global sum = 0
@time Threads.@threads for i = 1:n
    sum+=rand(Bool)
end
println(sum)

sum = 0
@time for i = 1:n
    global sum
    sum+=rand(Bool)
end
println(sum)