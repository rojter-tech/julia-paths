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
addprocs(1);
rmprocs(workers());
n_procs = 4
addprocs(n_procs);
@everywhere basepath = "/home/dreuter/Github/julia-paths"
@everywhere thispath = "/LearningPath-Julia/"
@everywhere fullpath = string(basepath,thispath)
@everywhere include(string("/home/dreuter/Github/julia-paths/LearningPath-Julia/","Counter.jl"))

function parallel_map(n,n_par)
    joblist = Vector{Future}(undef, n_par)
    n_job = Int(round(n/n_par))
    for i = 1:n_par
        joblist[i] = @spawn Counter.count_heads(n_job)
    end
    return joblist
end

n = 2e10;
joblist = parallel_map(n,n_procs);
@time sum(map(fetch, joblist))

@time Counter.count_heads(n)

### RemoteChannels

rmprocs(workers())
addprocs(7); # add number of worker processes

const jobs = RemoteChannel(()->Channel{Int}(32));
const results = RemoteChannel(()->Channel{Tuple}(32));

@everywhere function count_heads(n)
            c::Int = 0
            for i = 1:n
                c += rand(Bool)
            end
            c
        end

@everywhere function do_flip_work(jobs, results, flips) # define work function everywhere
            while true
                job_id = take!(jobs)
                nheads = count_heads(flips)
                put!(results, (job_id, nheads, myid()))
            end
        end

function make_jobs(n)
    for i in 1:n
        put!(jobs, i)
    end
end;

function execute_tasks(n, flips)
    @async make_jobs(n); # feed the jobs channel with "n" jobs
    for p in workers() # start tasks on the workers to process requests in parallel
        remote_do(do_flip_work, p, jobs, results, flips)
    end
end


n_jobs = 10; # add number of jobs
n_flips = 1e10
execute_tasks(n_jobs, n_flips)

# Display overall process and results
s = 0;
@time while n_jobs > 0 # print out results
    global s
    job_id, nheads, where = take!(results)
    println("Job $job_id counts to $(round(nheads; digits=2)) heads on worker $where")
    s += nheads
    global n_jobs -= 1
end;
println("The total number of heads is: $(round(s; digits=2))");
