"""
julia> versioninfo()
Julia Version 1.11.1
Commit 8f5b7ca12ad (2024-10-16 10:53 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: macOS (arm64-apple-darwin22.4.0)
  CPU: 11 × Apple M3 Pro
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, apple-m3)
Threads: 1 default, 0 interactive, 1 GC (on 5 virtual cores)
Environment:
  DYLD_LIBRARY_PATH = /System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/::/usr/lib:/usr/local/lib


# 問題は20204080:
n_αs = n_βs = 201
sim = 500  # simulations for each parameter value
trials = 1000
n_arms = 4

sims: 20200500, length(regrets): 40401
9840.366908 seconds (406.12 G allocations: 15.106 TiB, 8.15% gc time, 0.01% compilation time)


n_αs = n_βs = 201
sim = 100  # simulations for each parameter value
trials = 150
n_arms = 4
sims: 4040100, length(regrets): 40401
320.780613 seconds (12.50 G allocations: 478.946 GiB, 10.91% gc time, 0.11% compilation time)

## 1/30 くらいだから、5-6分、という予想そのまま

# 問題は70708090:
sims: 4040100, length(regrets): 40401
313.449861 seconds (12.50 G allocations: 478.952 GiB, 11.06% gc time, 0.12% compilation time)

ちょっとメモリをけちった
- HistoryRich でなく History
- evaluation ではなく regret_final

sims: 4040100, length(regrets): 40401
285.719026 seconds (10.06 G allocations: 365.692 GiB, 9.87% gc time, 0.13% compilation time)

sims: 4040100, length(regrets): 40401
261.945723 seconds (9.87 G allocations: 331.792 GiB, 9.24% gc time, 0.08% compilation time)


trials = 600 で「難しい問題」2つだと：
1024.513760 seconds (38.98 G allocations: 1.277 TiB, 8.00% gc time, 0.02% compilation time)
919.335574 seconds (39.01 G allocations: 1.279 TiB, 7.69% gc time, 0.60% compilation time: 29% of which was recompilation)

History を一個使いまわして上書きしたら：

sims: 4040100, length(regrets): 40401
863.581727 seconds (38.96 G allocations: 1.224 TiB, 8.71% gc time, 0.55% compilation time: 54% of which was recompilation)
"""



"""
[[https://x.com/genkuroki/status/949233447620390912][黒木玄 Gen Kuroki on X: "#JuliaLang Jupyter notebookでjuliaを julia -p auto で起動するようにしておくと並列処理もできます。以下のリンク先の第1.10節に解説がある。 https://t.co/TNQilz0f3a 並列処理のマクロを使うと @ parallel (+) for i in 1:N rand() end で乱数の和を計算してくれます。@ の後の空白は除く。" / X]]

* 重い計算のコードは必ず函数の中に書く。
* 大域変数を含む函数を書かない。(const や functor-like object を使う。)
* xの型が確定したらf(x)のコード中の諸々の型が確定するように書く。
* forループは速い。
* dot syntaxを使用する。
* @ view a[:,j] を使用する。

* a=[]をa=Float64[]に→5倍高速化
* 固定長配列に変更→2倍以上高速化
"""

# with 101 * 101 = 10,201 simulations with 10,000 trials each
# @time include("q-heatmap.jl")
# =>
# 162.927652 seconds (2.06 G allocations: 78.584 GiB, 63.83% gc time, 0.33% compilation time)
include("settings.jl")
# import Pkg; Pkg.add("CairoMakie")
using FLoops
using CairoMakie

verbose = false
n_αs = n_βs = 11 # 10 ないとエラーが出る！
sim = 1000  # simulations for each parameter value
trials = 1000
n_arms = 4
# ps = [0.2, 0.2, 0.4, 0.8]
# ps = [0.7, 0.7, 0.8, 0.9]
ps = [0.8, 0.8, 0.8, 0.9]
distributions::AbstractVector{Distribution{Univariate}} = [Bernoulli(p) for p in ps] # for all simulations
αs = range(0.0, 1.0, length=n_αs)
βs = range(0.0, 10.0, length=n_βs)
parameters = [[α, β] for α in αs for β in βs]
# parameters = collect(Iterators.product(αs, βs))
sims = sim * length(parameters) # total simulations

prob_str = join(string.(Int.(100 .* ps)))
filename_suffix = "$(sim)sims-$(trials)trials-$(n_arms)-arms-$(prob_str)-Q-SM-α-β-$(n_αs)x$(n_βs)param-vs"

rseeds = [1234 * i for i in 1:sims]
params_and_regrets = Vector{Vector{Float64}}()
# sizehint!(params_and_regrets, sim * length(parameters))
regrets = Vector{Float64}()
# sizehint!(regrets, length(parameters))


# TODO 記録用のファイル名を作成する
# simulation_name = toString(n_αs) * "x" * toString(n_βs) * "x" * toString(sim)


"""
TODO s!
DONE 1: param の数は可変で、3とか4とかも普通にあるから、array か tuple にするかな？
TODO 1.1:    しかし他方で、多重ディスパッチにするなら型で分けるのがいい
TODO 3: 並列化するなら、最後に sort する必要がある
DONE - 4: popfirst! を sim * params の配列に対して行うよりは、 i = 1 として i += 1 していくのがよかろう
TODO 5: パラメータなどとともに、かかった時間とメモリの大体も(画像、データ)ファイルに入れておきたいな
つまり、以下の勉強が必要：
TODO 1. 並列化の意味のある簡単なやり方
DONE 2. @time の使い方、結果の読み方
TODO 3. Julia でのメモリ節約の仕方（必要なら）、GCなど
"""
function regret_for_Q_α_β(parameters::Vector{Vector{Float64}}, sim::Int64, trials::Int64, n_arms::Int64, distributions::AbstractVector{Distribution{Univariate}}, rseeds::Vector{Int64})::Tuple{Vector{Float64}, Vector{Vector{Float64}}}
    n_params = length(parameters)
    # regrets = zeros(Float64, n_params)
    params_and_regrets = Vector{Vector{Float64}}() # [[α, β, regret], ...]]
    sizehint!(params_and_regrets, n_params)
    env = Environment(n_arms, distributions) # the same for all simulations
    @floop for (j, param) in enumerate(parameters)
    # for (j, param) in enumerate(parameters)
        α, β = param
        final_regrets = zeros(Float64, sim)
        # rng = Xoshiro(rseeds[(j-1)*sim+i])
        rng = Xoshiro(rseeds[(j-1)*sim+1]) # unneceesary to change the seed for each simulation, as a parallel thread has multiple simulations here
        for i in 1:sim
            agent = Agent(QEstimator(α, n_arms), SoftmaxPolicy(β))
            his = History(trials, n_arms) # each simulation needs to have a history when parallelized
            # his = HistoryRich(trials)
            sys = System(agent, env, his, rng)
            run!(sys, trials)
            # evaluation = evaluate(sys)
            # final_regrets[i] = evaluation.regret[end]
            final_regrets[i] = regret_final(sys)
            if verbose
                println("α: $(sys.agent.estimator.α), β: $(sys.agent.policy.β), regret: $(final_regret)")
            end
        end
        # TODO progress bar, as in Wada's social bandit program
        if j % (n_params ÷ 100) == 0
            println("$(j) / $(n_params) done")
        end
        mean_final_regret = mean(final_regrets)
        # regrets[j] = mean_final_regret
        params_and_regrets = push!(params_and_regrets, [α, β, mean_final_regret])
    end
    # sort the results according to alpha and beta values
    params_and_regrets_sorted = sort(params_and_regrets, by = x -> (x[1], x[2]))
    regrets = [x[3] for x in params_and_regrets_sorted]
    return regrets, params_and_regrets_sorted # transposed
    # return params_and_regrets
end

regrets, params_and_regrets = regret_for_Q_α_β(parameters, sim, trials, n_arms, distributions, rseeds)
# params_and_regrets = regret_for_Q_α_β(parameters, sim, trials, n_arms, distributions, rseeds)
#
println("params_and_regrets: ")
println(params_and_regrets)
println("regrets: ")
println(regrets)

println("sims: $(sims), length(regrets): $(length(regrets))")

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

regrets_matrix = reshape(regrets, n_αs, n_βs)
fig = create_regret_heatmap(regrets_matrix', αs, βs)
save("regret-heatmap-" * filename_suffix * ".pdf", fig)
fig

# save regrets_matrix' to a file
using JLD2
save("regrets_matrix" * filename_suffix *  ".jld2", "regrets_matrix", regrets_matrix)
