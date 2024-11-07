abstract type AbstractActionValueEstimator end
function toString(abstractActionValueEstimator::AbstractActionValueEstimator, verbose::Bool=false)::String
    dc = decompose(abstractActionValueEstimator)
    verbose ? dc : dc.str
end
# sample average estimator (standard bandit action values)
mutable struct SampleAverageEstimator <: AbstractActionValueEstimator
    Q::Vector{Float64}
    N::Vector{Int}
    SampleAverageEstimator(n_arms::Int) = new(zeros(n_arms), zeros(Int, n_arms))
end
toString(sampleAverageEstimator::SampleAverageEstimator) = "S"
function toString(sampleAverageEstimator::SampleAverageEstimator, verbose::Bool=false)
    dc = decompose(sampleAverageEstimator)
    verbose ? dc : str
end
# TODO: validate anyway
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
toString(qEstimator::QEstimator) = "Q"
function update!(estimator::QEstimator, action::Int, reward::Float64)
    δ = reward - estimator.Q[action]
    estimator.Q[action] += estimator.α * δ
end

# Differential Learning Rate (DLR) Estimator
mutable struct DLREstimator <: AbstractActionValueEstimator
    Q::Vector{Float64}
    αp::Float64
    αn::Float64
    DLREstimator(alpha_pos::Float64, alpha_neg::Float64, n_arms::Int) = new(zeros(n_arms), alpha_pos, alpha_neg)
end
toString(dlrEstimator::DLREstimator) = "D"
function update!(estimator::DLREstimator, action::Int, reward::Float64)
    δ = reward - estimator.Q[action]
    if δ >= 0
        estimator.Q[action] += estimator.αp * δ
    else
        estimator.Q[action] += estimator.αn * δ
    end
end

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
