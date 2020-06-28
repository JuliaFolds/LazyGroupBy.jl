    foldl.(op, [xf,] grouped(key, collection); [init])
    foldl.(os::OnlineStat, [xf,] grouped(key, collection); [init])

The first argument is either a reducing step function or an
`OnlineStat`.  The second optional argument `xf` is a transducer.

# Examples

```julia
julia> using LazyGroupBy

julia> foldl.(tuple, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Any,…} with 2 entries:
  false => ((0, 4), 0)
  true  => ((((((7, 3), 1), 5), 9), 3), 5)

julia> using OnlineStats

julia> foldl.(Ref(Mean()), grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Mean{Float64,EqualWeight},…} with 2 entries:
  false => Mean: n=3 | value=1.33333
  true  => Mean: n=7 | value=4.71429
```
