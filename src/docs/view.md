    view.(grouped(key, array))

Like `collect.(grouped(key, array))`, but return a mutable view to the
input `array`.

# Examples

```julia
julia> using LazyGroupBy

julia> xs = [0, 7, 3];

julia> gs = view.(grouped(isodd, xs))
Dict{Bool,SubArray{Int64,1,Array{Int64,1},Tuple{Array{Int64,1}},false}} with 2 entries:
  false => [0]
  true  => [7, 3]

julia> gs[false][end] = 111;

julia> xs
3-element Array{Int64,1}:
 111
   7
   3
```

