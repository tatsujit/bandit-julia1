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