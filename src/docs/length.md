    length.(grouped(key, collection))

Count number of items in each group.  This is defined as `count.(_ ->
true, grouped(key, collection))` rather than materializing each group
vector.

# Example

```julia
julia> using LazyGroupBy

julia> length.(grouped(isodd, 1:7))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 3
  true  => 4
```

