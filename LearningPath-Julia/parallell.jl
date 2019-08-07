## Distributed package # works
using Distributed
n = Int(1e8)

@time @sync nheads1 = @distributed (+) for i = 1:n; rand(Bool); end

nheads2 = 0;
@time for i = 1:n; global nheads2+=rand(Bool); end
println(nheads2)

## Show what worker that is involved
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

sum = 0
@time Threads.@threads for i = 1:n
    global sum
    sum+=rand(Bool)
end
println(sum)

sum = 0
@time for i = 1:n
    global sum
    sum+=rand(Bool)
end
println(sum)

# Trying to map out distribution

basepath = "/home/dreuter/Github/julia-paths"
thispath = "/LearningPath-Julia/"
fullpath = string(basepath,thispath)
cd(fullpath)
@everywhere include(string("/home/dreuter/Github/julia-paths/LearningPath-Julia/","Counter.jl"))

function parallel_map(n,n_par)
    joblist = []
    n_job = Int(round(n/n_par))
    for i = 1:n_par
        push!(joblist, @spawn Counter.count_heads(n_job))
    end
    return joblist
end

n = Int(1e10);
joblist = parallel_map(n,4);

## Compare with and without parallell jobs
@time sum(map(fetch, joblist))

@time Counter.count_heads(n)
