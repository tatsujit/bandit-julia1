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