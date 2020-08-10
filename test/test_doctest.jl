module TestDoctest

import LazyGroupBy
using Documenter: DocMeta, doctest
using Test

DocMeta.setdocmeta!(
    LazyGroupBy,
    :DocTestSetup,
    :(using LazyGroupBy: foldxl, foldxt, foldxd),
)

@testset "doctest" begin
    doctest(LazyGroupBy)
end

end  # module
