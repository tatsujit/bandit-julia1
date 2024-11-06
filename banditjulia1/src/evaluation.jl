abstract type AbstractEvaluation end # evaluated result

struct Evaluation <: AbstractEvaluation
    cum_rewards::Vector{Float64}
    accuracy::Vector{Float64}
    relative_accuracy::Vector{Float64}
    entropy::Vector{Float64}
    regret::Vector{Float64}
end
function Evaluation(expected_trials::Int=0)
    cum_rewards = Vector{Float64}(undef, 0)
    accuracy = Vector{Float64}(undef, 0)
    relative_accuracy = Vector{Float64}(undef, 0)
    entropy = Vector{Float64}(undef, 0)
    regret = Vector{Float64}(undef, 0)
    if expected_trials > 0
        sizehint!(cum_rewards, expected_trials)
        sizehint!(accuracy, expected_trials)
        sizehint!(relative_accuracy, expected_trials)
        sizehint!(entropy, expected_trials)
        sizehint!(regret, expected_trials)
    end
    Evaluation(rewards, accuracy, relative_accuracy, regret)
end
# optimal_arm の情報が必要、だから、dist の情報が必要
function evaluate(history::AbstractHistory)
    cum_rewards = accumulate(+, history.rewards)
    n_trials = length(rewards)
    accuracy = sum(rewards) / n_trials # TODO
    relative_accuracy = accuracy - 1 / 2 # TODO
    entropy = -sum([p * log(p) for p in [mean(rewards .== i) for i in 0:1]])
    regret = sum([maximum([mean(history.rewards[1:t]) for t in 1:n_trials]) - sum(history.rewards[1:t]) for t in 1:n_trials])
    Evaluation([accuracy], [relative_accuracy], [entropy], [regret])
end
