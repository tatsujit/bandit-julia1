abstract type AbstractHistory end # result
struct History <: AbstractHistory
    actions::Vector{Int}
    expectations::Vector{Vector{Float64}} # TODO 非定常環境を想定して、毎trialの期待値を保存する？　
    # TODO しかし、当平均で異分散の状況を扱いたくないか？　とくにリスク態度に関して
    rewards::Vector{Float64}
    function History(trials::Int, n_arms::Int)
        actions = zeros(Int64, trials)
        expectations = [zeros(n_arms) for _ in 1:trials]
        rewards = zeros(Float64, trials)
        new(actions, expectations, rewards)
    end
end
function print(history::History, verbose::Bool=false)
    trials = length(history.actions)
    if verbose
        println("trials: $(trials)")
        println("History: actions=$(history.actions)")
        println("expectations=$(history.expectations)")
        println("rewards=$(history.rewards)")
    else
        println("trials: $(trials)")
    end
end
function record!(history::History, trial::Int, action::Int, expectations::Vector{Float64}, reward::Float64, Qs::Vector{Float64})
    n_arms = length(expectations) #
    history.actions[trial] = action
    for i in 1:n_arms
        history.expectations[trial][i] = expectations[i]
    end
    # history.expectations[trial] = expectations
    history.rewards[trial] = reward
end

struct HistoryO <: AbstractHistory
    actions::Vector{Int}
    expectations::Vector{Vector{Float64}} # TODO 非定常環境を想定して、毎trialの期待値を保存する？　
    # TODO しかし、当平均で異分散の状況を扱いたくないか？　とくにリスク態度に関して
    rewards::Vector{Float64}
    function History(expected_trials::Int=0)
        actions = Vector{Int}(undef, 0)
        expectations = Vector{Vector{Float64}}()
        rewards = Vector{Float64}(undef, 0)
        if expected_trials > 0
            sizehint!(actions, expected_trials)
            sizehint!(expectations, expected_trials)
            sizehint!(rewards, expected_trials)
        end
        new(actions, expectations, rewards)
    end
end
function print(history::HistoryO, verbose::Bool=false)
    trials = length(history.actions)
    if verbose
        println("trials: $(trials)")
        println("History: actions=$(history.actions)")
        println("expectations=$(history.expectations)")
        println("rewards=$(history.rewards)")
    else
        println("trials: $(trials)")
    end
end
struct HistoryRich <: AbstractHistory
    actions::Vector{Int}
    expectationss::Vector{Vector{Float64}}
    rewards::Vector{Float64}
    Qss::Vector{Vector{Float64}}
end
# function HistoryRich()
#     actions = Vector{Int}(undef, 0)
#     expectations = Vector{Vector{Float64}}()
#     rewards = Vector{Float64}(undef, 0)
#     values = Vector{Vector{Float64}}()
#     HistoryRich(actions, expectations, rewards, values)
# end
function HistoryRich(expected_trials::Int=0)
    actions =       Vector{Int}(undef, 0)
    expectationss = Vector{Vector{Float64}}()
    rewards =       Vector{Float64}(undef, 0)
    Qss     =       Vector{Vector{Float64}}()
    if expected_trials > 0
        sizehint!(actions, expected_trials)
        sizehint!(expectationss, expected_trials)
        sizehint!(rewards, expected_trials)
        sizehint!(Qss, expected_trials)
    end
    HistoryRich(actions, expectationss, rewards, Qss)
end
function print(history::HistoryRich)
    trials = length(history.actions)
    println("trials: $(trials)")
    println("History: ")
    println("actions=$(history.actions)")
    # println("expectationss=$(history.expectationss)")
    println("rewards=$(history.rewards)")
    println("Qss=$(history.Qss)")
end
function record!(history::HistoryO, trial::Int, action::Int, expectations::Vector{Float64}, reward::Float64, Qs::Vector{Float64})
    push!(history.actions, action)
    push!(history.expectations, expectations)
    push!(history.rewards, reward)
end
function record!(history::HistoryRich, trial::Int, action::Int, expectations::Vector{Float64}, reward::Float64, Qs::Vector{Float64}, verbose::Bool=false)
    if verbose
        println("Qs: $(Qs)")
        println("history.Qss: $(history.Qss)")
    end
    push!(history.actions, action)
    push!(history.rewards, reward)
    push!(history.expectationss, copy(expectations))
    push!(history.Qss, copy(Qs))
end
# function to_dataframe(history::History)
#     DataFrame(action = history.actions, expectations = history.expectations, reward = history.rewards)
# end
function to_dataframe(history::HistoryRich)
    DataFrame(action = history.actions, expectationss = history.expectationss, reward = history.rewards, Qss = history.Qss)
end
