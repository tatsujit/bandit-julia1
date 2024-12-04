# import Pkg; Pkg.add("CairoMakie")
using CairoMakie

"""
表示する3つのパラメータのうちの一つに対して、適切な行数と列数を返す。
行数 ≤ 列数 となる範囲で、なるべく正方形に近い形になるようにしている。
"""
function int_to_panel_dim(n_display::Int)::Tuple{Int, Int}
    rows = Int(round(sqrt(n_display)))
    cols = Int(ceil(n_display / rows))
    return (rows, cols)
end
"""
表示するパラメータの値のindexを作る
"""
function display_indices(n_display::Int, size_display::Int)::Vector{Int}
    # .+ 1  to avoid beta=0.0 and so on?
    round.(((1:n_display) ./ n_display) .* size_display)
end

"""
regret_matrix には、各 (α, β, trial) に対する regret の値の、3次元配列が入っている
αps, αns, βs は実際のそれらパラメータの値の配列
"""
function create_regret_heatmaps_DLR(regrets_matrix::Array{Float64, 3},
                                    params_and_regrets::Vector{Vector{Float64}},
                                    αps::StepRangeLen{Float64}, αns::StepRangeLen{Float64}, βs_display::Int,
                                    eachRow::Bool=true)
    # dependent on the parameter to get fixed
    x_label = "Learning Rate (α+)"
    y_label = "Learning Rate (α-)"
    fixed_parameter = "β"
    n_display = βs_display
    display_dim = 3
    # below independent of the parameter to get fixed
    f = Figure(size = (700, 600)) # or XGA
    size_display = size(regrets_matrix, display_dim) # variation of the fixed parameter
    n_display = (n_display >= size_display) ? size_display : n_display # number of display (<= size_display)
    d_indices = display_indices(n_display, size_display) # which indices to display
    @ic(d_indices)
    rows, cols = int_to_panel_dim(n_display)
    params_fixed = [x[display_dim] for x in params_and_regrets]
    fixed_parameter_values = sort(collect(Set(params_fixed)))
    @ic(fixed_parameter_values)

    # color scale definition begin
    if eachRow # color scale by row
        regret_ranges = []
        for row in 1:rows
            # rgrts = [x[4] for x in params_and_regrets if x[3] ∈ d_indices[(cols-1)*i:cols*i-1]]
            # vals = fixed_parameter_values[d_indices[(cols-1)*row:cols*row-1]]
            vals = [fixed_parameter_values[i] for i in d_indices[(cols-1)*row:cols*row-1]]
            rgrts = [x[4] for x in params_and_regrets if x[3] ∈ vals]
            regret_range = (reg_min, reg_max) = (minimum(rgrts), maximum(rgrts))
            push!(regret_ranges, regret_range)
        end
    else # color scale for all plots
        rgrts = [x[4] for x in params_and_regrets]
        regret_range = (reg_min, reg_max) = (minimum(rgrts), maximum(rgrts))
        regret_ranges = [ regret_range regret_range regret_range ]
    end
    colorrange_map = regret_ranges
    # color scale definition end

    # again the next line dependent on the parameter to get fixed
    println("n_display: $(n_display), size_display: $(size_display), rows: $(rows), cols: $(cols)")
    for row in 1:rows, col in 1:cols
        i = cols*(row-1)+col
        if i > n_display
            break
        else
            xlabel = row == rows ? x_label : ""
            ylabel = col == 1 ? y_label : ""
            ax = Axis(f[row, col],
                      title = "$(fixed_parameter) = $(fixed_parameter_values[d_indices[i]])",
                      xlabel = xlabel,
                      ylabel = ylabel,
                      aspect = 1)
            # no transposition of regrets_matrix
            hm = heatmap!(ax, αps, αns, regrets_matrix[:,:,d_indices[i]], colorrange = colorrange_map[row])
            Colorbar(f[row, cols + 1], hm, label = "Regret")
        end
    end
    f
end

"""
regret_matrix には、各 (α, β, trial) に対する regret の値の、3次元配列が入っている
αs, βs は実際のそれらパラメータの値の配列、trials も実際の trials の値
"""
function create_regret_heatmaps_Q_trials(regrets_matrix::Array{Float64, 3},
                                         params_and_regrets::Vector{Vector{Float64}},
                                         αs::StepRangeLen{Float64}, βs::StepRangeLen{Float64},
                                         trials::Vector{Int}, eachRow::Bool=true)
    # dependent on the parameter to get fixed
    fixed_parameter = "trials"
    n_display = length(trials)
    x_label = "Learning Rate (α)"
    y_label = "Inv. Temp. (β)"
    display_dim = 3 # of which dimension in regrets_matrix the fixed parameter is
    # below independent of the parameter to get fixed
    f = Figure(size = (700, 600)) # or XGA
    size_display = size(regrets_matrix, display_dim) # variation of the fixed parameter
    n_display = (n_display >= size_display) ? size_display : n_display # number of display (<= size_display)
    d_indices = display_indices(n_display, size_display) # which indices to display
    rows, cols = int_to_panel_dim(n_display)
    # again the next line dependent on the parameter to get fixed
    params_fixed = [x[display_dim] for x in params_and_regrets]
    fixed_parameter_values = sort(collect(Set(params_fixed)))
    @ic(fixed_parameter_values)

    # color scale definition begin
    if eachRow # color scale by row
        regret_ranges = []
        for row in 1:rows
            vals = [fixed_parameter_values[i] for i in d_indices[(cols-1)*row:cols*row-1]]
            rgrts = [x[4] for x in params_and_regrets if x[3] ∈ vals]
            regret_range = (reg_min, reg_max) = (minimum(rgrts), maximum(rgrts))
            push!(regret_ranges, regret_range)
        end
    else # color scale for all plots
        rgrts = [x[4] for x in params_and_regrets]
        regret_range = (reg_min, reg_max) = (minimum(rgrts), maximum(rgrts))
        regret_ranges = [ regret_range regret_range regret_range ]
    end
    colorrange_map = regret_ranges
    # color scale definition end

    println("n_display: $(n_display), size_display: $(size_display), rows: $(rows), cols: $(cols)")
    for row in 1:rows, col in 1:cols
        i = cols*(row-1)+col
        if i > n_display
            break
        else
            xlabel = row == rows ? x_label : ""
            ylabel = col == 1 ? y_label : ""
            ax = Axis(f[row, col],
                      title = "$(fixed_parameter) = $(Int(round(fixed_parameter_values[d_indices[i]])))",
                      xlabel = xlabel,
                      ylabel = ylabel,
                      aspect = 1)
            # no transposition of regrets_matrix
            # hm = heatmap!(ax, αs, βs, regrets_matrix[:,:,d_indices[i]])
            hm = heatmap!(ax, αs, βs, regrets_matrix[:,:,d_indices[i]], colorrange = colorrange_map[row])
            Colorbar(f[row, cols + 1], hm, label = "Regret")
        end
    end
    f
end
