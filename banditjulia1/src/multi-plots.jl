using CairoMakie

fig = Figure(size = (1000, 700))

for i in 1:3, j in 1:3
    x = 10.0.^(1:0.1:(i*j))
    y = 1.0:0.1:5.0
    z = broadcast((x, y) -> x - 10, x, y')
    scale = ReversibleScale(x -> asinh(x / 2) / log(10), x -> 2sinh(log(10) * x))

    g = fig[i, j] = GridLayout()
    axmain = Axis(g[1, 1], title = string((i, j)))
    axbar = g[1, 2]
    hm = heatmap!(axmain, x, y, z; colorscale = scale)
    Colorbar(axbar, hm)
end

fig
