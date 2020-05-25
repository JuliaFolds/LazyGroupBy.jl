    all.(f, grouped(key, array))

# Examples

```julia
julia> using LazyGroupBy

julia> xs = [0, 7, 3];

julia> gs = all.(<(1), grouped(isodd, xs))
Transducers.GroupByViewDict{Bool,Bool,…} with 2 entries:
  false => true
  true  => false
```
