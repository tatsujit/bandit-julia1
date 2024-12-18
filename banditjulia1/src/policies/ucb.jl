# UCB Policy
struct UCBPolicy <: AbstractPolicy
    c::Float64
    t::Int
    function UCBPolicy(c::Float64)
        new(c, 0)
    end
end

toString(ucb::UCBPolicy) = "ucb($(ucb.c))"

function select_action(policy::UCBPolicy, estimator::SampleAverageEstimator)
    policy.t += 1
    n_arms = length(estimator.Q)
    ucb_values = zeros(n_arms)
    for i in 1:n_arms
        if estimator.N[i] == 0
            return i # Try each arm at least once
        else
            ucb_values[i] = estimator.Q[i] + policy.c * sqrt(log(policy.t) / estimator.N[i])
        end
    end
    return argmax(ucb_values)
end