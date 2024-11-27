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
function display_indices(n_display::Int, size_display::Int)::Vector{Int}
    # .+ 1  to avoid beta=0.0 and so on?
    round.(((1:n_display) ./ n_display) .* size_display)
end

"""
TODO: heatmap の色を複数プロットで揃えたい（比較のため）
TODO: それぞれの色を調整するために、最大値と最小値を取得する？
regret_matrix には、各 (α, β, trial) に対する regret の値の、3次元配列が入っている
αps, αns, βs は実際のそれらパラメータの値の配列
# trials も実際の trials の値
"""
function create_regret_heatmaps_DLR(regrets_matrix::Array{Float64, 3},
                                params_and_regrets::Vector{Vector{Float64}},
                                αps::StepRangeLen{Float64}, αns::StepRangeLen{Float64}, βs_display::Int)
    # dependent on the parameter to get fixed
    fixed_parameter = "β"
    n_display = βs_display
    x_parameter = "Learning Rate (α+)"
    y_parameter = "Learning Rate (α-)"
    display_dim = 3
    # below independent of the parameter to get fixed
    f = Figure(size = (800, 600)) # or XGA
    size_display = size(regrets_matrix, display_dim)
    n_display = (n_display >= size_display) ? size_display : n_display
    d_indices = display_indices(n_display, size_display)
    # color scale by row
    colorrange_map = [
        (10, 60)
        (10, 60)
        (10, 60)
    ]
    # again the next line dependent on the parameter to get fixed
    # print params_and_regrets
    # println("params_and_regrets: ", params_and_regrets)
    # @ic(d_indices)
    fixed_parameter_values = sort(collect(Set([params_and_regrets[i][display_dim] for i in 1:length(params_and_regrets)])))
    @ic(fixed_parameter_values)
    rows, cols = int_to_panel_dim(n_display)
    println("n_display: $(n_display), size_display: $(size_display), rows: $(rows), cols: $(cols)")
    for row in 1:rows, col in 1:cols
        i = cols*(row-1)+col
        if i > n_display
            break
        else
            xlabel = ylabel = ""
            if row == rows
                xlabel = "Learning Rate (α+)"
            end
            if col == 1
                ylabel = "Learning Rate (α-)"
            end
            ax = Axis(f[row, col],
                      title = "$(fixed_parameter) = $(fixed_parameter_values[i])",
                      xlabel = xlabel,
                      ylabel = ylabel)
            # no transposition of regrets_matrix
            hm = heatmap!(ax, αps, αns, regrets_matrix[:,:,d_indices[i]], colorrange = colorrange_map[row])
            Colorbar(f[row, cols + 1], hm, label = "Regret")
        end
    end
    f
end

# function create_regret_heatmap(regret_matrix, αs, βs)
#     f = Figure()
#     ax = Axis(f[1, 1],
#               title = "Q-Learning Regret Analysis",
#               xlabel = "Learning Rate (α)",
#               ylabel = "Inverse Temperature (β)")
#     hm = heatmap!(αs, βs, regret_matrix)
#     Colorbar(f[1, 2], hm, label = "Regret")
#     f
# end

# fig = create_regret_heatmap(regrets_matrix[:,:,9]', αps, αns)

"""
TODO: heatmap の色を複数プロットで揃えたい（比較のため）
TODO: それぞれの色を調整するために、最大値と最小値を取得する？
regret_matrix には、各 (α, β, trial) に対する regret の値の、3次元配列が入っている
αs, βs は実際のそれらパラメータの値の配列、
trials も実際の trials の値
"""
function create_regret_heatmaps_Q_trials(regrets_matrix::Array{Float64, 3},
                                         params_and_regrets::Vector{Vector{Float64}},
                                         αs::StepRangeLen{Float64}, βs::StepRangeLen{Float64},
                                         trials::Vector{Int})
    # dependent on the parameter to get fixed
    fixed_parameter = "trials"
    n_display = length(trials)
    x_parameter = "Learning Rate (α)"
    y_parameter = "Inv. Temp. (β)"
    display_dim = 3 # of which dimension in regrets_matrix the fixed parameter is
    # below independent of the parameter to get fixed
    f = Figure(size = (800, 600)) # or XGA
    size_display = size(regrets_matrix, display_dim) # variation of the fixed parameter
    n_display = (n_display >= size_display) ? size_display : n_display # number of display (<= size_display)
    d_indices = display_indices(n_display, size_display)
    # again the next line dependent on the parameter to get fixed
    params_fixed = [params_and_regrets[i][display_dim] for i in 1:length(params_and_regrets)]
    fixed_parameter_values = sort(collect(Set(params_fixed)))
    @ic(fixed_parameter_values)
    rows, cols = int_to_panel_dim(n_display)
    println("n_display: $(n_display), size_display: $(size_display), rows: $(rows), cols: $(cols)")
    for row in 1:rows, col in 1:cols
        i = cols*(row-1)+col
        if i > n_display
            break
        else
            ax = Axis(f[row, col],
                      title = "$(fixed_parameter) = $(Int(round(fixed_parameter_values[i])))",
                      xlabel = x_parameter,
                      ylabel = y_parameter)
            # no transposition of regrets_matrix
            hm = heatmap!(ax, αs, βs, regrets_matrix[:,:,d_indices[i]])
            Colorbar(f[row, cols + 1], hm, label = "Regret")
        end
    end
    f
end

"""
regret_matrix には、各 (αp, αn, β) に対する regret の値の、3次元配列が入っている
αps, αns は実際のそれらパラメータの値の配列、
βs_display は表示用の β の値 (= 0.1:0,1:0.9)
"""
# function create_regret_heatmaps(regret_matrix::Array{Float64, 3},
#                                 αps::StepRangeLen{Float64}, αns::StepRangeLen{Float64}, βs_display::StepRangeLen{Float64})
#     f = Figure(size = (800, 600)) # or XGA
#     for row in 1:3, col in 1:3
#         ax = Axis(f[row, col],
#                   title = "β = $(βs_display[3*(row-1)+col])",
#                   xlabel = "Learning Rate (α+)",
#                   ylabel = "Learning Rate (α-)")
#         # hm = heatmap!(ax, αps, αns, regret_matrix[:,:,βs_display[3*(row-1)+col]]')
#         hm = heatmap!(ax, αps, αns, regret_matrix[:,:,3*(row-1)+col]')
#         # hm = heatmap!(ax, αps, αns, regret_matrix[:,:,3*(row-1)+col])
#         Colorbar(f[row, 4], hm, label = "Regret")
#     end
#     f
# end


# function create_regret_heatmaps_Q_trials(regrets_matrix::Array{Float64, 3},
#                                 params_and_regrets::Vector{Vector{Float64}},
#                                 αs::StepRangeLen{Float64}, βs::StepRangeLen{Float64}, trials::Vector{Int})
#     # dependent on the parameter to get fixed
#     fixed_parameter = "trials"
#     n_display = βs_display
#     x_parameter = "Learning Rate (α)"
#     y_parameter = "Inv. Temp. (β)"
#     display_dim = 3
#     # below independent of the parameter to get fixed
#     f = Figure(size = (800, 600)) # or XGA
#     size_display = size(regrets_matrix, display_dim)
#     n_display = (n_display >= size_display) ? size_display : n_display
#     d_indices = display_indices(n_display, size_display)
#     # again the next line dependent on the parameter to get fixed
#     fixed_parameter_values = [params_and_regrets[i][3] for i in d_indices]
#     println("fixed_parameter_values: ", fixed_parameter_values)
#     rows, cols = int_to_panel_dim(n_display)
#     println("n_display: $(n_display), size_display: $(size_display), rows: $(rows), cols: $(cols)")
#     for row in 1:rows, col in 1:cols
#         i = cols*(row-1)+col
#         if i > n_display
#             break
#         else
#             ax = Axis(f[row, col],
#                       title = "$(fixed_parameter) = $(fixed_parameter_values[cols*(row-1)+col])",
#                       xlabel = x_parameter,
#                       ylabel = y_parameter)
#             # no transposition of regrets_matrix
#             hm = heatmap!(ax, αps, αns, regrets_matrix[:,:,d_indices[i]])
#             Colorbar(f[row, cols + 1], hm, label = "Regret")
#         end
#     end
#     f
# end
