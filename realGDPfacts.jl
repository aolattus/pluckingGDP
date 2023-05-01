using DataFrames, CSV
using Plots
using Measures
using Dates
using LinearAlgebra

realGDP = CSV.read("data/GDPC1.csv", DataFrame)

realGDP.GDPC1 = realGDP.GDPC1 ./ 1000

function hodrick_prescott(y::Vector{YT},λ::ΛT) where {YT<:Real,ΛT<:Real}
    T = length(y)

    # second difference matrix follows from (Orfandis, 2018)
    Q = diagm(-1=>fill(1,T-1),0=>fill(-2,T),1=>fill(1,T-1))
    @inbounds Q = Q[:,2:(T-1)]

    trend = (I+λ*Q*Q')\y
    cycle = y .- trend
    # ridge regression from (Pollock, 2016)
    return trend, cycle
end

realGDP.trend, realGDP.cycle = hodrick_prescott(realGDP.GDPC1, 1600)

# Plotting the trend and cycle
plot(realGDP.DATE, realGDP.trend,
    title="Real GDP and Real GDP Trend",
    leftmargin=3mm,
    label="",
    linewidth=0.5,
    color=:blue,
    ls=:dash
)

plot!(realGDP.DATE, realGDP.GDPC1,
    linewidth=0.5,
    color=:blue
)


plot(realGDP.DATE, realGDP.cycle,
    leftmargin=3mm,
    label="",
    linewidth=1,
    color=:blue
)