    tcollect.([xf,] grouped(key, collection))

Collect each group as a `Vector` using multiple threads.
See also [`collect.(grouped(key, collection))`](@ref collect).

The first optional argument `xf` is a transducer.

# Example

```julia
julia> using LazyGroupBy
       using Transducers

julia> tcollect.(grouped(isodd, [0, 7, 3]))
Transducers.GroupByViewDict{Bool,Array{Int64,1},…} with 2 entries:
  false => [0]
  true  => [7, 3]
```
