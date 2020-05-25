    dreduce.(op, [xf,] grouped(key, collection); [init])
    dreduce.(os::OnlineStat, [xf,] grouped(key, collection); [init])

The first argument is either a reducing step function or an
`OnlineStat`.  The second optional argument `xf` is a transducer.

# Examples

```julia
julia> using LazyGroupBy
       using Transducers

julia> dreduce.(+, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 4
  true  => 33
```
