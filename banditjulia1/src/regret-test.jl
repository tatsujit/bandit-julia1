include("q-heatmap.jl")

# test if the regret for each history is monotonic as it is ought to be
is_monotonic(v::Vector) = all(diff(v) .>= 0)
is_monotonic(syss[1].history.regrets)

sum([is_monotonic(evaluations[i].regret) for i in 1:sims]) == sims #=> true
# OK
