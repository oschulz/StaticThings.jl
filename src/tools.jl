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

Defaults to `Static.dynamic(x)`.
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

@inline maybestatic_fill(x::T, ::Tuple{}) where {T} = FillArrays.Fill(x)

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
    maybestatic_reshape(A, sz)

Reshapes array `A` to sizes `sz`.

If `A` is a static array and `sz` is static, the result is a static array.
"""
function maybestatic_reshape end
export maybestatic_reshape

maybestatic_reshape(A, sz) = reshape(A, canonical_size(sz))
function maybestatic_reshape(A, sz::StaticSizeLike)
    SArray(reshape(A, canonical_size(sz)))
end
function maybestatic_reshape(A::StaticArray, sz::Tuple{Vararg{StaticInteger}})
    staticarray_type(eltype(A), canonical_size(sz))(Tuple(A))
end


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

    maybestatic_size(x)

Returns the size of `x` as a tuple of dynamic or static integers.
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
    maybestatic_axes(x)::Tuple{Vararg{IntegerLike}}

Returns the size of `x` as a tuple of dynamic or static integers.
"""
function maybestatic_axes end
export maybestatic_axes

@inline maybestatic_axes(::Number) = ()

@inline maybestatic_axes(::Tuple{}) = (StaticOneTo(0),)
@inline maybestatic_axes(::Tuple{Vararg{Any,N}}) where {N} = (StaticOneTo(N),)
@inline maybestatic_axes(nt::NamedTuple) = maybestatic_axes(values(nt))
@inline maybestatic_axes(::StaticArrays.Size{tpl}) where {tpl} = (StaticOneTo(length(tpl)),)
@inline maybestatic_axes(::StaticOneToLike{N}) where {N} = (StaticOneTo(N),)
@static if isdefined(StaticArrays, :SUnitRange)
    @inline maybestatic_axes(r::StaticArrays.SUnitRange) = axes(r)
end
@inline maybestatic_axes(r::Static.OptionallyStaticUnitRange) = canonical_axes(axes(r))
@inline maybestatic_axes(r::AbstractUnitRange) = axes(r)
@inline maybestatic_axes(A::AbstractArray) = axes(A)
@inline maybestatic_axes(A::StaticArray) = axes(A)


"""
    StaticThings.axes2size(x::Tuple)
    StaticThings.axes2size(x::StaticArrays.Size)

Get the size of a collection-like object from it's axes.
"""
function axes2size end
export axes2size

@inline axes2size(::Tuple{}) = ()
@inline axes2size(axs::Tuple) = canonical_size(map(maybestatic_length, axs))


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

Returns the the index range of `x` as a dynamic or static integer range
"""
function maybestatic_eachindex end
export maybestatic_eachindex

maybestatic_eachindex(::Tuple{}) = StaticOneTo(0)
maybestatic_eachindex(::Tuple{Vararg{Any,N}}) where {N} = StaticOneTo(N)
maybestatic_eachindex(nt::NamedTuple) = maybestatic_eachindex(values(nt))
maybestatic_eachindex(x::AbstractArray) = canonical_indices(eachindex(x))


"""
    maybestatic_first(A)

Returns the first element of `A` as a dynamic or static value.
"""
function maybestatic_first end
export maybestatic_first

maybestatic_first(tpl::Tuple) = tpl[begin]
maybestatic_first(nt::NamedTuple) = nt[begin]
maybestatic_first(A::AbstractArray) = A[begin]
maybestatic_first(::StaticArrays.Size{tpl}) where {tpl} = static(tpl[begin])
maybestatic_first(::StaticArrays.SOneTo{N}) where {N} = static(1)
@static if isdefined(StaticArrays, :SUnitRange)
    maybestatic_first(::StaticArrays.SUnitRange{B,L}) where {B,L} = static(B)
end
function maybestatic_first(
    ::Static.OptionallyStaticUnitRange{<:Static.StaticInteger{from},<:Static.StaticInteger},
) where {from}
    static(from)
end


"""
    maybestatic_last(A)

Returns the last element of `A` as a dynamic or static value.
"""
function maybestatic_last end
export maybestatic_last

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
    canonical_axes(sz::SizeLike)

Return the canonical representation collection axes.
"""
function canonical_axes end
export canonical_axes

@inline canonical_axes(axs::AxesLike) = map(canonical_indices, axs)


"""
    StaticThings.NoTypeSize(T)

Returned by [`StaticThings.size_from_type(T)`](@ref) if the size of values of type
`T` is not fixed or not known.
"""
struct NoTypeSize{T} end


"""
    size_from_type(::Type{T})::StaticThings.SizeLike

Get the size (equivalent of StaticThings.maybestatic_size) of values of
type `T`.

Requires values of type `T` to have a fixed known size, returns
[`StaticThings.NoTypeSize{T}()`](@ref) otherwise.
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
size_from_type(::Type{AT}) where {AT<:StaticArray} = StaticArrays.Size(T)
