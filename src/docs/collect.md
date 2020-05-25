    collect.([xf,] grouped(key, collection))

Collect each group as a `Vector`.

The first optional argument `xf` is a transducer.

# Example

```julia
julia> using LazyGroupBy

julia> collect.(grouped(isodd, [0, 7, 3]))
Transducers.GroupByViewDict{Bool,Array{Int64,1},…} with 2 entries:
  false => [0]
  true  => [7, 3]
```
