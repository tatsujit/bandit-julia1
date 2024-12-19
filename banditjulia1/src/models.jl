module Models
using Random

export toString, update!,
    AbstractActionValueEstimator,
    SampleAverageEstimator,
    QEstimator,
    DLREstimator,
    ThompsonSamplingEstimator
include("./estimators/actionValueEstimator.jl")

export toString, select_action,
    AbstractPolicy,
    EpsilonGreedyPolicy,
    SoftmaxPolicy,
    UCBPolicy,
    UCBTunedPolicy,
    SatisficingPolicy,
    ThompsonSamplingPolicy
include("./policies/policy.jl")

end # end of Model