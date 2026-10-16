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
    @inline asnonstatic(r::StaticArrays.SUnitRange) =
        asnonstatic(maybestatic_first(r)):asnonstatic(maybestatic_last(r))
end
@inline asnonstatic(r::AbstractUnitRange) =
    asnonstatic(maybestatic_first(r)):asnonstatic(maybestatic_last(r))
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
    fill(x, staticarray_type(T, sz))
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
    staticarray_type(T, sz::StaticSizeLike)

Returns the type of a static array with element type `T` and size `sz`.
"""
function staticarray_type end
export staticarray_type

@inline staticarray_type(::Type{T}, sz::StaticSizeLike) where {T} =
    staticarray_type(T, _static_size(sz))

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
Other arrays are reshaped with the non-static size, not converted to an
`SArray`. As with `reshape`, the result shares the memory of a mutable `A`.
"""
function maybestatic_reshape end
export maybestatic_reshape

@inline maybestatic_reshape(A, sz::SizeLike) = reshape(A, asnonstatic(sz))
@inline maybestatic_reshape(A::StaticArray, sz::StaticSizeLike) =
    reshape(A, _static_size(sz))


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
@inline maybestatic_length(r::AbstractUnitRange) = length(r)
@static if isdefined(StaticArrays, :SUnitRange)
    @inline maybestatic_length(::StaticArrays.SUnitRange{B,L}) where {B,L} = static(L)
end
@inline maybestatic_length(::StaticArrays.SOneTo{N}) where {N} = static(N)
# Static ranges aren't normalized when empty, so compare before subtracting:
@inline maybestatic_length(::Static.SUnitRange{F,L}) where {F,L} = static(L < F ? 0 : L - F + 1)

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
@inline maybestatic_size(A::StaticArray) = canonical_size(StaticArrays.Size(A))

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
    StaticThings.axes2size(::Type{<:NTuple{N,StaticUnitRangeLike}})

Get the size of a collection-like object from its axes.

The type-level form gives the size of collections with statically sized
axes without an instance at hand.
"""
function axes2size end
export axes2size

@inline axes2size(::Tuple{}) = ()
@inline axes2size(axs::Tuple) = canonical_size(map(maybestatic_length, axs))

@inline axes2size(::Type{Tuple{}}) = ()
@inline axes2size(::Type{A}) where {N,A<:NTuple{N,StaticUnitRangeLike}} =
    canonical_size(_static_axes_lengths(A))

@inline _static_axes_lengths(::Type{Tuple{}}) = ()
@inline _static_axes_lengths(::Type{A}) where {A<:Tuple} = (
    _static_range_length(Base.tuple_type_head(A)),
    _static_axes_lengths(Base.tuple_type_tail(A))...,
)

@inline _static_range_length(::Type{<:StaticArrays.SOneTo{N}}) where {N} = static(N)
@static if isdefined(StaticArrays, :SUnitRange)
    @inline _static_range_length(::Type{<:StaticArrays.SUnitRange{B,L}}) where {B,L} = static(L)
end
@inline _static_range_length(::Type{<:Static.SUnitRange{F,L}}) where {F,L} =
    static(L < F ? 0 : L - F + 1)


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
maybestatic_first(r::AbstractRange) = first(r)
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
maybestatic_last(r::AbstractRange) = last(r)
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
) where {N} = StaticArrays.SOneTo{max(0, N)}()
# An empty range is clamped before the constructor subtracts, so that
# extreme endpoints don't wrap around:
@inline canonical_indices(
    ::Static.OptionallyStaticUnitRange{<:StaticInteger{A},<:StaticInteger{B}},
) where {A,B} = StaticUnitRange(A, B < A ? A - 1 : B)
@inline canonical_indices(
    r::Static.OptionallyStaticUnitRange{<:StaticInteger{1},<:Integer},
) = Base.OneTo(last(r))


"""
    canonical_size(sz::SizeLike)

Return the canonical representation of a collection size.

A fully static size is a `StaticArrays.Size`, except the zero-dimensional
one, which is `()`, and dynamic dimensions are `Int`s, both as in a `size`
from Base.
"""
function canonical_size end
export canonical_size

@inline canonical_size(sz::SizeLike) = map(_canonical_dim, sz)
@inline canonical_size(sz::StaticArrays.Size) = sz
@inline canonical_size(sz::Tuple{Vararg{Static.StaticInteger}}) =
    StaticArrays.Size{map(dynamic, sz)}()
@inline canonical_size(::Tuple{}) = ()
@inline canonical_size(::StaticArrays.Size{()}) = ()

@inline _canonical_dim(n::Integer) = Int(n)
@inline _canonical_dim(n::StaticInteger) = n

# StaticArrays needs a `Size` to build and reshape its arrays, for the
# zero-dimensional size too:
@inline _static_size(sz::StaticSizeLike) = StaticArrays.Size{asnonstatic(sz)}()


"""
    size_tuple(sz::SizeLike)::Tuple{Vararg{IntegerLike}}

Return the dimensions of the size `sz` as a tuple of dynamic or static
integers.

Inverse of [`canonical_size`](@ref).
"""
function size_tuple end
export size_tuple

@inline size_tuple(sz::Tuple{Vararg{IntegerLike}}) = sz
@inline size_tuple(::StaticArrays.Size{S}) where {S} = map(static, S)

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
