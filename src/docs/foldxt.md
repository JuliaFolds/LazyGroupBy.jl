    foldxt.(op, [xf,] grouped(key, collection); [init])
    foldxt.(os::OnlineStat, [xf,] grouped(key, collection); [init])

The first argument is either a reducing step function or an
`OnlineStat`.  The second optional argument `xf` is a transducer.

# Examples

```julia
julia> using LazyGroupBy, Transducers

julia> foldxt.(max, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 4
  true  => 9

julia> using OnlineStats

julia> foldxt.(Ref(Mean()), grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Mean{Float64,EqualWeight},…} with 2 entries:
  false => Mean: n=3 | value=1.33333
  true  => Mean: n=7 | value=4.71429
```

An example for calculating the minimum, maximum, and number of each
group in one go:

```julia
julia> table = ((k = gcd(v, 42), v = v) for v in 1:100);

julia> collect(Iterators.take(table, 5))  # preview
5-element Array{NamedTuple{(:k, :v),Tuple{Int64,Int64}},1}:
 (k = 1, v = 1)
 (k = 2, v = 2)
 (k = 3, v = 3)
 (k = 2, v = 4)
 (k = 1, v = 5)

julia> counter = reducingfunction(Map(_ -> 1), +);

julia> foldxt.(TeeRF(min, max, counter), Map(x -> x.v), grouped(x -> x.k, table))
Transducers.GroupByViewDict{Int64,Tuple{Int64,Int64,Int64},…} with 8 entries:
  7  => (7, 91, 5)
  14 => (14, 98, 5)
  42 => (42, 84, 2)
  2  => (2, 100, 29)
  3  => (3, 99, 15)
  21 => (21, 63, 2)
  6  => (6, 96, 14)
  1  => (1, 97, 28)
```
