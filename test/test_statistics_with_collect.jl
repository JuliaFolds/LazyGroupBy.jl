module TestStatisticsWithCollect

using LazyGroupBy
using Statistics
using Test
using Transducers: MapCat

≅(a, b) = isequal(a, b) || a ≈ b

dataset = [
    "mean(_)" => g -> mean.(g),
    "mean(x -> 2x, _)" => g -> mean.(x -> 2x, g),
    "var(_)" => g -> var.(g),
    "std(_)" => g -> std.(g),
]

@testset "$label" for (label, reducer) in dataset
    xs0 = [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]
    @testset for idx in [1:1, 1:2, :]
        xs = xs0[idx]
        g = grouped(isodd, xs)
        d = collect.(g)
        actual = sort!(collect(reducer(g)); by = first)
        desired = sort!(collect(zip(keys(d), reducer(values(d)))); by = first)
        @test first.(actual) == first.(desired)
        @test last.(actual) ≅ last.(desired)
    end
end

dataset_with_mapping = [
    "var(x -> 2x, _)" => (g -> var.(x -> 2x, g), g -> var(2 .* g)),
    "std(x -> 2x, _)" => (g -> std.(x -> 2x, g), g -> std(2 .* g)),
    "mean(MapCat(x -> -1:x), _)" =>
        (g -> mean.(MapCat(x -> -1:x), g), g -> mean(y for x in g for y in -1:x)),
]

@testset "$label" for (label, (reducer, mapped)) in dataset_with_mapping
    xs0 = [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]
    @testset for idx in [1:1, 1:2, :]
        xs = xs0[idx]
        g = grouped(isodd, xs)
        d = collect.(g)
        actual = sort!(collect(reducer(g)); by = first)
        desired = sort!(collect(zip(keys(d), mapped.(values(d)))); by = first)
        @test first.(actual) == first.(desired)
        @test last.(actual) ≅ last.(desired)
    end
end

end  # module
