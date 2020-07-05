module TestCount

using Test
using LazyGroupBy

@testset begin
    @test count.(_ -> true, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])) ==
          Dict(false => 3, true => 7)
    @test count.(grouped(identity, [true, false, true, true, true])) ==
          Dict(false => 0, true => 4)
    @test_throws(
        Exception,
        count.(_ -> 0.5, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])),
    )
end

end  # module
