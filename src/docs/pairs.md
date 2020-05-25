    pairs.(grouped(key, indexable))

Return a dictionary whose value is a vector of keys to the `indexable`
input collection.

# Example

```julia
julia> using LazyGroupBy

julia> pairs.(grouped(isodd, [0, 7, 3, 1, 5, 9, 4, 3, 0, 5]))
Transducers.GroupByViewDict{Bool,Dict{Int64,Int64},…} with 2 entries:
  false => Dict(7=>4,9=>0,1=>0)
  true  => Dict(4=>1,10=>5,2=>7,3=>3,5=>5,8=>3,6=>9)

julia> pairs.(grouped(isodd, Dict(zip('a':'e', 1:5))))
Transducers.GroupByViewDict{Bool,Dict{Char,Int64},…} with 2 entries:
  false => Dict('d'=>4,'b'=>2)
  true  => Dict('a'=>1,'c'=>3,'e'=>5)
```
