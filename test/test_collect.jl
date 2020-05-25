module TestCollect

using Test
using LazyGroupBy

@testset begin
    @test collect.(grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])) ==
          Dict(false => [0, 4, 0], true => [7, 3, 1, 5, 9, 3, 5])
end

end  # module
