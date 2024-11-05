# [[https://juliastats.org/Distributions.jl/v0.14/starting.html][Getting Started · Distributions.jl]]
using Distributions
d1 = Normal(1, 2)
typeof(d1)

ds1 = [Normal(i^2, 2) for i in 2:5]
typeof(ds1)

rs = [rand(d, 5) for d in ds1]
