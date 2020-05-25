    mapreduce.(f, op, grouped(key, collection); [init])

Multi-threaded version of
[`mapreduce.(f, op, grouped(key, collection))`](@ref mapfoldl).

# Examples

```julia
julia> using LazyGroupBy

julia> extrema_rf((min1, max1), (min2, max2)) = (min(min1, min2), max(max1, max2));

julia> mapreduce.(x -> (x, x), extrema_rf, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Tuple{Int64,Int64},…} with 2 entries:
  false => (0, 4)
  true  => (1, 9)
```
