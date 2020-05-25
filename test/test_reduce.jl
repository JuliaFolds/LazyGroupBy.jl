module TestReduce

using Test
using LazyGroupBy

extrema_rf((min1, max1), (min2, max2)) = (min(min1, min2), max(max1, max2))

@testset "extrema" begin
    @test mapreduce.(
        x -> (x, x),
        extrema_rf,
        grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]),
    ) == Dict(false => (0, 4), true => (1, 9))
end

end  # module
