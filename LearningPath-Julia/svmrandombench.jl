## Support vector machine models, randomized, bechmarked
basepath = "/home/dreuter/Github/julia-paths"
thispath = "/LearningPath-Julia/"
fullpath = string(basepath,thispath)
cd(fullpath)
@everywhere include(string("/home/dreuter/Github/julia-paths/LearningPath-Julia/","Svmrandom.jl"))

using Distributed, Statistics
results = []
n = 1000
for i = 1:n
    push!(results, @spawn Svmrandom.svmrandom())
end

avg = mean(map(fetch,results));

using Printf
@printf "Accuracy: %.2f%%\n" avg