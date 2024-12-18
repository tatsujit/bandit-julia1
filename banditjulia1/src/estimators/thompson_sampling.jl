# Thompson Sampling Estimator (for Beta-Bernoulli Bandits)
mutable struct ThompsonSamplingEstimator <: AbstractActionValueEstimator
    alpha::Vector{Float64}
    beta::Vector{Float64}
    ThompsonSamplingEstimator(n_arms::Int) = new(ones(n_arms), ones(n_arms))
end
toString(thompsonSamplingEstimator::ThompsonSamplingEstimator) = "T"

function update!(estimator::ThompsonSamplingEstimator, action::Int, reward::Float64)
    # Assuming reward is 0 or 1 (Bernoulli)
    estimator.alpha[action] += reward
    estimator.beta[action] += 1 - reward
end