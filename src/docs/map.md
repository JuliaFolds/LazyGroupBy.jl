    map.(f, grouped(key, collection))

Like `collect.(grouped(key, collection))`, but process each item with
`f`.

# Examples

```julia
julia> using LazyGroupBy

julia> map.(string, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Array{String,1},…} with 2 entries:
  false => ["0", "4", "0"]
  true  => ["7", "3", "1", "5", "9", "3", "5"]
```
