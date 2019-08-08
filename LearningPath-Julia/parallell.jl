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
using Distributed
basepath = "/home/dreuter/Github/julia-paths"
thispath = "/LearningPath-Julia/"
fullpath = string(basepath,thispath)
cd(fullpath)
@everywhere include(string("/home/dreuter/Github/julia-paths/LearningPath-Julia/","Counter.jl"))

function parallel_map(n,n_par)
    joblist = Vector{Future}(undef, n_par)
    n_job = Int(round(n/n_par))
    for i = 1:n_par
        joblist[i] = @spawn Counter.count_heads(n_job)
    end
    return joblist
end

n = Int(1e10);
@time joblist = parallel_map(n,16)

## Compare with and without parallell jobs
@time sum(map(fetch, joblist))

@time Counter.count_heads(n)

##

const jobs = Channel{Int}(32);
const results = Channel{Tuple}(32);

function count_heads(n)
    c::Int = 0
    for i = 1:n
        c += rand(Bool)
    end
    c
end;

function make_jobs(n)
    for i in 1:n
        put!(jobs, i)
    end
end;

function do_work(nc)
    for job_id in jobs
        nheads = count_heads(nc)
        put!(results, (job_id, nheads))
    end
end;

n_job = 4;
n_counts = 1e8;
@async make_jobs(n_job);

@time for i in 1:4
    @async do_work(n_counts)
end

@elapsed    while n_job > 0
                job_id, nheads = take!(results)
                println("Job $job_id counts to $(round(nheads; digits=2)) heads")
                global n_job = n_job - 1
            end
