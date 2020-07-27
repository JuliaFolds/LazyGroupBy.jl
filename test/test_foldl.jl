module TestFoldl

using Test
using LazyGroupBy
using LazyGroupBy: foldxl

@testset "tuple" begin
    @testset for fold in [foldl, foldxl]
        foldl = nothing

        @test fold.(tuple, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])) ==
              Dict(false => ((0, 4), 0), true => ((((((7, 3), 1), 5), 9), 3), 5))

        @test fold.(tuple, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]); init = -1) ==
              Dict(
            false => (((-1, 0), 4), 0),
            true => (((((((-1, 7), 3), 1), 5), 9), 3), 5),
        )
    end
end

extrema_rf((min1, max1), (min2, max2)) = (min(min1, min2), max(max1, max2))

@testset "extrema" begin
    @test mapfoldl.(
        x -> (x, x),
        extrema_rf,
        grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]),
    ) == Dict(false => (0, 4), true => (1, 9))
end

end  # module
