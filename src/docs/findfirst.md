    findfirst.(f, grouped(key, array))

# Examples

```julia
julia> using LazyGroupBy

julia> xs = [0, 7, 2, 3];

julia> gs = findfirst.(>(1), grouped(isodd, xs))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 3
  true  => 2

julia> xs[gs[false]]
2

julia> xs[gs[true]]
7
```
