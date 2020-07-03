module TestDoctest

import LazyGroupBy
using Documenter: doctest
using Test

@testset "doctest" begin
    doctest(LazyGroupBy)
end

end  # module
