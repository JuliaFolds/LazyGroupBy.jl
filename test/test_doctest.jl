module TestDoctest

import LazyGroupBy
using Documenter: doctest
using Test

@testset "doctest" begin
    if lowercase(get(ENV, "JULIA_PKGEVAL", "false")) == "true"
        @info "Skipping doctests on PkgEval."
    else
        doctest(LazyGroupBy)
    end
end

end  # module
