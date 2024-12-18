# UCB-Tuned Policy
struct UCBTunedPolicy <: AbstractPolicy
    t::Int
    sum_of_squares::Vector{Float64}
    function UCBTunedPolicy(n_arms::Int)
        new(0, zeros(n_arms))
    end
end

toString(ut1::UCBTunedPolicy) = "ut1"

function select_action(policy::UCBTunedPolicy, estimator::SampleAverageEstimator)
    policy.t += 1
    n_arms = length(estimator.Q)
    ucb_values = zeros(n_arms)
    for i in 1:n_arms
        if estimator.N[i] == 0
            return i # Try each arm at least once
        else
            mean = estimator.Q[i]
            variance = (policy.sum_of_squares[i] / estimator.N[i]) - mean^2
            variance = max(variance, 0) + sqrt(2 * log(policy.t) / estimator.N[i])
            ucb_values[i] = mean + sqrt((log(policy.t) / estimator.N[i]) * min(0.25, variance))
        end
    end
    return argmax(ucb_values)
end