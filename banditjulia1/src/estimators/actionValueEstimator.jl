abstract type AbstractActionValueEstimator end
function toString(abstractActionValueEstimator::AbstractActionValueEstimator, verbose::Bool=false)::String
    dc = decompose(abstractActionValueEstimator)
    verbose ? dc : dc.str
end

include("./sample_average.jl")
include("./q.jl")
include("./dlr.jl")
include("./thompson_sampling.jl")