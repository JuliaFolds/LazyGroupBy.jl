    minimum.([f,] grouped(key, collection); [init])

# Examples

```julia
julia> using LazyGroupBy

julia> minimum.(grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 0
  true  => 1
```
