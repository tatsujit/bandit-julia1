# import Pkg; Pkg.add("CairoMakie")
using CairoMakie

"""
TODO: heatmap の色を複数プロットで揃えたい（比較のため）
TODO: それぞれの色を調整するために、最大値と最小値を取得する？
"""
function create_regret_heatmap(regret_matrix, αs, βs)
    f = Figure()
    ax = Axis(f[1, 1],
              title = "Q-Learning Regret Analysis",
              xlabel = "Learning Rate (α)",
              ylabel = "Inverse Temperature (β)")
    hm = heatmap!(αs, βs, regret_matrix)
    Colorbar(f[1, 2], hm, label = "Regret")
    f
end

# fig = create_regret_heatmap(regrets_matrix[:,:,9]', αps, αns)

"""
regret_matrix には、各 (αp, αn, β) に対する regret の値の、3次元配列が入っている
αps, αns は実際のそれらパラメータの値の配列、
βs_display は表示用の β の値 (= 0.1:0,1:0.9)
"""
function create_regret_heatmaps(regret_matrix::Array{Float64, 3},
                                αps::StepRangeLen{Float64}, αns::StepRangeLen{Float64}, βs_display::StepRangeLen{Float64})
    f = Figure(size = (800, 600)) # or XGA
    for row in 1:3, col in 1:3
        ax = Axis(f[row, col],
                  title = "β = $(βs_display[3*(row-1)+col])",
                  xlabel = "Learning Rate (α+)",
                  ylabel = "Learning Rate (α-)")
        # hm = heatmap!(ax, αps, αns, regret_matrix[:,:,βs_display[3*(row-1)+col]]')
        hm = heatmap!(ax, αps, αns, regret_matrix[:,:,3*(row-1)+col]')
        # hm = heatmap!(ax, αps, αns, regret_matrix[:,:,3*(row-1)+col])
        Colorbar(f[row, 4], hm, label = "Regret")
    end
    f
end

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
    round.(((1:n_display) ./ n_display) .* size_display)
end

function create_regret_heatmaps(regrets_matrix::Array{Float64, 3},
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
    # again the next line dependent on the parameter to get fixed
    fixed_parameter_values = [params_and_regrets[i][3] for i in d_indices]
    println("fixed_parameter_values: ", fixed_parameter_values)
    rows, cols = int_to_panel_dim(n_display)
    println("n_display: $(n_display), size_display: $(size_display), rows: $(rows), cols: $(cols)")
    for row in 1:rows, col in 1:cols
        i = cols*(row-1)+col
        if i > n_display
            break
        else
            ax = Axis(f[row, col],
                      title = "$(fixed_parameter) = $(fixed_parameter_values[cols*(row-1)+col])",
                      xlabel = x_parameter,
                      ylabel = y_parameter)
            # hm = heatmap!(ax, αps, αns, regrets_matrix[:,:,d_indices[i]])
            hm = heatmap!(ax, αps, αns, regrets_matrix[:,:,d_indices[i]]')
            Colorbar(f[row, cols + 1], hm, label = "Regret")
        end
    end
    f
end

# f = Figure()
# ax = Axis(f[1, 1])

# centers_x = 1:5
# centers_y = 6:10
# data = reshape(1:25, 5, 5)

# heatmap!(ax, centers_x, centers_y, data)

# scatter!(ax, [(x, y) for x in centers_x for y in centers_y], color=:white, strokecolor=:black, strokewidth=1)

# f
