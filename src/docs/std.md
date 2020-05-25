    std.([f,] grouped(key, collection))

Compute standard deviation of each group.

# Example

```julia
julia> using LazyGroupBy, Statistics

julia> std.(grouped(isodd, 1:10))
Dict{Bool,Float64} with 2 entries:
  false => 3.16228
  true  => 3.16228
```
