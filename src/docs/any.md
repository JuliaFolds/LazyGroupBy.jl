    any.(f, grouped(key, array))

# Examples

```julia
julia> using LazyGroupBy

julia> xs = [0, 7, 3];

julia> gs = any.(>(5), grouped(isodd, xs))
Transducers.GroupByViewDict{Bool,Bool,…} with 2 entries:
  false => false
  true  => true
```
