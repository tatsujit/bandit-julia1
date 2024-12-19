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