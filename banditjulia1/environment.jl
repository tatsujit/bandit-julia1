using Distributions

abstract type AbstractEnvironment end

struct Environment <: AbstractEnvironment
    n_arms::Int
    # distributions::AbstractVector{Distribution}
    distributions::AbstractVector{Distribution{Univariate}}
end
# TODO why Environment(distributions) is not working?
function Environment(distributions::AbstractVector{Distribution{Univariate}})
    n_arms = length(distributions)
    Environment(n_arms, distributions)
end

# when given only n_arms::Int, Bernoullis with uniformly partitioning (0, 1) into (n_arms+1) intervals
function Environment(n_arms::Int)
    distributions = [Bernoulli(x / (n_arms+1)) for x in 1:n_arms]
    Environment(distributions)
end

# as Bernoulli returns Boolean
function bool_to_float(x::Any)::Float64
    if isa(x, Bool)
        return convert(Float64, x)
    elseif isa(x, Float64)
        return x
    else
        throw(ArgumentError("Input must be Bool or Float64"))
    end
end
function sample_reward(env::Environment, arm::Int, rng::AbstractRNG)
    return bool_to_float(rand(rng, env.distributions[arm]))
end
function sample_reward(env::Environment, arm::Int)
    return bool_to_float(rand(env.distributions[arm]))
end
