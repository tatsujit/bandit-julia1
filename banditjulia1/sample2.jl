using Random
using Distributions: Bernoulli

using banditjulia1
import banditjulia1.Models: SampleAverageEstimator
# 新しいpolicyの定義に必要なものをModelsモジュールからimport
# importしない場合，それぞれの名前の前に"banditjulia1.Models."をつける
import banditjulia1.Models:
    AbstractPolicy, AbstractActionValueEstimator, toString, select_action

# 新しいpolicyを定義
struct SamplePolicy <: AbstractPolicy
    β::Float64
end
toString(samplePolicy::SamplePolicy) = "samplePolicy($(samplePolicy.β))"
# そのpolicyに対応するselect_action関数を定義
# 今回は全て1を返すpolicy
function select_action(policy::SamplePolicy, estimator::AbstractActionValueEstimator, rng::AbstractRNG)
    n_arms = length(estimator.Q)
    return 1
end

# settings
sims = 4
trials = 100
rseed = [1234 * i for i in 1:sims]
rngs = [Xoshiro(seed) for seed in rseed]
n_arms = [3, 4, 5, 6]
εs = [0.01, 0.05, 0.1, 0.2]
agents = [Agent(SampleAverageEstimator(n_arms[i]), SamplePolicy(εs[i])) for i in 1:sims]
distributions1s = [[Bernoulli(j*0.1) for j in 1:n_arms[i]] for i in 1:sims]
env1s = [Environment(n_arms[i], distributions1s[i]) for i in 1:4]
his1s = [History(trials, n_arms[i]) for i in 1:4]
sys1s = [System(agents[i], env1s[i], his1s[i], rngs[i]) for i in 1:4]

# run
println(typeof(distributions1s))
println(typeof(distributions1s[1]))

Threads.@threads for i in 1:sims
    # @parallel for i in 1:sims
        run!(sys1s[i], trials)
        println(sys1s[i].history)
    end

println(typeof(sys1s[1]))
println(typeof(sys1s[1]))

println(sys1s[1].history)
sys1s[1].history