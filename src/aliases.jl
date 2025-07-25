# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

"""
    StaticUnitRange

The StaticThings default type for static unit ranges.

Currently an alias for `StaticArrays.SUnitRange`, if it exists, otherwise
an alias for `Static.SUnitRange`.
"""
const StaticUnitRange = @static if isdefined(StaticArrays, :SUnitRange)
    # Unclear if StaticArrays.SUnitRange is part of StaticArrays stable API.
    # Some packages use it, but let's be careful in case it disappears.
    StaticArrays.SUnitRange
else
    Static.SUnitRange
end
export StaticUnitRange


"""
    const StaticOneTo{T} = StaticArrays.SOneTo{T}

The StaticThings default type for static one-based unit ranges.

Currently an alias for StaticArrays.SOneTo.
"""
const StaticOneTo{T} = StaticArrays.SOneTo{T}
export StaticOneTo


"""
    IntegerLike = Union{Integer,Static.StaticInteger}

Equivalent to `Union{Integer,Static.StaticInteger}`.
"""
const IntegerLike = Union{Integer,Static.StaticInteger}
export IntegerLike


"""
    SizeLike = Union{Tuple{},Tuple{Vararg{IntegerLike}},StaticArrays.Size}

Something that can represent the size of a collection.
"""
const SizeLike = Union{Tuple{},Tuple{Vararg{IntegerLike}},StaticArrays.Size}
export SizeLike


"""
    StaticSizeLike = Union{Tuple{Vararg{StaticInteger}},StaticArrays.Size}

Something that can represent the size of a statically sized collection.
"""
const StaticSizeLike = Union{Tuple{Vararg{StaticInteger}},StaticArrays.Size}
export StaticSizeLike


"""
    AxesLike = Union{Tuple{},Tuple{Vararg{AbstractVector{<:IntegerLike}}}}

Something that can represent axes of a collection.
"""
const AxesLike = Union{Tuple{},Tuple{Vararg{AbstractVector{<:IntegerLike}}}}
export AxesLike


"""
    StaticAxesLike = Tuple{Vararg{Union{StaticArrays.SOneTo,StaticArrays.SUnitRange,Static.SUnitRange}}}

Something that can represent axes of a statically sized collection.
"""
@static if isdefined(StaticArrays, :SUnitRange)
    const StaticAxesLike = Union{
        Tuple{Vararg{Union{StaticArrays.SOneTo,StaticArrays.SUnitRange,Static.SUnitRange}}}
    }
else
    const StaticAxesLike = Union{
        Tuple{Vararg{Union{StaticArrays.SOneTo,Static.SUnitRange}}}
    }
end
export StaticAxesLike


"""
    OneToLike = Union{Base.OneTo,StaticArrays.SOneTo,Static.SOneTo}

Alias for unit ranges that start at one.
"""
const OneToLike = Union{Base.OneTo,StaticArrays.SOneTo,Static.SOneTo}
export OneToLike


"""
    StaticOneToLike{N} = Union{StaticArrays.SOneTo{N},Static.SOneTo{N}}

A static unit range from one to N.
"""
const StaticOneToLike{N} = Union{StaticArrays.SOneTo{N},Static.SOneTo{N}}
export StaticOneToLike


"""
    StaticUnitRangeLike = Union{StaticArrays.SOneTo,StaticArrays.SUnitRange,Static.SUnitRange}

A static unit range.
"""
@static if isdefined(StaticArrays, :SUnitRange)
    const StaticUnitRangeLike =
        Union{StaticArrays.SOneTo,StaticArrays.SUnitRange,Static.SUnitRange}
else
    const StaticUnitRangeLike = Union{StaticArrays.SOneTo,Static.SUnitRange}
end
export StaticUnitRangeLike
