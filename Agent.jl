# Agent Definition
struct Agent
    estimator::AbstractActionValueEstimator
    policy::AbstractPolicy
end
