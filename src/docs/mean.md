    mean.([f,] grouped(key, collection))

Compute `mean` of each group.

# Example

```julia
julia> using LazyGroupBy, Statistics

julia> mean.(grouped(isodd, 1:7))
Dict{Bool,Float64} with 2 entries:
  false => 4.0
  true  => 4.0
```
