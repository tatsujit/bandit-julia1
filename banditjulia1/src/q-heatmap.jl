"""
julia> versioninfo()
Julia Version 1.11.1
Commit 8f5b7ca12ad (2024-10-16 10:53 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: macOS (arm64-apple-darwin22.4.0)
  CPU: 11 × Apple M3 Pro
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, apple-m3)
Threads: 1 default, 0 interactive, 1 GC (on 5 virtual cores)
Environment:
  DYLD_LIBRARY_PATH = /System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/::/usr/lib:/usr/local/lib


201x201 で sims = 100
History を一個使いまわして上書きしたら：
sims: 4040100, length(regrets): 40401
863.581727 seconds (38.96 G allocations: 1.224 TiB, 8.71% gc time, 0.55% compilation time: 54% of which was recompilation)

julia -t 4 として FLoops を使ったら、2倍くらい速くなるけど、とにかく長い計算で効き目があるはず
"""

include("settings.jl")
# import Pkg; Pkg.add("CairoMakie")
# using BenchmarkTools
# using CairoMakie
using FLoops

verbose = false
n_αs = n_βs = 4
sim = 10  # simulations for each parameter value
trials = 100
ps = [0.2, 0.2, 0.4, 0.8]
# ps = [0.7, 0.7, 0.8, 0.9]
# ps = [0.8, 0.8, 0.8, 0.9]
# ps = [0.2, 0.2, 0.2, 0.2, 0.4, 0.4, 0.4, 0.4, 0.8]
n_arms = length(ps)
distributions::AbstractVector{Distribution{Univariate}} = [Bernoulli(p) for p in ps] # for all simulations
αs = range(0.0, 1.0, length=n_αs)
βs = range(0.0, 10.0, length=n_βs)
parameters = [[α, β] for α in αs for β in βs] # parameters = collect(Iterators.product(αs, βs))
println("parameters: ", parameters)
sims = sim * length(parameters) # total simulations
prob_str = join(string.(Int.(100 .* ps)))
estimator_str, policy_str = "Q", "SM"
filename_suffix = "$(sim)sims-$(trials)trials-$(n_arms)-arms-$(prob_str)-$(estimator_str)-$(policy_str)-α-β-$(n_αs)x$(n_βs)param-vs"
# filename_suffix = filename_suffix(sims, trials, n_arms, ps, estimator_str, policy_str, n_αs, n_βs, rseed)
rseed = 1234
rseeds = [rseed * i for i in 1:sims]

# TODO 記録用のファイル名を作成する
# simulation_name = toString(n_αs) * "x" * toString(n_βs) * "x" * toString(sim)
"regret-heatmap-10sims-100trials-4-arms-20204080-Q-SM-α-β-3x3param-vs.pdf"



#@btime
(regrets, params_and_regrets) = regret_for_Q_α_β(parameters, sim, trials, n_arms, distributions, rseeds)

if verbose
    println("params_and_regrets: ", params_and_regrets)
    println("regrets: ", regrets)
end

println("sims: $(sims), length(regrets): $(length(regrets))")

regrets_matrix = reshape(regrets, n_αs, n_βs)
fig = create_regret_heatmap(regrets_matrix', αs, βs)
save("regret-heatmap-" * filename_suffix * ".pdf", fig)
fig

# save regrets_matrix' to a file
using JLD2
save("regrets_matrix" * filename_suffix * ".jld2", "regrets_matrix", regrets_matrix)
