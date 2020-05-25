module TestView

using Test
using LazyGroupBy

@testset begin
    @test view.(grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5])) ==
          Dict(false => [0, 4, 0], true => [7, 3, 1, 5, 9, 3, 5])
end

@testset "mutation" begin
    xs = [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]
    gs = view.(grouped(isodd, xs))
    @test gs == Dict(false => [0, 4, 0], true => [7, 3, 1, 5, 9, 3, 5])
    gs[false][1] = 10
    @test xs == [10, 7, 3, 1, 5, 9, 4, 3, 0, 5]
    gs[false][2:end] .= 20
    @test xs == [10, 7, 3, 1, 5, 9, 20, 3, 20, 5]
    gs[true] .= 30
    @test xs == [10, 30, 30, 30, 30, 30, 20, 30, 20, 30]
end

end  # module
