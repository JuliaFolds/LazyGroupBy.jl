    extrema.([f,] grouped(key, collection); [init])

# Examples

```julia
julia> using LazyGroupBy

julia> xs = [0, 7, 2, 3];

julia> extrema.(grouped(isodd, xs))
Transducers.GroupByViewDict{Bool,Tuple{Int64,Int64},…} with 2 entries:
  false => (0, 2)
  true  => (3, 7)
```
