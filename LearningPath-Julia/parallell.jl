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


@time nheads1 = @distributed (+) for i = 1:200000000; Int(rand(Bool)); end

@time nheads2 = for i = 1:200000000; Int(rand(Bool)); end

n = 32
a = zeros(n);
Threads.@threads for i = 1:n
    a[i] = Threads.threadid()
end
a

Threads.nthreads()

# Distribute workers within for loop (Experimental only!)

n = Int(1e8)
a = zeros(n);

@time Threads.@threads for i = 1:n
    a[i] = i%30
end

@time for i = 1:n
    a[i] = i%30
end
