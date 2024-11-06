abstract type AbstractActionValueEstimator end
# Sample Average Estimator (Standard Q-Learning)
mutable struct SampleAverageEstimator <: AbstractActionValueEstimator
    Q::Vector{Float64}
    N::Vector{Int}
    SampleAverageEstimator(n_arms::Int) = new(zeros(n_arms), zeros(Int, n_arms))
end

# TODO validate anyway
function update!(estimator::SampleAverageEstimator, action::Int, reward::Float64)
    estimator.N[action] += 1
    estimator.Q[action] += (reward - estimator.Q[action]) / estimator.N[action]
end

# Differential Learning Rate (DLR) Estimator
mutable struct QEstimator <: AbstractActionValueEstimator
    Q::Vector{Float64}
    α::Float64
    QEstimator(α::Float64, n_arms::Int) = new(zeros(n_arms), α)
end

function update!(estimator::QEstimator, action::Int, reward::Float64)
    δ = reward - estimator.Q[action]
    estimator.Q[action] += estimator.α * δ
end

# Differential Learning Rate (DLR) Estimator
mutable struct DLREstimator <: AbstractActionValueEstimator
    Q::Vector{Float64}
    alpha_pos::Float64
    alpha_neg::Float64
    DLREstimator(alpha_pos::Float64, alpha_neg::Float64, n_arms::Int) = new(zeros(n_arms), alpha_pos, alpha_neg)
end

function update!(estimator::DLREstimator, action::Int, reward::Float64)
    δ = reward - estimator.Q[action]
    if δ >= 0
        estimator.Q[action] += estimator.alpha_pos * δ
    else
        estimator.Q[action] += estimator.alpha_neg * δ
    end
end

# Thompson Sampling Estimator (for Beta-Bernoulli Bandits)
mutable struct ThompsonSamplingEstimator <: AbstractActionValueEstimator
    alpha::Vector{Float64}
    beta::Vector{Float64}
    ThompsonSamplingEstimator(n_arms::Int) = new(ones(n_arms), ones(n_arms))
end

function update!(estimator::ThompsonSamplingEstimator, action::Int, reward::Float64)
    # Assuming reward is 0 or 1 (Bernoulli)
    estimator.alpha[action] += reward
    estimator.beta[action] += 1 - reward
end
