# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

"""
    maybestatic_oneto(n::IntegerLike)

Creates a range from one to n.

Returns an instance of `Base.OneTo` or [`StaticOneTo`](@ref), depending on the
type of `n`.
"""
function maybestatic_oneto end
export maybestatic_oneto

@inline maybestatic_oneto(n::Integer) = Base.OneTo(n)
@inline maybestatic_oneto(::Static.StaticInteger{N}) where {N} = StaticOneTo(N)


"""
    asnonstatic(x)

Return a non-static equivalent of `x`.

Defined for numbers, tuples, ranges, sizes and axes.
"""
function asnonstatic end
export asnonstatic

@inline asnonstatic(x::Number) = dynamic(x)
@inline asnonstatic(::Tuple{}) = ()
@static if isdefined(StaticArrays, :SUnitRange)
    @inline asnonstatic(r::StaticArrays.SUnitRange) = r[begin]:r[end]
end
@inline asnonstatic(r::AbstractUnitRange) = asnonstatic(r[begin]):asnonstatic(r[end])
@inline asnonstatic(r::Base.OneTo) = Base.OneTo(asnonstatic(r.stop))
@inline asnonstatic(::StaticOneToLike{N}) where {N} = Base.OneTo(N)
@inline asnonstatic(x::SizeLike) = map(asnonstatic, x)
@inline asnonstatic(::StaticArrays.Size{TPL}) where {TPL} = TPL
@inline asnonstatic(x::AxesLike) = map(asnonstatic, x)


"""
    maybestatic_fill(x, sz::NTuple{N,<:IntegerLike}) where N

Creates an array of size `sz` filled with `x`.

The result will typically be either a `FillArrays.Fill` or a
`StaticArrays.StaticArray`.
"""
function maybestatic_fill end
export maybestatic_fill

@inline maybestatic_fill(x::T, n::IntegerLike) where {T} = maybestatic_fill(x, (n,))

@inline maybestatic_fill(x, ::Tuple{}) = maybestatic_fill(x, StaticArrays.Size())

@inline maybestatic_fill(x, sz::SizeLike) = maybestatic_fill(x, size2axes(sz))

@inline function maybestatic_fill(x::T, sz::StaticSizeLike) where {T}
    fill(x, staticarray_type(T, canonical_size(sz)))
end

@inline function maybestatic_fill(x, axs::AxesLike)
    dyn_axs = map(asnonstatic, axs)
    FillArrays.Fill(x, dyn_axs)
end

# While `FillArrays.Fill` (mostly?) works with axes that are static unit
# ranges, some operations that automatic differentiation requires do fail
# on such instances of `Fill` (e.g. `reshape` from dynamic to static size).
# So need to build a filled static array:
@inline function maybestatic_fill(x::T, axs::Tuple{Vararg{StaticOneToLike}}) where {T}
    sz = axes2size(axs)
    fill(x, staticarray_type(T, sz))
end


"""
    staticarray_type(T, sz::StaticArrays.Size)

Returns the type of a static array with element type `T` and size `sz`.
"""
function staticarray_type end
export staticarray_type

@inline @generated function staticarray_type(
    ::Type{T},
    ::StaticArrays.Size{sz},
) where {T,sz}
    N = length(sz)
    len = prod(sz)
    :(SArray{Tuple{$sz...},T,$N,$len})
end


"""
    maybestatic_reshape(A, sz::SizeLike)

Reshapes array `A` to size `sz`.

If `A` is a static array and `sz` is static, the result is a static array.
Other arrays are reshaped to the non-static size, so that device arrays and
traced arrays keep their type.
"""
function maybestatic_reshape end
export maybestatic_reshape

@inline maybestatic_reshape(A, sz::SizeLike) = reshape(A, asnonstatic(sz))
@inline maybestatic_reshape(A::StaticArray, sz::StaticSizeLike) =
    reshape(A, canonical_size(sz))


"""
    maybestatic_length(x)

Returns the length of `x` as a dynamic or static integer.
"""
function maybestatic_length end
export maybestatic_length

@inline maybestatic_length(::Number) = static(1)
@inline maybestatic_length(::Tuple{}) = static(0)
@inline maybestatic_length(::Tuple{Vararg{Any,N}}) where {N} = static(N)
@inline maybestatic_length(nt::NamedTuple) = maybestatic_length(values(nt))
@inline maybestatic_length(A::AbstractArray) = size2length(maybestatic_size(A))
@static if isdefined(StaticArrays, :SUnitRange)
    @inline maybestatic_length(r::StaticArrays.SUnitRange) = maybestatic_last(r) - maybestatic_first(r) + static(1)
end
@inline maybestatic_length(r::AbstractUnitRange) = maybestatic_last(r) - maybestatic_first(r) + static(1)
@inline maybestatic_length(r::Base.OneTo) = length(r)
@inline maybestatic_length(::StaticArrays.SOneTo{N}) where {N} = static(N)
@inline maybestatic_length(::Static.SOneTo{N}) where {N} = static(N)

"""
    maybestatic_size(x)::SizeLike

Returns the size of `x` as a tuple of dynamic or static integers or as a
`StaticArrays.Size`.
"""
function maybestatic_size end
export maybestatic_size

@inline maybestatic_size(::Number) = ()
@inline maybestatic_size(::Tuple{}) = StaticArrays.Size(0)
@inline maybestatic_size(::Tuple{Vararg{Any,N}}) where {N} = StaticArrays.Size(N)
@inline maybestatic_size(nt::NamedTuple) = maybestatic_size(values(nt))
@inline maybestatic_size(::StaticArrays.Size{tpl}) where {tpl} = StaticArrays.Size(length(tpl))
@inline maybestatic_size(A::AbstractArray) = axes2size(maybestatic_axes(A))
@inline maybestatic_size(A::StaticArray) = StaticArrays.Size(A)

"""
    maybestatic_axes(x)::AxesLike

Returns the axes of `x` as a tuple of dynamic or static unit ranges.
"""
function maybestatic_axes end
export maybestatic_axes

@inline maybestatic_axes(::Number) = ()

@inline maybestatic_axes(::Tuple{}) = (StaticOneTo(0),)
@inline maybestatic_axes(::Tuple{Vararg{Any,N}}) where {N} = (StaticOneTo(N),)
@inline maybestatic_axes(nt::NamedTuple) = maybestatic_axes(values(nt))
@inline maybestatic_axes(::StaticArrays.Size{tpl}) where {tpl} = (StaticOneTo(length(tpl)),)
@inline maybestatic_axes(A::AbstractArray) = canonical_axes(axes(A))


"""
    StaticThings.axes2size(axs::AxesLike)
    StaticThings.axes2size(::Type{<:Tuple{Vararg{StaticOneToLike}}})

Get the size of a collection-like object from its axes.

The type-level form gives the size of collections with statically sized
axes without an instance at hand.
"""
function axes2size end
export axes2size

@inline axes2size(::Tuple{}) = ()
@inline axes2size(axs::Tuple) = canonical_size(map(maybestatic_length, axs))

@inline axes2size(::Type{A}) where {A<:Tuple{Vararg{StaticOneToLike}}} =
    canonical_size(_static_axes_lengths(A))

@inline _static_axes_lengths(::Type{Tuple{}}) = ()
@inline _static_axes_lengths(::Type{A}) where {A<:Tuple} = (
    _static_oneto_length(Base.tuple_type_head(A)),
    _static_axes_lengths(Base.tuple_type_tail(A))...,
)

@inline _static_oneto_length(::Type{<:StaticArrays.SOneTo{N}}) where {N} = static(N)
@inline _static_oneto_length(::Type{<:Static.SOneTo{N}}) where {N} = static(N)


"""
    size2axes(sz::Tuple)
    size2axes(sz::StaticArrays.Size)

Get one-based indexing axes from a size of a collection-like object.
"""
function size2axes end
export size2axes

@inline size2axes(::Tuple{}) = ()
@inline size2axes(sz::Tuple) = canonical_axes(map(maybestatic_oneto, sz))
@inline size2axes(::StaticArrays.Size{TPL}) where {TPL} = map(StaticOneTo, TPL)


"""
    size2length(sz::Tuple)
    size2length(sz::StaticArrays.Size)

Get a length from a size (tuple).
"""
function size2length end
export size2length

@inline size2length(::Tuple{}) = static(1)
@inline size2length(sz::Tuple) = prod(sz)
@inline size2length(::StaticArrays.Size{TPL}) where {TPL} = static(prod(TPL))


"""
    asaxes(axs::AxesLike)
    asaxes(sz::SizeLike)
    asaxes(len::IntegerLike)

Converts axes or a size or a length of a collection to axes.

One-based indexing will be used if the indexing offset can't be inferred from
the given dimensions.
"""
function asaxes end
export asaxes

@inline asaxes(::Tuple{}) = ()
@inline asaxes(axs::AxesLike) = axs
@inline asaxes(sz::SizeLike) = size2axes(sz)
@inline asaxes(len::IntegerLike) = size2axes((len,))


"""
    maybestatic_eachindex(x)

Returns the index range of `x` as a dynamic or static integer range.
"""
function maybestatic_eachindex end
export maybestatic_eachindex

maybestatic_eachindex(::Number) = StaticOneTo(1)
maybestatic_eachindex(::Tuple{}) = StaticOneTo(0)
maybestatic_eachindex(::Tuple{Vararg{Any,N}}) where {N} = StaticOneTo(N)
maybestatic_eachindex(nt::NamedTuple) = maybestatic_eachindex(values(nt))
maybestatic_eachindex(::StaticArrays.Size{tpl}) where {tpl} = StaticOneTo(length(tpl))
maybestatic_eachindex(x::AbstractArray) = canonical_indices(eachindex(x))


"""
    maybestatic_first(A)

Returns the first element of `A` as a dynamic or static value.
"""
function maybestatic_first end
export maybestatic_first

maybestatic_first(x::Number) = x
maybestatic_first(tpl::Tuple) = tpl[begin]
maybestatic_first(nt::NamedTuple) = nt[begin]
maybestatic_first(A::AbstractArray) = A[begin]
maybestatic_first(::Base.OneTo) = static(1)
maybestatic_first(::StaticArrays.Size{tpl}) where {tpl} = static(tpl[begin])
maybestatic_first(::StaticArrays.SOneTo{N}) where {N} = static(1)
@static if isdefined(StaticArrays, :SUnitRange)
    maybestatic_first(::StaticArrays.SUnitRange{B,L}) where {B,L} = static(B)
end
function maybestatic_first(
    ::Static.OptionallyStaticUnitRange{<:Static.StaticInteger{from}},
) where {from}
    static(from)
end


"""
    maybestatic_last(A)

Returns the last element of `A` as a dynamic or static value.
"""
function maybestatic_last end
export maybestatic_last

maybestatic_last(x::Number) = x
maybestatic_last(tpl::Tuple) = tpl[end]
maybestatic_last(nt::NamedTuple) = nt[end]
maybestatic_last(A::AbstractArray) = A[end]
maybestatic_last(::StaticArrays.Size{tpl}) where {tpl} = static(tpl[end])
maybestatic_last(::StaticArrays.SOneTo{N}) where {N} = static(N)
@static if isdefined(StaticArrays, :SUnitRange)
    maybestatic_last(::StaticArrays.SUnitRange{B,L}) where {B,L} = static(B + L - 1)
end
function maybestatic_last(
    ::Static.OptionallyStaticUnitRange{<:Any,<:Static.StaticInteger{until}},
) where {until}
    static(until)
end


"""
    canonical_indices(idxs::AbstractVector{<:IntegerLike})

Return the canonical representation of a collection axis indices.
"""
function canonical_indices end
export canonical_indices

@inline canonical_indices(idxs::AbstractVector{<:IntegerLike}) = idxs
@inline canonical_indices(idxs::AbstractArray{<:CartesianIndex}) = idxs
@inline canonical_indices(
    ::Static.OptionallyStaticUnitRange{<:StaticInteger{1},<:StaticInteger{N}},
) where {N} = StaticArrays.SOneTo{N}()
@inline canonical_indices(
    ::Static.OptionallyStaticUnitRange{<:StaticInteger{A},<:StaticInteger{B}},
) where {A,B} = StaticUnitRange(A, B)
@inline canonical_indices(
    r::Static.OptionallyStaticUnitRange{<:StaticInteger{1},<:Integer},
) = Base.OneTo(last(r))


"""
    canonical_size(sz::SizeLike)

Return the canonical representation of a collection size.
"""
function canonical_size end
export canonical_size

@inline canonical_size(sz::SizeLike) = sz
@inline canonical_size(sz::Tuple{Vararg{Static.StaticInteger}}) =
    StaticArrays.Size{map(dynamic, sz)}()


"""
    size_dims(sz::SizeLike)::Tuple{Vararg{IntegerLike}}

Return the dimensions of the size `sz` as a tuple of dynamic or static
integers.

Inverse of [`canonical_size`](@ref).
"""
function size_dims end
export size_dims

@inline size_dims(sz::Tuple{Vararg{IntegerLike}}) = sz
@inline size_dims(::StaticArrays.Size{S}) where {S} = map(static, S)

"""
    canonical_axes(axs::AxesLike)

Return the canonical representation of collection axes.
"""
function canonical_axes end
export canonical_axes

@inline canonical_axes(axs::AxesLike) = map(canonical_indices, axs)


"""
    StaticThings.NoTypeSize{T}()

Returned by [`size_from_type`](@ref) if the size of values of type
`T` is not fixed or not known.
"""
struct NoTypeSize{T} end


"""
    size_from_type(::Type{T})::StaticThings.SizeLike

Get the size (equivalent of StaticThings.maybestatic_size) of values of
type `T`.

Requires values of type `T` to have a fixed known size, returns
[`StaticThings.NoTypeSize{T}()`](@ref StaticThings.NoTypeSize) otherwise.

For array types the size is determined via `StaticArrayInterface.known_size`.
"""
function size_from_type end
export size_from_type

size_from_type(::Type{T}) where {T} = NoTypeSize{T}()
size_from_type(::Type{<:Number}) = ()
size_from_type(::Type{Tuple{}}) = StaticArrays.Size(0)
size_from_type(::Type{<:Tuple{Vararg{Any,N}}}) where {N} = StaticArrays.Size(N)
size_from_type(::Type{<:NamedTuple{names}}) where {names} = StaticArrays.Size(length(names))
function size_from_type(::Type{<:StaticArrays.Size{tpl}}) where {tpl}
    StaticArrays.Size(length(tpl))
end
@inline function size_from_type(::Type{AT}) where {AT<:AbstractArray}
    _knownsize2size(AT, StaticArrayInterface.known_size(AT))
end

# Convert a `StaticArrayInterface.known_size` result to a canonical size:
@inline _knownsize2size(::Type, ksz::Tuple{Vararg{Int}}) = canonical_size(static(ksz))
@inline _knownsize2size(::Type{AT}, ::Tuple) where {AT} = NoTypeSize{AT}()


"""
    maybestatic_view(A::AbstractVector, from::IntegerLike, until::IntegerLike)
    maybestatic_view(tpl::Tuple, from::IntegerLike, until::IntegerLike)

The elements of `A` from index `from` to index `until`.

Static vectors and tuples give static results for static indices, other
vectors give a `view`.
"""
function maybestatic_view end
export maybestatic_view

Base.@propagate_inbounds function maybestatic_view(
    A::AbstractVector,
    from::IntegerLike,
    until::IntegerLike,
)
    view(A, dynamic(from):dynamic(until))
end

Base.@propagate_inbounds function maybestatic_view(
    A::StaticVector,
    from::StaticInteger{F},
    until::StaticInteger{U},
) where {F,U}
    SVector{U - F + 1,eltype(A)}(maybestatic_view(Tuple(A), from, until))
end

Base.@propagate_inbounds function maybestatic_view(
    tpl::Tuple,
    from::IntegerLike,
    until::IntegerLike,
)
    ntuple(i -> tpl[from+i-1], Val(dynamic(until - from + one(from))))
end


"""
    split_at(A::AbstractVector, n::IntegerLike)

Split `A` into its first `n` elements and the rest.

Static vectors give static results for a static `n`.
"""
function split_at end
export split_at

@inline function split_at(A::AbstractVector, n::IntegerLike)
    idxs = maybestatic_eachindex(A)
    i_first = maybestatic_first(idxs)
    i_last = maybestatic_last(idxs)
    maybestatic_view(A, i_first, i_first + n - one(n)),
    maybestatic_view(A, i_first + n, i_last)
end


"""
    static_reduce(op, ::Type{<:Tuple})
    static_reduce(op, f, ::Type{<:Tuple})

Reduce the element types of a tuple type with `op`, applying `f` to each
element type first.

Folded pairwise from the right, so that the result is a compile-time
constant where `reduce` over a tuple of values isn't (Julia 1.10).
"""
function static_reduce end
export static_reduce

@inline static_reduce(op::OP, ::Type{T}) where {OP,T<:Tuple} = static_reduce(op, identity, T)
@inline static_reduce(op::OP, f::F, ::Type{Tuple{T}}) where {OP,F,T} = f(T)
@inline function static_reduce(op::OP, f::F, ::Type{T}) where {OP,F,T<:Tuple}
    op(f(Base.tuple_type_head(T)), static_reduce(op, f, Base.tuple_type_tail(T)))
end


"""
    static_all(f, ::Type{<:Tuple})

Whether `f` holds for every element type of a tuple type.

Returns `Static.True` or `Static.False`, folded pairwise so that the result
is a compile-time constant where `all` isn't (Julia 1.10).
"""
function static_all end
export static_all

@inline static_all(::F, ::Type{Tuple{}}) where {F} = static(true)
@inline function static_all(f::F, ::Type{T}) where {F,T<:Tuple}
    static(f(Base.tuple_type_head(T))) & static_all(f, Base.tuple_type_tail(T))
end


"""
    static_any(f, ::Type{<:Tuple})

Whether `f` holds for any element type of a tuple type.

Returns `Static.True` or `Static.False`, folded pairwise so that the result
is a compile-time constant where `any` isn't (Julia 1.10).
"""
function static_any end
export static_any

@inline static_any(::F, ::Type{Tuple{}}) where {F} = static(false)
@inline function static_any(f::F, ::Type{T}) where {F,T<:Tuple}
    static(f(Base.tuple_type_head(T))) | static_any(f, Base.tuple_type_tail(T))
end


# Dimensions of an array as a tuple of dynamic or static integers:
@inline _dims_of(A) = size_dims(maybestatic_size(A))

@noinline _throw_too_few_dims(n, N) =
    throw(DimensionMismatch("Can't operate on the $N leading dimensions of a $n-dimensional object"))


"""
    drop_leading_dims(A::AbstractArray, ::StaticInteger{N})

Drop the `N` leading (singleton) dimensions of `A`.

Reshaping instead of `dropdims` keeps static arrays static and infers.
"""
function drop_leading_dims end
export drop_leading_dims

@inline function drop_leading_dims(A::AbstractArray, ::StaticInteger{N}) where {N}
    dims = _dims_of(A)
    length(dims) >= N || _throw_too_few_dims(length(dims), N)
    maybestatic_reshape(A, ntuple(i -> dims[N+i], Val(length(dims) - N)))
end


"""
    merge_leading_dims(A::AbstractArray, ::StaticInteger{N})

Merge the `N` leading dimensions of `A` into one.

`N == 0` adds a leading dimension of size one. Static arrays stay static.
"""
function merge_leading_dims end
export merge_leading_dims

@inline merge_leading_dims(A::AbstractArray, ::StaticInteger{0}) =
    maybestatic_reshape(A, (static(1), _dims_of(A)...))

@inline function merge_leading_dims(A::AbstractArray, ::StaticInteger{N}) where {N}
    dims = _dims_of(A)
    length(dims) >= N || _throw_too_few_dims(length(dims), N)
    lead = ntuple(i -> dims[i], Val(N))
    maybestatic_reshape(A, (prod(lead), ntuple(i -> dims[N+i], Val(length(dims) - N))...))
end


"""
    all_leading_dims(A::AbstractArray{Bool}, ::StaticInteger{N})

Reduce `A` with `all` over its `N` leading dimensions.

Returns an array over the remaining dimensions, `true` or `false` if there
are none. Static arrays stay static.
"""
function all_leading_dims end
export all_leading_dims

@inline all_leading_dims(A::AbstractArray{Bool,N}, ::StaticInteger{N}) where {N} = all(A)
@inline function all_leading_dims(A::AbstractArray{Bool}, ::StaticInteger{N}) where {N}
    drop_leading_dims(all(A; dims = ntuple(identity, Val(N))), static(N))
end

# StaticArrays only reduces over a single dimension at a time:
@inline all_leading_dims(A::StaticArray{<:Any,Bool,N}, ::StaticInteger{N}) where {N} = all(A)
@inline function all_leading_dims(A::StaticArray{<:Any,Bool}, ::StaticInteger{N}) where {N}
    drop_leading_dims(_all_dims_seq(A, static(N)), static(N))
end

@inline _all_dims_seq(A::AbstractArray, ::StaticInteger{0}) = A
@inline _all_dims_seq(A::AbstractArray, ::StaticInteger{N}) where {N} =
    _all_dims_seq(all(A; dims = N), static(N - 1))


"""
    sum_leading_dims(A, ::StaticInteger{N})

Sum `A` over its `N` leading dimensions.

Returns an array over the remaining dimensions, a number if there are none.
Static arrays stay static. Lazy broadcasts are reduced without
materialization where their style supports it.
"""
function sum_leading_dims end
export sum_leading_dims

@inline sum_leading_dims(x::Number, ::StaticInteger{0}) = x
@noinline sum_leading_dims(::Number, ::StaticInteger{N}) where {N} = _throw_too_few_dims(0, N)

@inline sum_leading_dims(A::AbstractArray, n::StaticInteger) =
    _sum_leading_dims_impl(A, n, static(ndims(A)))

@inline _sum_leading_dims_impl(A::AbstractArray, ::StaticInteger{0}, ::StaticInteger) = A
@inline _sum_leading_dims_impl(A::AbstractArray, ::StaticInteger{0}, ::StaticInteger{0}) = A
@inline _sum_leading_dims_impl(A::AbstractArray, ::StaticInteger{N}, ::StaticInteger{N}) where {N} = sum(A)
@inline function _sum_leading_dims_impl(A::AbstractArray, ::StaticInteger{N}, ::StaticInteger) where {N}
    drop_leading_dims(_sum_dims_seq(A, static(N)), static(N))
end

@inline _sum_dims_seq(A::AbstractArray, ::StaticInteger{0}) = A
@inline _sum_dims_seq(A::AbstractArray, ::StaticInteger{N}) where {N} =
    _sum_dims_seq(sum(A; dims = N), static(N - 1))

# Broadcast styles whose lazy reductions work without materialization:
const _EagerReducibleBroadcast = Broadcast.Broadcasted{
    <:Union{Broadcast.DefaultArrayStyle,StaticArrays.StaticArrayStyle},
}

@inline sum_leading_dims(bc::Broadcast.Broadcasted, n::StaticInteger) =
    _sum_leading_dims_lazy(bc, n, static(ndims(bc)))

@inline _sum_leading_dims_lazy(bc::Broadcast.Broadcasted, ::StaticInteger{0}, ::StaticInteger) = bc
@inline _sum_leading_dims_lazy(bc::Broadcast.Broadcasted, ::StaticInteger{0}, ::StaticInteger{0}) = bc
@inline _sum_leading_dims_lazy(bc::_EagerReducibleBroadcast, ::StaticInteger{0}, ::StaticInteger{0}) = bc
@inline function _sum_leading_dims_lazy(bc::_EagerReducibleBroadcast, ::StaticInteger{N}, ::StaticInteger{N}) where {N}
    # An empty broadcast has no neutral element to start from, the empty
    # array it materializes to has one:
    length(bc) == 0 ? sum(copy(bc)) : sum(bc)
end
@inline _sum_leading_dims_lazy(bc::Broadcast.Broadcasted, ::StaticInteger{N}, ::StaticInteger{N}) where {N} = sum(copy(bc))
@inline _sum_leading_dims_lazy(bc::Broadcast.Broadcasted, n::StaticInteger, ::StaticInteger) =
    sum_leading_dims(copy(bc), n)
