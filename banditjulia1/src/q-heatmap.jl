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

using IceCream
include("settings.jl")
# import Pkg; Pkg.add("CairoMakie")
# using BenchmarkTools
# using CairoMakie
using FLoops

verbose = false
rseed = 1234
n_αs = n_βs = 11
sim = 10  # simulations for each parameter value
# trials = 150
trials = [50, 100, 150, 300, 450, 600, 900, 1500, 3000]
# trials = [50, 3000]
n_trials = length(trials)
# ps = [0.2, 0.2, 0.4, 0.8]
# ps = [0.4, 0.4, 0.4, 0.8]
# ps = [0.1, 0.1, 0.1, 0.5]
# ps = [0.7, 0.7, 0.8, 0.9]
# ps = [0.8, 0.8, 0.8, 0.9]
ps = [0.4, 0.4, 0.4, 0.4, 0.8]
# ps = [0.1, 0.1, 0.1, 0.1, 0.5]
# ps = [0.2, 0.2, 0.2, 0.2, 0.4, 0.4, 0.4, 0.4, 0.8]
n_arms = length(ps)
distributions::AbstractVector{Distribution{Univariate}} = [Bernoulli(p) for p in ps] # for all simulations
αs = range(0.0, 1.0, length=n_αs)
βs = range(0.0, 100.0, length=n_βs)
# parameters = [[α, β] for α in αs for β in βs]
parameters = [(α, β, trial) for α in αs for β in βs for trial in trials] # tuples allow different types of elements
if verbose
    println("parameters: ", parameters)
end
sims = sim * length(parameters) # total simulations
rseeds = [rseed * i for i in 1:sims]
estimator_str, policy_str = "Q", "SM"
fn_suffix = filename_suffix(sims, trials, n_arms, ps, estimator_str, policy_str, n_αs, n_βs, rseed)
println("fn_suffix: ", fn_suffix)

#@btime
(regrets, params_and_regrets) = regret_for_Q_α_β_(parameters, sim, n_arms, distributions, rseeds)

if verbose
    println("params_and_regrets: ", params_and_regrets)
    println("regrets: ", regrets)
end

println("sims: $(sims), length(regrets): $(length(regrets))")

# regrets_matrix = reshape(regrets, n_αs, n_βs)
regrets_matrix = reshape(regrets, n_αs, n_βs, n_trials)

# fig = create_regret_heatmap(regrets_matrix', αs, βs)
fig = create_regret_heatmaps_Q_trials(regrets_matrix, params_and_regrets, αs, βs, trials, false)
save("regret-heatmap-" * fn_suffix * ".pdf", fig)
fig

# save regrets_matrix' to a file
using JLD2
save("regrets_matrix" * fn_suffix * ".jld2", "regrets_matrix", regrets_matrix)
