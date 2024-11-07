abstract type AbstractPolicy end

# Epsilon-Greedy Policy
struct EpsilonGreedyPolicy <: AbstractPolicy
    ϵ::Float64
end
toString(egp::EpsilonGreedyPolicy) = "egp($(egp.ϵ))"
function select_action(policy::EpsilonGreedyPolicy, estimator::AbstractActionValueEstimator, rng::AbstractRNG)
    n_arms = length(estimator.Q)
    if rand(rng) < policy.ϵ
        return rand(rng, 1:n_arms)
    else
        return argmax(estimator.Q)
    end
end
# Softmax Policy (mutable would be preferable but probably no theory for adjusting β yet?)
# It can take any kind of action values (the value difference is the only thing that matters)
struct SoftmaxPolicy <: AbstractPolicy
    β::Float64
    function SoftmaxPolicy(β::Float64) new(β) end
end
toString(smp::SoftmaxPolicy) = "smp($(smp.β))"
function select_action(policy::SoftmaxPolicy, estimator::AbstractActionValueEstimator, rng::AbstractRNG)
    values = estimator.Q
    n_arms = length(values)
    β = policy.β
    proto_probs = [exp(β * v) for v in values]
    probs = proto_probs / sum(proto_probs)
    return sample(rng, 1:n_arms, Weights(probs))
end
function select_action(policy::SoftmaxPolicy, estimator::AbstractActionValueEstimator)
    values = estimator.Q
    n_arms = length(values)
    β = policy.β
    proto_probs = [exp(β * v) for v in values]
    probs = proto_probs / sum(proto_probs)
    return sample(1:n_arms, Weights(probs))
end
# UCB Policy
struct UCBPolicy <: AbstractPolicy
    c::Float64
    t::Int
    function UCBPolicy(c::Float64)
        new(c, 0)
    end
end
toString(ucb::UCBPolicy) = "ucb($(ucb.c))"
function select_action(policy::UCBPolicy, estimator::SampleAverageEstimator)
    policy.t += 1
    n_arms = length(estimator.Q)
    ucb_values = zeros(n_arms)
    for i in 1:n_arms
        if estimator.N[i] == 0
            return i # Try each arm at least once
        else
            ucb_values[i] = estimator.Q[i] + policy.c * sqrt(log(policy.t) / estimator.N[i])
        end
    end
    return argmax(ucb_values)
end

# UCB-Tuned Policy
struct UCBTunedPolicy <: AbstractPolicy
    t::Int
    sum_of_squares::Vector{Float64}
    function UCBTunedPolicy(n_arms::Int)
        new(0, zeros(n_arms))
    end
end
toString(ut1::UCBTunedPolicy) = "ut1"

function select_action(policy::UCBTunedPolicy, estimator::SampleAverageEstimator)
    policy.t += 1
    n_arms = length(estimator.Q)
    ucb_values = zeros(n_arms)
    for i in 1:n_arms
        if estimator.N[i] == 0
            return i # Try each arm at least once
        else
            mean = estimator.Q[i]
            variance = (policy.sum_of_squares[i] / estimator.N[i]) - mean^2
            variance = max(variance, 0) + sqrt(2 * log(policy.t) / estimator.N[i])
            ucb_values[i] = mean + sqrt((log(policy.t) / estimator.N[i]) * min(0.25, variance))
        end
    end
    return argmax(ucb_values)
end

# Satisficing Policy
struct SatisficingPolicy <: AbstractPolicy
    aspiration_level::Float64
end
toString(sps::SatisficingPolicy) = "sps"

function select_action(policy::SatisficingPolicy, estimator::AbstractActionValueEstimator, rng::AbstractRNG)
    satisfactory_arms = findall(x -> x >= policy.aspiration_level, estimator.Q)
    if !isempty(satisfactory_arms)
        idx = rand(rng, 1:length(satisfactory_arms))
        return satisfactory_arms[idx]
    else
        # If no arm meets the aspiration level, select an arm at random
        return rand(rng, 1:length(estimator.Q))
    end
end

# Thompson Sampling Policy
struct ThompsonSamplingPolicy <: AbstractPolicy end
toString(tsp::ThompsonSamplingPolicy) = "tsp"

function select_action(policy::ThompsonSamplingPolicy, estimator::ThompsonSamplingEstimator, rng::AbstractRNG)
    samples = [rand(rng, Beta(estimator.alpha[i], estimator.beta[i])) for i in 1:length(estimator.alpha)]
    return argmax(samples)
end
function select_action(policy::ThompsonSamplingPolicy, estimator::ThompsonSamplingEstimator)
    samples = [rand(Beta(estimator.alpha[i], estimator.beta[i])) for i in 1:length(estimator.alpha)]
    return argmax(samples)
end
