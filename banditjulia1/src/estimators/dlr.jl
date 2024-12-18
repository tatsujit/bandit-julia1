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