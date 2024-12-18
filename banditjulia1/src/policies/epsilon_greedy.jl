struct EpsilonGreedyPolicy <: AbstractPolicy
    ϵ::Float64
end

toString(epg::EpsilonGreedyPolicy) = "epg($(egp.ϵ))"

function select_action(policy::EpsilonGreedyPolicy, estimator::AbstractActionValueEstimator, rng::AbstractRNG)
    n_arms = length(estimator.Q)
    if rand(rng) < policy.ϵ
        return rand(rng, 1:n_arms)
    else
        return argmax(estimator.Q)
    end
end