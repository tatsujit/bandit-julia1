abstract type AbstractSystem end
# System Definition
struct System <: AbstractSystem
    agent::Agent
    env::Environment
    history::AbstractHistory
    rng::AbstractRNG  # Add RNG to System
end
function System(agent::Agent, env::Environment, rng::AbstractRNG)
    history = History()
    System(agent, env, history, rng)
end
# System Definition
struct SystemRich <: AbstractSystem
    agent::Agent
    env::Environment
    history::AbstractHistory
    rng::AbstractRNG  # Add RNG to System
end
function SystemRich(agent::Agent, env::Environment, rng::AbstractRNG)
    history = HistoryRich()
    System(agent, env, history, rng)
end
# Step Function for the System
function step!(system::System)
    agent = system.agent
    estimator = agent.estimator
    policy = agent.policy
    rng = system.rng
    action = select_action(policy, estimator, rng)
    # TODO make this a function and generalize it to non-Bernoulli rewards
    expectations = [system.env.distributions[i].p for i in 1:n_arms]
    reward = sample_reward(system.env, action, rng)
    record!(system.history, action, expectations, reward, estimator.Q)
    update!(estimator, action, reward)
    # Update sum of squares for UCB-Tuned Policy if used
    if isa(policy, UCBTunedPolicy) && isa(estimator, SampleAverageEstimator)
        policy.sum_of_squares[action] += reward^2
    end
end
