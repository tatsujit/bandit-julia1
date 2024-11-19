using Random
using Distributions
using StatsBase

abstract type AbstractEnvironment end

struct Environment <: AbstractEnvironment
    n_arms::Int
    # distributions::AbstractVector{Distribution}
    distributions::AbstractVector{Distribution{Univariate}}

    # # TODO why Environment(distributions) is not working?
    # function Environment(n_arms::Int, distributions::AbstractVector{Distribution{Univariate}})
    #     new(n_arms, distributions)
    # end
    #
    # function Environment(distributions::AbstractVector{Distribution{Univariate}})
    #     n_arms = length(distributions)
    #     new(n_arms, distributions)
    # end
    #
    # # when given only n_arms::Int, Bernoullis with uniformly partitioning (0, 1) into (n_arms+1) intervals
    # function Environment(n_arms::Int)
    #     distributions = [Bernoulli(x / (n_arms+1)) for x in 1:n_arms]
    #     Environment(distributions)
    # end
end

""" for environments with limited available arms at each trial. LA stands for limited availability"""
struct LAEnvironment <: AbstractEnvironment
    n_arms::Int
    n_avail_arms::Int
    # distributions::AbstractVector{Distribution}
    distributions::AbstractVector{Distribution{Univariate}}
    available_arms::AbstractVector{Int}
    # available_arms::AbstractVector{Bool} # Bool の方が良いかもしれないよな。または文字列 "TFFTT" とか
end
""" usage: `dist_to_means.(env.distributions)` """
function dist_to_means(dist::Distribution{Univariate})
    if isa(dist, Bernoulli)
        return dist.p
    elseif isa(dist, Normal)
        return mean(dist)
    else
        throw(ArgumentError("Input must be Bernoulli or Normal"))
    end
end
# # TODO これは型的にちょっとわからんのであとで考える
# function dists_to_means(dists::AbstractVector{Distribution{Univariate}})
#     if isa(dists[1], Bernoulli)
#         return dists.p
#     elseif isa(dists, Normal)
#         return mean(dist)
#     else
#         throw(ArgumentError("Input must be Bernoulli or Normal"))
#     end
# end

"""as a Bernoulli returns a Boolean"""
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

function sample_reward(env::LAEnvironment, arm::Int, rng::AbstractRNG)
    return bool_to_float(rand(rng, env.distributions[arm]))
end
function sample_reward(env::LAEnvironment, arm::Int)
    return bool_to_float(rand(env.distributions[arm]))
end
