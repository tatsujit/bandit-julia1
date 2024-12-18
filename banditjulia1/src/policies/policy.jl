abstract type AbstractPolicy end

include("./epsilon_greedy.jl")
include("./softmax.jl")
include("./ucb.jl")
include("./ucb_turned.jl")
include("./satisficing.jl")
include("./thompson_sampling.jl")