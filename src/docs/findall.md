    findall.(f, grouped(key, array))

# Examples

```julia
julia> using LazyGroupBy

julia> xs = [0, 7, 2, 3];

julia> gs = findall.(>(1), grouped(isodd, xs))
Transducers.GroupByViewDict{Bool,Array{Int64,1},…} with 2 entries:
  false => [3]
  true  => [2, 4]

julia> xs[gs[false]]
1-element Array{Int64,1}:
 2

julia> xs[gs[true]]
2-element Array{Int64,1}:
 7
 3
```
