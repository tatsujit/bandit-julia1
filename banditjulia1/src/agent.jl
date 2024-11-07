# Agent Definition
struct Agent
    estimator::AbstractActionValueEstimator
    policy::AbstractPolicy
end
toString(agent::Agent) = "$(toString(agent.estimator))_$(toString(agent.policy))"
