import Pkg; Pkg.add("ProgressBars")
using ProgressBars

v = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

for (i, val) in ProgressBar(enumerate(v))
    println("i: $(i), val: $(val)")
end
