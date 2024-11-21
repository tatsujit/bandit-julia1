using FLoops
using ProgressBars

"""
DONE 1: param の数は可変で、3とか4とかも普通にあるから、array か tuple にするかな？
TODO 1.1:    しかし他方で、多重ディスパッチにするなら型で分けるのがいい
DONE 3: 並列化するなら、最後に sort する必要がある
DONE - 4: popfirst! を sim * params の配列に対して行うよりは、 i = 1 として i += 1 していくのがよかろう
TODO 5: パラメータなどとともに、かかった時間とメモリの大体も(画像、データ)ファイルに入れておきたいな
     using BenchmarkTools で @btime
つまり、以下の勉強が必要：
DONE 1. 並列化の意味のある簡単なやり方
DONE 2. @time の使い方、結果の読み方
DONE 3. Julia でのメモリ節約の仕方（必要なら）、GCなど
"""

function regret_for_Q_α_β(parameters::Vector{Vector{Float64}}, sim::Int64, trials::Int64, n_arms::Int64,
                          distributions::AbstractVector{Distribution{Univariate}}, rseeds::Vector{Int64}
                          )::Tuple{Vector{Float64}, Vector{Vector{Float64}}}
    n_params = length(parameters)
    params_and_regrets = Vector{Vector{Float64}}() # [[α, β, regret], ...]]
    sizehint!(params_and_regrets, n_params)
    env = Environment(n_arms, distributions) # the same for all simulations
    # @floop for (j, param) in enumerate(parameters)
    @floop for (j, param) in ProgressBar(enumerate(parameters))
    # for (j, param) in enumerate(parameters)
        println("j: $(j), param: $(param)")
        α, β = param
        final_regrets = zeros(Float64, sim)
        # rng = Xoshiro(rseeds[(j-1)*sim+i])
        rng = Xoshiro(rseeds[(j-1)*sim+1]) # a single RNG for each thread
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
        # if n_params < 100
        #     println("$(j) / $(n_params) done")
        # elseif j % (n_params ÷ 100) == 0
        #     println("$(j) / $(n_params) done")
        # end
        mean_final_regret = mean(final_regrets)
        # regrets[j] = mean_final_regret
        push!(params_and_regrets, [α, β, mean_final_regret])
    end
    # sort the results according to alpha and beta values
    params_and_regrets_sorted = sort(params_and_regrets, by = x -> (x[1], x[2]))
    regrets = [x[3] for x in params_and_regrets_sorted]
    return (regrets, params_and_regrets_sorted)
end

function regret_for_DLR_αp_αn_β(parameters::Vector{Vector{Float64}}, sim::Int64, trials::Int64, n_arms::Int64,
                          distributions::AbstractVector{Distribution{Univariate}}, rseeds::Vector{Int64}
                          )::Tuple{Vector{Float64}, Vector{Vector{Float64}}}
    n_params = length(parameters)
    # params_and_regrets = zeros(Float64, n_params, 4) # [[αp, αn, β, regret], ...]]
    params_and_regrets = Vector{Vector{Float64}}() # [[αp, αn, β, regret], ...]]
    sizehint!(params_and_regrets, n_params)
    env = Environment(n_arms, distributions) # the same for all simulations
    # @floop for (j, param) in enumerate(parameters)
    # @floop for (j, param) in ProgressBar(enumerate(parameters))
    for (j, param) in ProgressBar(enumerate(parameters))
    # for (j, param) in enumerate(parameters)
        # println("j: $(j), param: $(param)")
        αp, αn, β = param
        final_regrets = zeros(Float64, sim)
        # rng = Xoshiro(rseeds[(j-1)*sim+i])
        rng = Xoshiro(rseeds[(j-1)*sim+1]) # a single RNG for each thread
        for i in 1:sim
            agent = Agent(DLREstimator(αp, αn, n_arms), SoftmaxPolicy(β))
            his = History(trials, n_arms) # each simulation needs to have a history when parallelized
            # his = HistoryRich(trials)
            sys = System(agent, env, his, rng)
            run!(sys, trials)
            # evaluation = evaluate(sys)
            # final_regrets[i] = evaluation.regret[end]
            final_regrets[i] = regret_final(sys)
            if verbose
                println("αp: $(sys.agent.estimator.αp), αn: $(sys.agent.estimator.αn), β: $(sys.agent.policy.β), regret: $(final_regret)")
            end
        end
        mean_final_regret = mean(final_regrets)
        # regrets[j] = mean_final_regret
        push!(params_and_regrets, [αp, αn, β, mean_final_regret])
        # params_and_regrets[], [αp, αn, β, mean_final_regret])
    end
    # sort the results according to αp, αn, and β values
    params_and_regrets_sorted = sort(params_and_regrets, by = x -> (x[1], x[2], x[3]))
    regrets = [x[4] for x in params_and_regrets_sorted]
    return (regrets, params_and_regrets_sorted)
end
