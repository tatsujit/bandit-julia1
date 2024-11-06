# import Pkg; Pkg.add("Optim")
using Random
using DataFrames
using Distributions
using StatsBase
using Optim
include("actionvalueestimator.jl")
include("policy.jl")
include("agent.jl")
include("environment.jl")
include("history.jl")
include("system.jl")
include("evaluation.jl")

# Run the Simulation
function run!(system::AbstractSystem, steps::Int)
    for _ in 1:steps
        step!(system)
    end
end

rseed = 1234
rng1 = Xoshiro(rseed) # DONE: rseed input and also use Xoshiro
n_arms = 3
ε = 0.1
agent1 = Agent(SampleAverageEstimator(n_arms), EpsilonGreedyPolicy(ε))
# distributions1 = [Normal(1.0, 1.0), Normal(2.0, 1.0), Normal(3.0, 1.0)]
# distributions1 = [Normal(i*1.0, 1.0) for i in 1:n_arms]
distributions1 = [Bernoulli(i*0.1) for i in 1:n_arms]
println(typeof(distributions1)) #
env1 = Environment(n_arms, distributions1)
# sys1 = System(agent1, env1, rng1)
sys1 = SystemRich(agent1, env1, rng1)


run!(sys1, 100)

println(sys1.history)
sys1.history
