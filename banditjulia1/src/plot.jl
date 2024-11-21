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
        Colorbar(f[row, 4], hm, label = "Regret")
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
