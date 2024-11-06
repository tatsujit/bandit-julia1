abstract type AbstractHistory end # result
# なんか push!() を 1,000,000 回とかするのもなんなんで、
# trials については hint を与えられるようにした
struct History <: AbstractHistory
    actions::Vector{Int}
    expectations::Vector{Vector{Float64}} # TODO 非定常環境を想定して、毎trialの期待値を保存する
    rewards::Vector{Float64}
end
function History(expected_trials::Int=0)
    actions = Vector{Int}(undef, 0)
    expectations = Vector{Vector{Float64}}()
    rewards = Vector{Float64}(undef, 0)
    if expected_trials > 0
        sizehint!(actions, expected_trials)
        sizehint!(expectations, expected_trials)
        sizehint!(rewards, expected_trials)
    end
    History(actions, expectations, rewards)
end
struct HistoryRich <: AbstractHistory
    actions::Vector{Int}
    expectations::Vector{Vector{Float64}}
    rewards::Vector{Float64}
    values::Vector{Vector{Float64}}
end
function HistoryRich(expected_trials::Int=0)
    actions = Vector{Int}(undef, 0)
    expectations = Vector{Vector{Float64}}()
    rewards = Vector{Float64}(undef, 0)
    values = Vector{Vector{Float64}}()
    if expected_trials > 0
        sizehint!(actions, expected_trials)
        sizehint!(expectations, expected_length)
        sizehint!(rewards, expected_trials)
        sizehint!(values, expected_trials)  # for the length of the outer pointer array
    end
    HistoryRich(actions, expectations, rewards, values)
end
function record!(history::History, action::Int, expectations::Vector{Float64}, reward::Float64, values::Vector{Float64})
    push!(history.actions, action)
    push!(history.expectations, expectations)
    push!(history.rewards, reward)
end
function record!(history::HistoryRich, action::Int, expectations::Vector{Float64}, reward::Float64, values::Vector{Float64})
    push!(history.actions, action)
    push!(history.expectations, expectations)
    push!(history.rewards, reward)
    push!(history.values, values)
end
function to_dataframe(history::History)
    DataFrame(action = history.actions, expectations = history.expectations, reward = history.rewards)
end
function to_dataframe(history::HistoryRich)
    DataFrame(action = history.actions, expectations = history.expectations, reward = history.rewards, value = history.values)
end
