function count_heads(n)
    c::Int = 0
    for i = 1:n
        c += rand(Bool)
    end
    c
end


using Distributed
#basepath = "/mnt/rOjterQsync/Programmering/"
#thispath = pwd()
#cd(thispath)

n = Int(1e8)
include_string(Main, "$(read("count_heads.jl", String))", "count_heads.jl")

function parallel_map(n)
    a = @spawn count_heads(n);
    b = @spawn count_heads(n);
    return fetch(a) + fetch(b)
end

@time parallel_map(n)

@time count_heads(n) + count_heads(n)

@time nheads1 = @distributed (+) for i = 1:200000000; Int(rand(Bool)); end

@time nheads2 = for i = 1:200000000; Int(rand(Bool)); end

n = 32
a = zeros(n);
Threads.@threads for i = 1:n
    a[i] = Threads.threadid()
end
a

Threads.nthreads()
n = Int(1e8)
a = zeros(n);

@time Threads.@threads for i = 1:n
    a[i] = i%30
end

@time for i = 1:n
    a[i] = i%30
end
