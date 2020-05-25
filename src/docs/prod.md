    prod.([f,] grouped(key, collection); [prod])

# Examples

```julia
julia> using LazyGroupBy

julia> prod.(grouped(isodd, [7, 3, 1, 5, 9, 4, 3, 5]))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 4
  true  => 14175
```
