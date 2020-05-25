module TestFind

using Test
using LazyGroupBy

@testset begin
    @test findall.(<(5), grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])) ==
          Dict(false => [1, 7, 9], true => [3, 4, 8])
    @test findfirst.(<(5), grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])) ==
          Dict(false => 1, true => 3)
    @test findlast.(<(5), grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])) ==
          Dict(false => 9, true => 8)
end

end  # module
