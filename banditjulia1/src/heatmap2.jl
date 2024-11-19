using CairoMakie, Random

function generate_sample_data(n=101)
    Random.seed!(42)
    x = range(-3, 3, n)
    y = range(-3, 3, n)
    base = [sin(x[i] * 2) * cos(y[j] * 2) for i in 1:n, j in 1:n]
    noise = 0.2 * randn(n, n)
    base .+ noise
end

function create_heatmap(data)
    fig = Figure(size=(800, 600))  # Changed from resolution to size

    ax = Axis(fig[1, 1],
              title="101x101 Matrix Heatmap",
              xlabel="X axis",
              ylabel="Y axis")

    hm = heatmap!(ax, data,
                  colormap=:viridis,
                  interpolate=true)

    Colorbar(fig[1, 2], hm,
             label="Value",
             width=15,
             ticklabelsize=12)

    colsize!(fig.layout, 1, Relative(0.85))
    fig
end

# Main execution
data = generate_sample_data()
fig = create_heatmap(data)
save("matrix_heatmap.png", fig)

fig
