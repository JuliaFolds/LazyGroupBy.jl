module TestKeys

using Test
using LazyGroupBy

@testset begin
    @test keys.(grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])) ==
          Dict(false => [1, 7, 9], true => [2, 3, 4, 5, 6, 8, 10])
end

end  # module
