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

"""

include("settings.jl")
import Pkg; Pkg.add("JLD2")

# import Pkg; Pkg.add("CairoMakie")

verbose = false
n_αps = n_αns = n_βs = 11 # (display が3x3なので、9以上だし、11じゃないとうまく \beta = 1.0, ..., 9.0 ともならない！）
display_values = 9
sim = 100  # simulations for each parameter value
trials = 150
# ps = [0.2, 0.2, 0.4, 0.8]
# ps = [0.7, 0.7, 0.8, 0.9]
# ps = [0.8, 0.8, 0.8, 0.9]
# ps = [0.2, 0.2, 0.2, 0.2, 0.4, 0.4, 0.4, 0.4, 0.8]
ps = [0.1, 0.1, 0.1, 0.1, 0.5]
# ps = [0.4, 0.4, 0.4, 0.4, 0.8]
# ps = [0.6, 0.6, 0.6, 0.6, 1.0]
# ps = [0.5, 0.5, 0.5, 0.5, 0.9]
n_arms = length(ps)
distributions::AbstractVector{Distribution{Univariate}} = [Bernoulli(p) for p in ps] # for all simulations
αps = range(0.0, 1.0, length=n_αps)
αns = range(0.0, 1.0, length=n_αns)
βs = range(0.0, 10.0, length=n_βs)
αps_display = range(0.1, 0.9, length=display_values)
αns_display = range(0.1, 0.9, length=display_values)
βs_display = range(1.0, 9.0, length=display_values)

parameters = [[αp, αn, β] for αp in αps for αn in αns for β in βs] # parameters = collect(Iterators.product(αs, βs))
# println("parameters: ", parameters)
# println("length(parameters): ", length(parameters))
sims = sim * length(parameters) # total simulations
prob_str = join(string.(Int.(100 .* ps)))
estimator_str, policy_str = "DLR", "SM" # TODO toString should be used
rseed = 1234
rseeds = [rseed * i for i in 1:sims]

fn_suffix = filename_suffix(sims, trials, n_arms, ps, estimator_str, policy_str, n_αps, n_αns, n_βs, rseed)


println("sims: $(sims)")

(regrets, params_and_regrets) = regret_for_DLR_αp_αn_β(parameters, sim, trials, n_arms, distributions, rseeds)

if verbose
    println("params_and_regrets: ", params_and_regrets)
    println("regrets: ", regrets)
end

# println("sims: $(sims), length(regrets): $(length(regrets))")

regrets_matrix = reshape(regrets, n_αps, n_αns, n_βs)

# fig = create_regret_heatmap(regrets_matrix[:,:,9]', αps, αns)
fig = create_regret_heatmaps(regrets_matrix, params_and_regrets, αps, αns, βs_display)
save("regret-heatmap-" * fn_suffix * ".pdf", fig)
fig

# save regrets_matrix' to a file
using JLD2
save("regrets_matrix" * fn_suffix * ".jld2", "regrets_matrix", regrets_matrix)
