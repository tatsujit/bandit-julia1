import Pkg; Pkg.add("Optim")
using Random
using DataFrames
using Distributions
using StatsBase
# using Optim
using Distributed
include("utils.jl")
include("actionValueEstimator.jl")
include("policy.jl")
include("agent.jl")
include("environment.jl")
include("history.jl")
include("system.jl")
include("evaluation.jl")

sims = 1
trials = 10
# rseed = 3
rseed = Int(round(time() * 1000)) # time() gives seconds, multiplying by 1000 for milliseconds
rng = Xoshiro(rseed)
n_arms = 3
ε = 0.3
agent = Agent(SampleAverageEstimator(n_arms), EpsilonGreedyPolicy(ε))
distributions1 = [Bernoulli(j*0.1+0.6) for j in 1:n_arms]
# println(typeof(distributions1)) #
env1 = Environment(n_arms, distributions1)
# his1 = History(trials)
his1 = HistoryRich(trials)
sys1 = System(agent, env1, his1, rng)

run!(sys1, trials)
println("rseed: $rseed")

print(sys1.history)

# println(sys1)

# println(agent.estimator.Q)

dat1 = to_dataframe(sys1.history)


dat1
