    count.([f,] grouped(key, collection))

Count number of items `f` is evaluated to `true` in each group.

# Example

```julia
julia> using LazyGroupBy

julia> count.(<(5), grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 3
  true  => 3
```
