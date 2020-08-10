module LazyGroupBy

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia"m => "```jldoctest README")
end LazyGroupBy

export grouped

using BangBang: merge!!
using BangBang.NoBang: SingletonVector, SingletonDict
using Base: add_sum, mul_prod
using Base.Broadcast: Broadcasted
using InitialValues: InitialValues
using OnlineStats: Mean, Variance, value, nobs
using Statistics: Statistics, mean, std, var
using Transducers
using Transducers: IdentityTransducer, ZipSource, extract_transducer

if !@isdefined only
    using Compat: only
end

const FoldFunction0 = Union{typeof(foldl),typeof(reduce),typeof(dreduce)}
if @isdefined foldxl
    const FoldFunction1 = Union{typeof(foldxl),typeof(foldxt),typeof(foldxd)}
else
    const FoldFunction1 = Union{}
    const foldxl = foldl
    const foldxt = reduce
    const foldxd = dreduce
end
const FoldFunction = Union{FoldFunction0,FoldFunction1}

# Used only for `KWBroadcastedInner` below:
function air end
struct Aired{T}
    value::T
end
Broadcast.broadcasted(::typeof(air), x) = Aired(x)
Broadcast.materialize(x::Aired) = x.value

# A hack to support broadcasting with keyword arguments:
const KWBroadcastedInner = let T = typeof(air.(identity.(; dummy = 1)).f)
    getfield(parentmodule(T), nameof(T))
end
# TODO: Use `FixKwargs` after:
# https://github.com/JuliaLang/julia/pull/36093

"""
    grouped(key, collection)

Create a lazy associative (dict-like) object grouped by a function
`key`.  Actual per-group reduction can be initiated by the dot-call
(broadcasting) of the "reducers" like `foldl` and `reduce`.

# Examples
```jldoctest
julia> using LazyGroupBy

julia> length.(grouped(isodd, 1:7))
Transducers.GroupByViewDict{Bool,Int64,…} with 2 entries:
  false => 3
  true  => 4
```
"""
grouped(key, collection) = GroupedBy(key, collection)

struct GroupedBy{K,C}
    key::K
    collection::C
end

struct GroupedByStyle <: Broadcast.BroadcastStyle end
Base.BroadcastStyle(::Type{<:GroupedBy}) = GroupedByStyle()
Base.BroadcastStyle(::GroupedByStyle, ::Broadcast.BroadcastStyle) = GroupedByStyle()

Base.broadcastable(x::GroupedBy) = x
Broadcast.instantiate(bc::Broadcasted{GroupedByStyle}) = bc

unwrap0d(x::Ref) = x[]
unwrap0d(x) = Base.IteratorSize(x) isa Base.HasShape{0} ? only(x) : x

_namedtuple(kwargs) = kwargs.data::NamedTuple

function Base.copy(bc::Broadcasted{GroupedByStyle})
    if bc.f isa KWBroadcastedInner
        return impl(bc.f.f, _namedtuple(bc.f.kwargs), map(unwrap0d, bc.args)...)
    else
        return impl(bc.f, NamedTuple(), map(unwrap0d, bc.args)...)
    end
end

check_kwargs(_, kwargs::Union{NamedTuple{()},NamedTuple{(:init,)}}) = kwargs
check_kwargs(f, kwargs::NamedTuple) =
    throw(ArgumentError("invalid keyword arguments for `$f`: $kwargs"))

_groupby_kwargs(; init = Transducers.DefaultInit, kwargs...) = ((init,), kwargs)

function _impl_fold(fold, kwargs, rf, xf, group)
    (init,), kwargs = _groupby_kwargs(; kwargs...)
    prexf, collection = extract_transducer(group.collection)
    gxf = opcompose(prexf, GroupBy(group.key, opcompose(Map(last), xf), rf, init))
    d = fold(right, gxf, collection; init = nothing, kwargs...)
    if d === nothing
        error("input collection is empty or all filtered out")
    end
    return d
end

impl(fold::FoldFunction, kwargs, rf, xf::Transducer, group::GroupedBy) =
    _impl_fold(fold, kwargs, rf, xf, group)
impl(fold::FoldFunction, kwargs, rf, xs) = impl(fold, kwargs, rf, Map(identity), xs)

impl(::typeof(mapfoldl), kwargs, f, rf, xs) = impl(foldl, kwargs, rf, Map(f), xs)
impl(::typeof(mapreduce), kwargs, f, rf, xs) = impl(reduce, kwargs, rf, Map(f), xs)

impl(::typeof(collect), kwargs, xf::Transducer, group::GroupedBy) = foldl(
    right,
    GroupBy(group.key, opcompose(Map(last), xf, Map(SingletonVector)), append!!),
    group.collection,
)
impl(::typeof(collect), kwargs, group::GroupedBy) =
    impl(collect, kwargs, IdentityTransducer(), group)

impl(::typeof(tcollect), kwargs, xf::Transducer, group::GroupedBy) = foldxt(
    right,
    GroupBy(group.key, opcompose(Map(last), xf, Map(SingletonVector)), append!!),
    group.collection,
)
impl(::typeof(tcollect), kwargs, group::GroupedBy) =
    impl(tcollect, kwargs, IdentityTransducer(), group)

impl(::typeof(dcollect), kwargs, xf::Transducer, group::GroupedBy) = foldxd(
    right,
    GroupBy(group.key, opcompose(Map(last), xf, Map(SingletonVector)), append!!),
    group.collection;
    kwargs...,
)
impl(::typeof(dcollect), kwargs, group::GroupedBy) =
    impl(dcollect, kwargs, IdentityTransducer(), group)

impl(::typeof(map), kwargs, f, group::GroupedBy) = impl(collect, kwargs, Map(f), group)

impl(::typeof(sum), kwargs::NamedTuple, group::GroupedBy) =
    impl(foldl, kwargs, add_sum, IdentityTransducer(), group)
impl(::typeof(sum), kwargs::NamedTuple, f, group::GroupedBy) =
    impl(foldl, check_kwargs(sum, kwargs), add_sum, Map(f), group)

impl(::typeof(prod), kwargs::NamedTuple, group::GroupedBy) =
    impl(foldl, kwargs, mul_prod, IdentityTransducer(), group)
impl(::typeof(prod), kwargs::NamedTuple, f, group::GroupedBy) =
    impl(foldl, check_kwargs(prod, kwargs), mul_prod, Map(f), group)

struct AsBool{F}
    f::F
end
AsBool(::Type{T}) where {T} = AsBool{Type{T}}(T)
@inline (f::AsBool)(x) = f.f(x)::Bool

impl(::typeof(count), ::NamedTuple{()}, group::GroupedBy) =
    impl(foldl, (init = 0,), +, Map(AsBool(identity)), group)
impl(::typeof(count), ::NamedTuple{()}, f, group::GroupedBy) =
    impl(foldl, (init = 0,), +, Map(AsBool(f)), group)
impl(::typeof(length), ::NamedTuple{()}, group::GroupedBy) =
    impl(foldl, (init = 0,), +, Map(_ -> 1), group)

# impl(::typeof(any), ::NamedTuple{()}, group::GroupedBy) =
#     impl(foldl, NamedTuple(), |, IdentityTransducer(), group)
impl(::typeof(any), ::NamedTuple{()}, f, group::GroupedBy) =
    impl(foldl, NamedTuple(), |, Map(f), group)

# impl(::typeof(all), ::NamedTuple{()}, group::GroupedBy) =
#     impl(foldl, NamedTuple(), &, IdentityTransducer(), group)
impl(::typeof(all), ::NamedTuple{()}, f, group::GroupedBy) =
    impl(foldl, NamedTuple(), &, Map(f), group)

impl(::typeof(minimum), kwargs::NamedTuple, group::GroupedBy) =
    impl(minimum, kwargs, identity, group)
impl(::typeof(minimum), kwargs::NamedTuple, f, group::GroupedBy) =
    impl(mapfoldl, check_kwargs(minimum, kwargs), f, min, group)
impl(::typeof(maximum), kwargs::NamedTuple, group::GroupedBy) =
    impl(maximum, kwargs, identity, group)
impl(::typeof(maximum), kwargs::NamedTuple, f, group::GroupedBy) =
    impl(mapfoldl, check_kwargs(maximum, kwargs), f, max, group)

impl(::typeof(extrema), kwargs::NamedTuple, group::GroupedBy) =
    impl(extrema, kwargs, identity, group)
impl(::typeof(extrema), kwargs::NamedTuple, f, group::GroupedBy) =
    impl(mapfoldl, check_kwargs(extrema, kwargs), DupY(f), extrema_rf, group)

struct DupY{F} <: Function
    f::F
end
DupY(f::Type{T}) where {T} = DupY{Type{T}}(f)
@inline (f::DupY)(x) = (y = f.f(x); (y, y))

extrema_rf((min1, max1), (min2, max2)) = (min(min1, min2), max(max1, max2))

impl(::typeof(keys), ::NamedTuple{()}, group::GroupedBy) = foldl(
    right,
    GroupBy(
        group.key ∘ last,
        Map(((_key, (idx, _val)),) -> SingletonVector(idx)),
        append!!,
    ),
    pairs(group.collection),
)

impl(::typeof(pairs), ::NamedTuple{()}, group::GroupedBy) = foldl(
    right,
    GroupBy(
        group.key ∘ last,
        Map(((_key, (idx, val)),) -> SingletonDict(idx => val)),
        merge!!,
    ),
    pairs(group.collection),
)

impl(::typeof(view), ::NamedTuple{()}, group::GroupedBy) =
    Dict(k => view(group.collection, idx) for (k, idx) in impl(keys, NamedTuple(), group))

left(x, _) = x
left(x) = x
InitialValues.@def_monoid left

# `identity` here is pretty useless. Maybe `_ -> true`?
# impl(::typeof(findfirst), ::NamedTuple{()}, group::GroupedBy) =
#     impl(findfirst, NamedTuple(), identity, group)
impl(::typeof(findfirst), ::NamedTuple{()}, f, group::GroupedBy) = foldl(
    right,
    GroupBy(
        group.key ∘ last,
        opcompose(
            Filter(((_key, (_idx, val)),) -> f(val)),
            Map(((_key, (idx, _val)),) -> idx),
        ),
        left,
    ),
    pairs(group.collection),
)

# impl(::typeof(findlast), ::NamedTuple{()}, group::GroupedBy) =
#     impl(findlast, NamedTuple(), identity, group)
impl(::typeof(findlast), ::NamedTuple{()}, f, group::GroupedBy) = foldl(
    right,
    GroupBy(
        group.key ∘ last,
        opcompose(Filter(((_key, (_idx, val)),) -> f(val)), Map(((_key, (idx, _val)),) -> idx)),
        right,
    ),
    pairs(group.collection),
)

impl(::typeof(findall), kwargs, f, group::GroupedBy) = foldl(
    right,
    GroupBy(
        group.key ∘ last,
        opcompose(
            Filter(((_key, (_idx, val)),) -> f(val)),
            Map(((_key, (idx, _val)),) -> SingletonVector(idx)),
        ),
        append!!,
    ),
    pairs(group.collection),
)

# Statistics
function _group_foldl_os(::NamedTuple{()}, os, xf, group)
    d = impl(foldl, NamedTuple(), os, xf, group)
    return Dict(k => value(v) for (k, v) in pairs(d))
end

impl(::typeof(mean), kwargs, group::GroupedBy) =
    impl(mean, kwargs, identity, group::GroupedBy)
impl(::typeof(mean), kwargs, f, group::GroupedBy) = impl(mean, kwargs, Map(f), group)
impl(::typeof(mean), kwargs, xf::Transducer, group::GroupedBy) =
    _group_foldl_os(kwargs, Mean(), xf, group)

impl(::typeof(var), kwargs, group::GroupedBy) =
    impl(var, kwargs, identity, group::GroupedBy)
impl(::typeof(var), kwargs, f, group::GroupedBy) = impl(var, kwargs, Map(f), group)
function impl(::typeof(var), kwargs, xf::Transducer, group::GroupedBy)
    d = impl(foldl, NamedTuple(), Variance(), xf, group)
    return Dict(k => nobs(v) < 2 ? NaN : value(v) for (k, v) in pairs(d))
end

impl(::typeof(std), kwargs, group::GroupedBy) =
    impl(std, kwargs, identity, group::GroupedBy)
impl(::typeof(std), kwargs, f, group::GroupedBy) = impl(std, kwargs, Map(f), group)
function impl(::typeof(std), ::NamedTuple{()}, xf::Transducer, group::GroupedBy)
    d = impl(foldl, NamedTuple(), Variance(), xf, group)
    return Dict(k => nobs(v) < 2 ? NaN : sqrt(value(v)) for (k, v) in pairs(d))
end

# Helper function for Documenter
_is_public(x) =
    x === (@__MODULE__) ||
    x in grouped ||
    parentmodule(x) in (Base, Statistics, Transducers)

function _import_docs()
    processed = Symbol[]
    # Use markdown files as docstring:
    for file in readdir(joinpath(@__DIR__, "docs"))
        endswith(file, ".md") || continue
        name = Symbol(file[1:end-length(".md")])
        path = joinpath(@__DIR__, "docs", file)
        # Don't fail when somehow importing docstrings doesn't work (we
        # don't loose any functionalities for that).
        try
            include_dependency(path)
            str = read(path, String)
            str = replace(str, r"^```julia"m => "```jldoctest $name")
            @eval @doc $str $name
        catch err
            @error(
                "Failed to import docstring for $name",
                exception = (err, catch_backtrace()),
            )
        end
        push!(processed, name)
    end
    return processed
end
_import_docs()

end # module
