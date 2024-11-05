abstract type AbstractActionValueEstimator end
# Sample Average Estimator (Standard Q-Learning)
mutable struct SampleAverageEstimator <: AbstractActionValueEstimator
    Q::Vector{Float64}
    N::Vector{Int}
end

function SampleAverageEstimator(n_arms::Int)
    Q = zeros(n_arms)
    N = zeros(Int, n_arms)
    SampleAverageEstimator(Q, N)
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
end

function QEstimator(α::Float64, n_arms::Int)
    Q = zeros(n_arms)
    QEstimator(Q, α)
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
end

function DLREstimator(alpha_pos::Float64, alpha_neg::Float64, n_arms::Int)
    Q = zeros(n_arms)
    DLREstimator(Q, alpha_pos, alpha_neg)
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
end

function ThompsonSamplingEstimator(n_arms::Int)
    alpha = ones(n_arms)
    beta = ones(n_arms)
    ThompsonSamplingEstimator(alpha, beta)
end

function update!(estimator::ThompsonSamplingEstimator, action::Int, reward::Float64)
    # Assuming reward is 0 or 1 (Bernoulli)
    estimator.alpha[action] += reward
    estimator.beta[action] += 1 - reward
end
