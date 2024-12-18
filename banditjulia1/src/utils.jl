"""decompose a struct into its type and values copied from
[[https://qiita.com/hidemotoNakada/items/a3e24033b4d1f892077a][Juliaの構造体の分解と合成 #Julia - Qiita]]
"""
function decompose(target::Any)::Tuple{String, Vector{Any}}
    t = typeof(target)
    vals = [getproperty(target, name) for name in fieldnames(t)]
    (str = t, vals = vals)
end

"""get the fully expanded "includes" in a .jl file
(to make a single source file that can be inspected by someone or LLM).
Usage:
expanded_content = expand_includes("bandit1.jl")
write("bandit1_expanded.jl", expanded_content)
"""
function expand_includes(filename::String)::String
    dir = dirname(abspath(filename))
    content = read(filename, String)

    # Replace each include with the content of the included file
    expanded = replace(content, r"include\([\"'](.*?)[\"']\)" => function(m)
        included_file = match(r"[\"'](.*?)[\"']", m).captures[1]
        # Resolve path relative to the including file's directory
        full_path = joinpath(dir, included_file)
        # Recursively expand includes in the included file
        expand_includes(full_path)
    end)

    return expanded
end

"""
TODO: multiple dispatch and use of toString()
"""
function filename_suffix(sims::Int, trials::Int, n_arms::Int, ps::Vector{Float64}, estimator_str::String, policy_str::String, n_αs::Int, n_βs::Int, rseed::Int)::String
    prob_str = join(string.(Int.(100 .* ps), pad=3), "_")
    return "$(sim)sims-$(trials)trials-$(n_arms)-arms-$(prob_str)-$(estimator_str)-$(policy_str)-α-β-$(n_αs)x$(n_βs)param-rseed=$(rseed)-vs"
end
function filename_suffix(sims::Int, trials::Vector{Int}, n_arms::Int, ps::Vector{Float64}, estimator_str::String, policy_str::String, n_αs::Int, n_βs::Int, rseed::Int)::String
    prob_str = join(string.(Int.(100 .* ps), pad=3), "_")
    trial_str = join(string.(Int.(trials)), "_")
    return "$(sim)sims-$(trial_str)trials-$(n_arms)-arms-$(prob_str)-$(estimator_str)-$(policy_str)-α-β-$(n_αs)x$(n_βs)param-rseed=$(rseed)-vs"
end
function filename_suffix(sims::Int, trials::Int, n_arms::Int, ps::Vector{Float64}, estimator_str::String, policy_str::String, n_αps::Int, n_αns::Int, n_βs::Int, rseed::Int)::String
    prob_str = join(string.(Int.(100 .* ps), pad=3), "_")
    return "$(sim)sims-$(trials)trials-$(n_arms)-arms-$(prob_str)-$(estimator_str)-$(policy_str)-αp-αn-β-$(n_αps)x$(n_αns)x$(n_βs)param-rseed=$(rseed)-vs"
end

# ps = [0.1, 0.1, 0.1, 0.1, 0.5]
# prob_str = join(string.(Int.(100 .* ps), pad=3), delim="_")
# join(string.(
#     Int.(100 .* ps),
#     pad=3
# ),
#      "_")
