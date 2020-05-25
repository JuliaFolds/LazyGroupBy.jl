    var.([f,] grouped(key, collection))

Compute variance of each group.

# Example

```julia
julia> using LazyGroupBy, Statistics

julia> var.(grouped(isodd, 1:10))
Dict{Bool,Float64} with 2 entries:
  false => 10.0
  true  => 10.0
```
