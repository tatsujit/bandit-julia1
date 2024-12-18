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