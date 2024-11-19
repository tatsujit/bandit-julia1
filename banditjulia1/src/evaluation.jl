abstract type AbstractEvaluation end # evaluated result

struct Evaluation <: AbstractEvaluation
    cum_rewards::Vector{Float64}
    accuracy::Vector{Float64}
    relative_accuracy::Vector{Float64}
    # entropy::Vector{Float64}
    regret::Vector{Float64}
end
function Evaluation(expected_trials::Int=0)
    cum_rewards = Vector{Float64}(undef, 0)
    accuracy = Vector{Float64}(undef, 0)
    relative_accuracy = Vector{Float64}(undef, 0)
    # entropy = Vector{Float64}(undef, 0)
    regret = Vector{Float64}(undef, 0)
    if expected_trials > 0
        sizehint!(cum_rewards, expected_trials)
        sizehint!(accuracy, expected_trials)
        sizehint!(relative_accuracy, expected_trials)
        # sizehint!(entropy, expected_trials)
        sizehint!(regret, expected_trials)
    end
    Evaluation(rewards, accuracy, relative_accuracy, regret)
end
# # optimal_arm の情報が必要、だから、dist の情報が必要
# function evaluate(history::AbstractHistory)
#     cum_rewards = accumulate(+, history.rewards)
#     n_trials = length(rewards)
#     accuracy = sum(rewards) / n_trials # TODO
#     relative_accuracy = accuracy - 1 / 2 # TODO
#     entropy = -sum([p * log(p) for p in [mean(rewards .== i) for i in 0:1]])
#     regret = sum([maximum([mean(history.rewards[1:t]) for t in 1:n_trials]) - sum(history.rewards[1:t]) for t in 1:n_trials])
#     Evaluation([accuracy], [relative_accuracy], [entropy], [regret])
# end
"""relative accuracy calculated from regret;
relative accuracy is like non-cumulative normalized regret.
for an arm /i/ with reward probability p_i,
- p_i == p_max → 1,
- p_i == p_min → 0,
- otherwise → (p_i - p_min) / (p_max - p_min)
"""
# function relative_accuracy(regrets::Vector{Float64}, means::Vector{Float64})::Vector{Float64}
#     # relative_accuracy = [(regrets[t] / mean_max_difference) for t in 1:n_trials] #
#     relative_accuracy = regrets / mean_max_difference
#     return relative_accuracy
#     # n_trials = length(regrets)
#     # mean_max_difference = maximum(means) - minimum(means)
#     # # relative_accuracy = [(regrets[t] / mean_max_difference) for t in 1:n_trials] #
#     # relative_accuracy = regrets / mean_max_difference
#     # return relative_accuracy
# end
"""Evaluate the system's history.
Input is a system, no the history, because the info of reward probability distributions is necessary for performance evaluation such as regret.
"""
function evaluate(system::AbstractSystem)
    n_arms = system.env.n_arms
    rewards = system.history.rewards
    n_trials = length(rewards)
    cum_rewards = accumulate(+, rewards)
    arms_means = [system.env.distributions[i].p for i in 1:n_arms]
    max_mean = maximum(arms_means)
    optimal_arms = [i for i in n_arms if arms_means[i] == max_mean]
    # optimal_arm = optimal_arms[1]
    actions = system.history.actions
    accuracy = accurate(actions, optimal_arms)
    regrets = [max_mean - arms_means[actions[t]] for t in 1:n_trials]
    regret = accumulate(+, regrets)
    max_regret = max_mean - minimum(arms_means)
    relative_accuracy = (1 .- regrets) / max_regret
    # TODO entropy は移動平均かな？　集団でみてもいいけども
    # entropy = -sum([p * log(p) for p in [mean(rewards .== i) for i in 0:1]])
    Evaluation(cum_rewards, accuracy, relative_accuracy, regret)
end
"""TODO: make a version where the input is smaller? (than the whole System?)"""
function regret(system::AbstractSystem)::Float64
    n_trials = length(system.history.rewards)
    n_arms = system.env.n_arms
    optimal_arms = [i for i in n_arms if arms_mean[i] == max_mean]
    arms_means = [system.environment.distributions[i].p for i in n_arms]
    max_mean = maximum(arms_means)
    actions = system.history.actions
    regrets = [max_mean - arms_means[actions[t]] for t in 1:n_trials]
    regret = sum(regrets)
    return regret
end
"""If an action is one of the optimal arms, return true."""
function accurate(action::Int, optimal_arms::Vector{Int})::Bool
    return (action in optimal_arms)
end
"""Return a vector of booleans res, res[t] == true if action at trial /t/ is accurate."""
function accurate(actions::Vector{Int}, optimal_arms::Vector{Int})::Vector{Bool}
    [accurate(action, optimal_arms) for action in actions]
end
"""Return a vector of booleans res, res[t] == true if action at trial /t/ is accurate, and the optimal arms change over time (non-stationary environment)."""
function accurate(actions::Vector{Int}, optimal_arms::Vector{Vector{Int}})::Vector{Bool}
    trials = length(optimal_arms)
    [accurate(actions[t], optimal_arms[t]) for t in 1:trials]
end

"""Evaluate the system's history, when the environment is nonstationary.
TODO: direct dispatch according to the environment or system type?
"""
function evaluate_nonstationary(system::AbstractSystem)
    n_arms = system.env.n_arms
    rewards = system.history.rewards
    cum_rewards = accumulate(+, rewards)
    n_trials = length(rewards)
    arms_mean = [system.environment.distributions[i].p for i in n_arms]
    max_mean = maximum(arms_mean)
    optimal_arms = [i for i in n_arms if arms_mean[i] == max_mean]
    # optimal_arm = optimal_arms[1]
    accuracy = sum(rewards) / n_trials # TODO
    relative_accuracy = accuracy - 1 / 2 # TODO
    entropy = -sum([p * log(p) for p in [mean(rewards .== i) for i in 0:1]])
    regret = sum([maximum([mean(history.rewards[1:t]) for t in 1:n_trials]) - sum(history.rewards[1:t]) for t in 1:n_trials])
    Evaluation([accuracy], [relative_accuracy], [entropy], [regret])
end
