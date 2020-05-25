    keys.(grouped(key, indexable))

Return a dictionary whose value is a vector of keys to the `indexable`
input collection.

# Example

```julia
julia> using LazyGroupBy

julia> keys.(grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Array{Int64,1},…} with 2 entries:
  false => [1, 7, 9]
  true  => [2, 3, 4, 5, 6, 8, 10]

julia> keys.(grouped(isodd, Dict(zip('a':'e', 1:5))))
Transducers.GroupByViewDict{Bool,Array{Char,1},…} with 2 entries:
  false => ['d', 'b']
  true  => ['a', 'c', 'e']
```
