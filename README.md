# LazyGroupBy: lazy, parallelizable and composable group-by operations

LazyGroupBy.jl exports a single API `grouped`.  It can be used to run
group-by operation using the dot-call syntax:

```JULIA
reducer.(..., grouped(key, collection), ...)
```

where `reducer` runs on _each_ group (thus, `grouped(key, collection)`
can be considered a as a key-value pairs with
[Dictionaries.jl](https://github.com/andyferris/Dictionaries.jl)-like
broadcasting rule).  Roughly speaking, `grouped(key, collection)` is
equivalent to `Dict(k_1 => [v_11, v_12, ...], k_2 =>
[v_21, v_22, ...], ...)` where `k_i` is an output of value of
`key(v_ij)` for `v_ij` in `collection` and each call of `reducer` is
evaluated with a group "vector" `[v_i1, v_i2, ...]`.

For example:

```julia
julia> using LazyGroupBy

julia> collect.(grouped(isodd, 1:7))
Transducers.GroupByViewDict{Bool,Array{Int64,1},…} with 2 entries:
  false => [2, 4, 6]
  true  => [1, 3, 5, 7]

julia> length.(grouped(isodd, 1:7))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 3
  true  => 4

julia> keys.(grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Array{Int64,1},…} with 2 entries:
  false => [1, 7, 9]
  true  => [2, 3, 4, 5, 6, 8, 10]

julia> foldl.(tuple, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Any,…} with 2 entries:
  false => ((0, 4), 0)
  true  => ((((((7, 3), 1), 5), 9), 3), 5)

julia> foldl.(tuple, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]); init = -1)
Transducers.GroupByViewDict{Bool,Tuple{Any,Int64},…} with 2 entries:
  false => (((-1, 0), 4), 0)
  true  => (((((((-1, 7), 3), 1), 5), 9), 3), 5)

julia> extrema_rf((min1, max1), (min2, max2)) = (min(min1, min2), max(max1, max2));

julia> mapfoldl.(x -> (x, x), extrema_rf, grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Tuple{Int64,Int64},…} with 2 entries:
  false => (0, 4)
  true  => (1, 9)
```

Following generic and standard reducers are supported:

* `collect.(op, grouped(...))` → `DICT{Key,Vector{...}}`
* `view.(grouped(_, array))` → `DICT{Key,SubArray}`
* `map.(f, grouped(...))`
* `length.(op, grouped(...))` → `DICT{Key,Int}`
* `count.([f,] op, grouped(...))` → `DICT{Key,Int}`
* `sum.([f,] op, grouped(...))` → `DICT{Key,Number}`
* `prod.([f,] op, grouped(...))` → `DICT{Key,Number}`
* `any.(f, op, grouped(...))` → `DICT{Key,Bool}`
* `all.(f, op, grouped(...))` → `DICT{Key,Bool}`
* `minimum.([f,] op, grouped(...))`
* `maximum.([f,] op, grouped(...))`
* `extrema.([f,] op, grouped(...))`
* `keys.(op, grouped(_, collection))` → `DICT{Key,Vector{keytype(collection)}}`
* `pairs.(op, grouped(_, collection))` →
  `DICT{Key,DICT{keytype(collection),valtype(collection)}}`
* `findfirst.(f, grouped(_, array))` → `DICT{Key,keytype(collection)}`
* `findlast.(f, grouped(_, array))` → `DICT{Key,keytype(collection)}`
* `findall.(f, grouped(_, array))` → `DICT{Key,Vector{keytype(collection)}}`
* `foldl.(op, grouped(...); [init])`
* `mapfoldl.(f, op, grouped(...); [init])`
* `reduce.(op, grouped(...); [init])` (multi-threaded)
* `mapreduce.(f, op, grouped(...); [init])` (multi-threaded)

where `DICT{K,V}` above is a short-hand for `AbstractDict{<:K,<:V}`
and `Key` is the type of the values returned from `key` function
passed to `grouped`.

For more complex tasks,
[Transducers.jl](https://github.com/tkf/Transducers.jl) and
[OnlineStats.jl](https://github.com/joshday/OnlineStats.jl) can also
be used:

* `foldl.(op, xf, grouped(...); [init])`
* `reduce.(op, xf, grouped(...); [init])` (multi-threaded)
* `dreduce.(op, xf, grouped(...); [init])` (distributed)
* `collect.(xf, grouped(...))`
* `tcollect.(xf, grouped(...))` (multi-threaded version of `collect`)
* `dcollect.(xf, grouped(...))` (distributed version of `collect`)

where `xf::Transducer` is initiated for each group individually and
`op` is either a two-argument function or an `OnlineStat` object
(e.g., `OnlineStats.Mean`).

## Caveats

The dot-call syntax is used for defining the "domain-specific
language" (DSL) and it is different from the standard semantics of
broadcasting on arrays.  In particular, `reducer.(..., grouped(key,
collection), ...)` may not actually call `reducer`.  Rather, it is
pattern-matched and dispatched to an alternative definition based on
Transducers.jl.

## Implementation

LazyGroupBy.jl is implemented as a direct transformation to
`foldl`/`reduce`/`dreduce` and `GroupBy` from Transducer.jl.  Consider

```JULIA
foldl.(rf, xf, grouped(key, collection); init = init)
```

This is simply translated to

```JULIA
foldl(right, GroupBy(key, xf, rf, init), collection)
```

Other reducers like `sum` and `collect` are implemented in terms of
above transformation.
