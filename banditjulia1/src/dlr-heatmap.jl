# to be invoked by
# `julia -p 4`
# and then executed by
# `include("dlr-heatmap.jl")`
# I guess?
include("settings.jl")


αs = range(0.0, 1.0, length=101)
βs = range(0.0, 10.0, length=101)


sims = 1
trials = 100
rseed = [1234 * i for i in 1:sims]
rngs = [Xoshiro(seed) for seed in rseed]
n_arms = [3, 4, 5, 6]
# rng1 = Xoshiro(rseed) # DONE: rseed input and also use Xoshiro
# ε = 0.1
# n_arms = 3
εs = [0.01, 0.05, 0.1, 0.2]
# agent1 = Agent(SampleAverageEstimator(n_arms), EpsilonGreedyPolicy(ε))
agents = [Agent(SampleAverageEstimator(n_arms[i]), EpsilonGreedyPolicy(εs[i])) for i in 1:sims]
# distributions1 = [Normal(1.0, 1.0), Normal(2.0, 1.0), Normal(3.0, 1.0)]
# distributions1 = [Normal(i*1.0, 1.0) for i in 1:n_arms]
# distributions1 = [Bernoulli(i*0.1) for i in 1:n_arms]
distributions1s = [[Bernoulli(j*0.1) for j in 1:n_arms[i]] for i in 1:sims]
println(typeof(distributions1s)) #
println(typeof(distributions1s[1])) #
# env1 = Environment(n_arms, distributions1)
# env1s = [Environment(n_arms[i], distributions1s[i]) for i in 1:4]
env1s = [Environment(n_arms[i], distributions1s[i]) for i in 1:4]
# sys1 = System(agent1, env1, rng1)
# sys1 = SystemRich(agent1, env1, rng1)
his1s = [History(trials) for i in 1:4]
sys1s = [SystemRich(agents[i], env1s[i], his1s[i], rngs[i]) for i in 1:4]


Threads.@threads for i in 1:sims
# @parallel for i in 1:sims
    run!(sys1s[i], trials)
    println(sys1s[i].history)
end


println(typeof(sys1s[1]))
println(typeof(sys1s[1]))

println(sys1s[1].history)
sys1s[1].history
