module TestPairs

using Test
using LazyGroupBy

@testset begin
    @test pairs.(grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])) == Dict(
        false => Dict(7 => 4, 9 => 0, 1 => 0),
        true => Dict(4 => 1, 10 => 5, 2 => 7, 3 => 3, 5 => 5, 8 => 3, 6 => 9),
    )
end

end  # module
