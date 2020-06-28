    reduce.(op, [xf,] grouped(key, collection); [init])
    reduce.(os::OnlineStat, [xf,] grouped(key, collection); [init])

The first argument is either a reducing step function or an
`OnlineStat`.  The second optional argument `xf` is a transducer.

# Examples

```julia
julia> using LazyGroupBy

julia> reduce.(max, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 4
  true  => 9

julia> using OnlineStats

julia> reduce.(Ref(Mean()), grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Mean{Float64,EqualWeight},…} with 2 entries:
  false => Mean: n=3 | value=1.33333
  true  => Mean: n=7 | value=4.71429
```
