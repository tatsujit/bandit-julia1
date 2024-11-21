# to be invoked by julia -p 4 bandit1.jl? but it doesn't compile the codes well?
import Pkg; Pkg.add("Optim")
using Random
using DataFrames
using Distributions
using StatsBase
# using Optim
using Distributed
include("utils.jl")
include("actionValueEstimator.jl")
include("policy.jl")
include("agent.jl")
include("environment.jl")
include("history.jl")
include("system.jl")
include("evaluation.jl")
include("heatmap.jl")
include("plot.jl")
