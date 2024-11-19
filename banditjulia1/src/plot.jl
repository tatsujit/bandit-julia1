# import Pkg; Pkg.add("CairoMakie")
using CairoMakie
f = Figure()
ax = Axis(f[1, 1])

centers_x = 1:5
centers_y = 6:10
data = reshape(1:25, 5, 5)

heatmap!(ax, centers_x, centers_y, data)

scatter!(ax, [(x, y) for x in centers_x for y in centers_y], color=:white, strokecolor=:black, strokewidth=1)

f
