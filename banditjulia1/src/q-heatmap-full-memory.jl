# more than 80GB memory was occupied when I tried to run this script at 162900th simulation done.
# with 1001 * 1001 = 1,002,001 simulations with 10,000 trials each
#
# with 101 * 101 = 10,201 simulations with 10,000 trials each
# @time include("q-heatmap.jl")
# =>
# 162.927652 seconds (2.06 G allocations: 78.584 GiB, 63.83% gc time, 0.33% compilation time)
# with
#
# to be invoked by
# `julia -p 4`
# and then executed by
# `include("dlr-heatmap.jl")`
# I guess?
include("settings.jl")
# using Pkg; Pkg.add("GLMakie")
# import Pkg; Pkg.add("CairoMakie")
using CairoMakie

verbose = false
n_αs = n_βs = 101
sim = 1  # simulations for each parameter value
trials = 100
n_arms = 4
ps = [0.2, 0.2, 0.4, 0.8]

αs = range(0.0, 1.0, length=n_αs)
βs = range(0.0, 10.0, length=n_βs)
# αs = range(0.0, 1.0, length=101)
# βs = range(0.0, 10.0, length=101)
parameters = Iterators.product(αs, βs) # collect if we want an array
sims = sim * length(parameters) # total simulations

rseeds = [1234 * i for i in 1:sims]
rngs = [Xoshiro(rseed) for rseed in rseeds]

agents = [Agent(QEstimator(α, n_arms), SoftmaxPolicy(β)) for (α, β) in parameters] # TODO sim も考慮しないと
# distributions1s = [[Bernoulli(j*0.2) for j in 1:n_arms] for i in 1:sims]
distributions = [Bernoulli(p) for p in ps] # for all simulations
env = Environment(n_arms, distributions) # for all simulations
hiss = [HistoryRich(trials) for _ in 1:sims]
syss = [System(agents[i], env, hiss[i], rngs[i]) for i in 1:sims]

Threads.@threads for i in 1:sims
    run!(syss[i], trials)
    if i % (sims / 100) == 0
        println(syss[i].history)
        println("$(i)th simulation done.")
    end
end

evaluations = [evaluate(sys) for sys in syss]

regrets = [evaluations[i].regret[end] for i in 1:sims]

if verbose
    for i in 1:sims
        if i % (sims / 100) == 0
            println("α: $(syss[1].agent.estimator.α), β: $(syss[1].agent.policy.β), regret: $(evaluations[1].regret[end])")
        end
    end
end

# resultsQ = [[syss[i].agent.estimator.α, syss[i].agent.policy.β, evaluations[i].regret[end]] for i in 1:sims]
# resultsQ

# heatmap(reshape(regrets, 101, 101), αs, βs, c=:viridis)



# using CairoMakie

# function create_regret_heatmap(regret_matrix, αs, βs)
#     fig = Figure(size=(900, 700))

#     ax = Axis(fig[1, 1],
#               title="Q-Learning Regret Analysis",
#               xlabel="Learning Rate (α)",
#               ylabel="Inverse Temperature (β)")

#     # Create heatmap with reversed y-axis to match matrix orientation
#     hm = heatmap!(ax, αs, βs, regret_matrix',
#                   colormap=:viridis,
#                   interpolate=true)

#     # Add colorbar with scientific notation for large values
#     Colorbar(fig[1, 2], hm,
#              label="Regret",
#              width=15,
#              tickformat=x->string(Float64(round(x; sigdigits=3))),
#              ticklabelsize=12)

#     # Adjust layout
#     colsize!(fig.layout, 1, Relative(0.85))

#     # Add gridlines for better readability
#     ax.xgridvisible = true
#     ax.ygridvisible = true

#     # Custom ticks for better readability
#     ax.xticks = range(0, 1, step=0.2)
#     ax.yticks = range(0, 10, step=2)

#     fig
# end

using CairoMakie

function create_regret_heatmap(regret_matrix, αs, βs)
    f = Figure()
    ax = Axis(f[1, 1],
              title = "Q-Learning Regret Analysis",
              xlabel = "Learning Rate (α)",
              ylabel = "Inverse Temperature (β)")
    hm = heatmap!(αs, βs, regret_matrix)
    Colorbar(f[1, 2], hm, label = "Regret")
    f
end

# Example usage (uncomment and modify with your actual regret matrix):
# regret_matrix = rand(101, 101)  # Replace with your actual regret matrix
# αs = range(0.0, 1.0, length=101)
# βs = range(0.0, 10.0, length=101)
regrets_matrix = reshape(regrets, n_αs, n_βs)
fig = create_regret_heatmap(regrets_matrix, αs, βs)
save("qlearning_regret.png", fig)
fig


