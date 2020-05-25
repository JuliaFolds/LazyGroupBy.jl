module TestWithCollect

using Test
using LazyGroupBy

dataset = [
    "map(identity, _)" => g -> map.(identity, g),
    "map(iseven, _)" => g -> map.(iseven, g),
    "sum(_)" => g -> sum.(g),
    "sum(x -> 2x, _)" => g -> sum.(x -> 2x, g),
    "prod(_)" => g -> prod.(g),
    "prod(x -> 2 + x, _)" => g -> prod.(x -> 2 + x, g),
    "length(_)" => g -> length.(g),
    "any(isodd, _)" => g -> any.(isodd, g),
    "all(isodd, _)" => g -> all.(isodd, g),
    "minimum(_)" => g -> minimum.(g),
    "minimum(x -> 2x, _)" => g -> minimum.(x -> 2x, g),
    "maximum(_)" => g -> maximum.(g),
    "maximum(x -> 2x, _)" => g -> maximum.(x -> 2x, g),
    "extrema(_)" => g -> extrema.(g),
    "extrema(x -> 2x, _)" => g -> extrema.(x -> 2x, g),
]

@testset "$label" for (label, reducer) in dataset
    g = grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])
    d = collect.(g)
    @test reducer(g) == Dict(zip(keys(d), reducer(values(d))))
end

end  # module
