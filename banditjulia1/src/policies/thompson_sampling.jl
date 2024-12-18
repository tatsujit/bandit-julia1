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