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
using CairoMakie

verbose = false
n_αs = n_βs = 101
sim = 1000  # simulations for each parameter value
trials = 100
n_arms = 4
ps = [0.2, 0.2, 0.4, 0.8]
distributions = [Bernoulli(p) for p in ps] # for all simulations
αs = range(0.0, 1.0, length=n_αs)
βs = range(0.0, 10.0, length=n_βs)
parameters = Iterators.product(αs, βs) # collect if we want an array
sims = sim * length(parameters) # total simulations

rseeds = [1234 * i for i in 1:sims]
params_and_regrets = Vector{Vector{Float64}}()
# sizehint!(params_and_regrets, sim * length(parameters))
regrets = Vector{Float64}()
# sizehint!(regrets, length(parameters))

# 記録様のファイル名を作成する
simulation_name = toString(n_αs) * "x" * toString(n_βs) * "x" * toString(sim)

"""
TODO 1: param の数は可変で、3とか4とかも普通にあるから、array か tuple にするかな？
　　　　しかし他方で、多重ディスパッチにするなら型で分けるのがいい
TODO 2: sizehint!はなるべくやっておこう
TODO 3: 並列化するなら、最後に sort する必要がある
TODO 4: popfirst! を sim * params の配列に対して行うよりは、 i = 1 として i += 1 していくのがよかろう
TODO 5: パラメータなどとともに、かかった時間とメモリの大体も(画像、データ)ファイルに入れておきたいな
つまり、以下の勉強が必要：
1. 並列化の意味のある簡単なやり方
2. @time の使い方、結果の読み方
3. Julia でのメモリ節約の仕方（必要なら）、GCなど
"""
function regret_for_Q_α_β(αs, βs, sim, trials, n_arms, distributions, rseeds)
    regrets = Vector{Float64}()
    for α in αs
        for β in βs
            final_regrets = Float64[]
            for i in 1:sim
                agent = Agent(QEstimator(α, n_arms), SoftmaxPolicy(β))
                env = Environment(n_arms, distributions) # for all simulations
                his = HistoryRich(trials)
                rng = Xoshiro(popfirst!(rseeds)) # consume each first rseed
                sys = System(agent, env, his, rng)
                run!(sys, trials)
                evaluation = evaluate(sys)
                final_regret = evaluation.regret[end]
                if verbose
                    println("α: $(sys.agent.estimator.α), β: $(sys.agent.policy.β), regret: $(final_regret)")
                end
                push!(final_regrets, final_regret)
            end
            mean_final_regret = mean(final_regrets)
            push!(regrets, mean_final_regret)
        end
    end
    regrets
end

# 並列化するならあとで結果をsortする必要がある
for param in parameters
    final_regrets = Float64[]
    for i in 1:sim
        α, β = param
        agent = Agent(QEstimator(α, n_arms), SoftmaxPolicy(β))
        env = Environment(n_arms, distributions) # for all simulations
        his = HistoryRich(trials)
        rng = Xoshiro(popfirst!(rseeds)) # consume each first rseed
        sys = System(agent, env, his, rng)
        run!(sys, trials)
        evaluation = evaluate(sys)
        final_regret = evaluation.regret[end]
        if verbose
            println("α: $(sys.agent.estimator.α), β: $(sys.agent.policy.β), regret: $(final_regret)")
        end
        push!(final_regrets, final_regret)
    end
    mean_final_regret = mean(final_regrets)
    push!(params_and_regrets, [param[1], param[2], mean_final_regret])
    push!(regrets, mean_final_regret)
end

# println(params_and_regrets)
println(regrets)

println("sims: $(sims), length(regrets): $(length(regrets))")

using CairoMakie

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

# Example usage (uncomment and modify with your actual regret matrix):
# regret_matrix = rand(101, 101)  # Replace with your actual regret matrix
# αs = range(0.0, 1.0, length=101)
# βs = range(0.0, 10.0, length=101)
regrets_matrix = reshape(regrets, n_αs, n_βs)
fig = create_regret_heatmap(regrets_matrix, αs, βs)
save("qlearning_regret.png", fig)
fig


