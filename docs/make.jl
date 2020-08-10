using Documenter
using LazyGroupBy

makedocs(
    # https://juliadocs.github.io/Documenter.jl/stable/lib/public/#Documenter.makedocs
    sitename = "LazyGroupBy",
    format = Documenter.HTML(),
    pages = ["Home" => "index.md", hide("internals.md")],
    modules = [LazyGroupBy],
    doctest = false,
)

deploydocs(
    # https://juliadocs.github.io/Documenter.jl/stable/lib/public/#Documenter.deploydocs
    repo = "github.com/JuliaFolds/LazyGroupBy.jl",
    push_preview = true,
)
