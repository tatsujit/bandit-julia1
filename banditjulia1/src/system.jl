abstract type AbstractSystem end
function toString(abstractSystem::AbstractSystem)::String
    typeof(abstractSystem)
end
# System Definition
struct System <: AbstractSystem
    agent::Agent
    env::Environment
    history::AbstractHistory
    rng::AbstractRNG  # Add RNG to System
end
function toString(system::System, verbose::Bool)
    dc = decompose(system)
    verbose ? dc : toString(system)
end
struct SystemLA <: AbstractSystem
    agent::Agent
    env::LAEnvironment
    history::AbstractHistory
    rng::AbstractRNG  # Add RNG to System
end
function toString(system::System, verbose::Bool)
    dc = decompose(system)
    verbose ? dc : toString(system)
end
# # System Definition
# struct SystemRich <: AbstractSystem
#     agent::Agent
#     env::Environment
#     history::AbstractHistory
#     rng::AbstractRNG  # Add RNG to System
# end
# function SystemRich(agent::Agent, env::Environment, rng::AbstractRNG)
#     history = HistoryRich()
#     System(agent, env, history, rng)
# end
# Agent 側の処理として、可能な行動をインデックスリストまたはブールリストで受け取り、
# 行動をインデックスで返す。ということは、
function sample_available_arms!(sys::SystemLA)
    # randomly choose n_arms from distributions
    a_arms = sample(sys.rng, 1:sys.env.n_arms, sys.env.n_avail_arms, replace=false)
    sys.env.available_arms = [i in a_arms for i in 1:env.n_arms]
end

# Step Function for the System
function step!(system::AbstractSystem, trial::Int, verbose::Bool=false)
    # localizing variables
    agent = system.agent
    estimator = agent.estimator
    policy = agent.policy
    rng = system.rng
    n_arms = system.env.n_arms

    # debug
    # println(estimator)

    # action selection
    action = select_action(policy, estimator, rng)
    # TODO make this a function and generalize it to non-Bernoulli rewards
    expectations = [system.env.distributions[i].p for i in 1:n_arms]
    # reward as evaluative feedback
    reward = sample_reward(system.env, action, rng)

    if verbose
        println()
        println("t: $t, action: $action, reward: $reward")
        println("before update: $(estimator.Q)")
    end
    # update action value estimates
    update!(estimator, action, reward)
    if verbose
        println("after update: $(estimator.Q)")
    end
    # record an era in the history
    record!(system.history, trial, action, expectations, reward, estimator.Q)
    if verbose
        println(action, expectations, reward, estimator.Q)
    end
    # Update sum of squares for UCB-Tuned Policy if used
    if isa(policy, UCBTunedPolicy) && isa(estimator, SampleAverageEstimator)
        policy.sum_of_squares[action] += reward^2
    end
end
"""Run the Simulation for the system for the given number of trials"""
function run!(system::AbstractSystem, trials::Int)
    for trial in 1:trials
        step!(system, trial)
    end
end
