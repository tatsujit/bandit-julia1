module banditjulia1
export run!, step!,
    Agent, Environment, History, System

using Random

include("models.jl")
using .Models

include("./utils.jl")
include("./agent.jl")
include("./environment.jl")
include("./history.jl")
include("./system.jl")
include("./evaluation.jl")

function run!(system::AbstractSystem, trials::Int)
    for trial in 1:trials
        step!(system, trial)
    end
end

end # module banditjulia1