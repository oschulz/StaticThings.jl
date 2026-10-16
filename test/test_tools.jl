# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

using StaticThings
using Test

using StaticThings: NoTypeSize

import FillArrays
using FillArrays: Fill

import Static
using Static: static

import StaticArrays
using StaticArrays: SArray, SVector, SMatrix, MVector, MMatrix, SizedVector, StaticVector


struct TestPoint3 <: StaticArrays.FieldVector{3,Float64}
    x::Float64
    y::Float64
    z::Float64
end


# A minimal vector with non-one-based axes:
struct TestOffsetVector{T} <: AbstractVector{T}
    data::Vector{T}
    offset::Int
end

Base.size(v::TestOffsetVector) = size(v.data)
Base.axes(v::TestOffsetVector) = (v.offset .+ Base.OneTo(length(v.data)),)
Base.getindex(v::TestOffsetVector, i::Int) = v.data[i-v.offset]


@testset "satools" begin
    v = 4.2
    sv = static(4.2)
    T = typeof(v)

    tpl = (7, 42, 5)
    nt = (a = 7, b = 42, c = 5)

    i = 7
    si = static(7)

    @test i isa IntegerLike
    @test si isa IntegerLike
    @test !(v isa IntegerLike)
    @test !(sv isa IntegerLike)

    @test i isa RealLike
    @test si isa RealLike
    @test v isa RealLike
    @test sv isa RealLike

    sz = (2, 4, 3)
    sasz = StaticArrays.Size(2, 4, 3)
    sisz = (static(2), static(4), static(3))

    len = prod(sz)
    slen = static(len)

    @test sz isa SizeLike
    @test sasz isa SizeLike
    @test sisz isa SizeLike

    @test !(sz isa StaticSizeLike)
    @test sasz isa StaticSizeLike
    @test sisz isa StaticSizeLike

    axs = (Base.OneTo(2), 2:5, Base.OneTo(3))
    axs1 = (Base.OneTo(2), Base.OneTo(4), Base.OneTo(3))
    saaxs = (StaticOneTo(2), StaticUnitRange(2, 5), StaticOneTo(3))
    saaxs1 = (StaticOneTo(2), StaticOneTo(4), StaticOneTo(3))
    siaxs = (Static.SOneTo(2), static(2):static(5), static(1):static(3))
    siaxs1 = (Static.SOneTo(2), static(1):static(4), static(1):static(3))

    @test axs isa AxesLike
    @test axs1 isa AxesLike
    @test saaxs isa AxesLike
    @test saaxs1 isa AxesLike
    @test siaxs isa AxesLike
    @test siaxs1 isa AxesLike

    @test !(axs isa StaticAxesLike)
    @test saaxs isa StaticAxesLike
    @test saaxs1 isa StaticAxesLike
    @test siaxs isa StaticAxesLike
    @test siaxs1 isa StaticAxesLike

    @test axs[1] isa OneToLike
    @test !(axs[2] isa OneToLike)
    @test axs[3] isa OneToLike

    @test saaxs[1] isa OneToLike
    @test !(saaxs[2] isa OneToLike)
    @test saaxs1[2] isa OneToLike
    @test saaxs[3] isa OneToLike

    @test siaxs[1] isa OneToLike
    @test !(siaxs[2] isa OneToLike)
    @test siaxs1[2] isa OneToLike
    @test siaxs[3] isa OneToLike

    @test !(axs[1] isa StaticOneToLike)
    @test !(axs[2] isa StaticOneToLike)
    @test !(axs[3] isa StaticOneToLike)

    @test saaxs[1] isa StaticOneToLike
    @test !(saaxs[2] isa StaticOneToLike)
    @test saaxs1[2] isa StaticOneToLike
    @test saaxs[3] isa StaticOneToLike

    @test siaxs[1] isa StaticOneToLike
    @test !(siaxs[2] isa StaticOneToLike)
    @test siaxs1[2] isa StaticOneToLike
    @test siaxs[3] isa StaticOneToLike

    @test !(axs[1] isa StaticUnitRangeLike)
    @test !(axs[2] isa StaticUnitRangeLike)
    @test !(axs[3] isa StaticUnitRangeLike)

    @test saaxs[1] isa StaticUnitRangeLike
    @test saaxs[2] isa StaticUnitRangeLike
    @test saaxs1[2] isa StaticUnitRangeLike
    @test saaxs[3] isa StaticUnitRangeLike

    @test siaxs[1] isa StaticUnitRangeLike
    @test siaxs[2] isa StaticUnitRangeLike
    @test siaxs1[2] isa StaticUnitRangeLike
    @test siaxs[3] isa StaticUnitRangeLike

    @test @inferred(maybestatic_oneto(i)) == Base.OneTo(i)
    @test @inferred(maybestatic_oneto(si)) == StaticOneTo(i)

    @test @inferred(asnonstatic(())) === ()
    @test @inferred(asnonstatic(i)) === i
    @test @inferred(asnonstatic(si)) === i
    @test @inferred(asnonstatic(sz)) === sz
    @test @inferred(asnonstatic(sasz)) === sz
    @test @inferred(asnonstatic(sisz)) === sz
    @test @inferred(asnonstatic(axs)) === axs
    @test @inferred(asnonstatic(saaxs)) === axs
    @test @inferred(asnonstatic(saaxs1)) === (Base.OneTo(2), Base.OneTo(4), Base.OneTo(3))
    @test @inferred(asnonstatic(siaxs)) === axs
    @test @inferred(asnonstatic(siaxs1)) === (Base.OneTo(2), Base.OneTo(4), Base.OneTo(3))
    @test @inferred(asnonstatic(sv)) === v

    # Empty ranges have no elements to take the bounds from:
    @test @inferred(asnonstatic(3:2)) === 3:2
    @test @inferred(asnonstatic(static(3):static(2))) === 3:2
    @test @inferred(asnonstatic(StaticUnitRange(3, 2))) === 3:2
    @test @inferred(maybestatic_fill(v, (3:2,))) == Fill(v, (3:2,))

    @test @inferred(maybestatic_fill(v, i)) === Fill(v, i)
    @test @inferred(maybestatic_fill(v, si)) === SVector(fill(v, i)...)
    @test @inferred(maybestatic_fill(v, ())) === SArray{Tuple{},T,0,1}(v)

    @test @inferred(maybestatic_fill(v, sz)) === Fill(v, sz)
    @test @inferred(maybestatic_fill(v, sasz)) === SArray{Tuple{sz...},T}(fill(v, sz))
    @test @inferred(maybestatic_fill(v, sisz)) === SArray{Tuple{sz...},T}(fill(v, sz))

    @test @inferred(maybestatic_fill(v, axs)) === Fill(v, axs)
    @test @inferred(maybestatic_fill(v, saaxs)) === Fill(v, axs)
    @test @inferred(maybestatic_fill(v, saaxs1)) === SArray{Tuple{sz...},T}(fill(v, sz))
    @test @inferred(maybestatic_fill(v, siaxs)) === Fill(v, axs)
    @test @inferred(maybestatic_fill(v, siaxs1)) === SArray{Tuple{sz...},T}(fill(v, sz))
    @test @inferred(maybestatic_fill(v, StaticArrays.Size())) === SArray{Tuple{},T,0,1}(v)

    @test @inferred(staticarray_type(T, sasz)) <: SArray{Tuple{2,4,3},T}
    @test @inferred(staticarray_type(T, StaticArrays.Size(3))) === SVector{3,T}

    A = rand(T, len)
    FA = Fill(v, len)
    SA = SVector(A...)

    # Array with CartesianIndices
    ciA = view(rand(5, 6, 6), 3:4, 2:5, 3:5)
    ciidxs = eachindex(ciA)

    rshpA = reshape(A, sz)
    rshpFA = Fill(v, sz)
    rshpSA = SArray{Tuple{sz...},T}(A)

    # Only static arrays become static arrays, other arrays reshape as
    # `reshape` does:
    @test @inferred(maybestatic_reshape(A, sz)) == rshpA
    @test typeof(maybestatic_reshape(A, sz)) == typeof(rshpA)
    @test @inferred(maybestatic_reshape(A, sasz)) == rshpA
    @test typeof(maybestatic_reshape(A, sasz)) == typeof(rshpA)
    @test @inferred(maybestatic_reshape(A, sisz)) == rshpA
    @test typeof(maybestatic_reshape(A, sisz)) == typeof(rshpA)

    @test @inferred(maybestatic_reshape(FA, sz)) == rshpFA
    @test typeof(maybestatic_reshape(FA, sz)) == typeof(rshpFA)
    @test @inferred(maybestatic_reshape(FA, sasz)) == rshpFA
    @test typeof(maybestatic_reshape(FA, sasz)) == typeof(rshpFA)
    @test @inferred(maybestatic_reshape(FA, sisz)) == rshpFA
    @test typeof(maybestatic_reshape(FA, sisz)) == typeof(rshpFA)

    @test @inferred(maybestatic_reshape(SA, sz)) == rshpA
    @test maybestatic_reshape(SA, sz) isa Base.ReshapedArray{T,3,<:SVector}
    @test @inferred(maybestatic_reshape(SA, sasz)) === rshpSA
    @test @inferred(maybestatic_reshape(SA, sisz)) === rshpSA

    # Reshaping a mutable static array shares its memory:
    for MA in (MVector{len}(A), SizedVector{len}(copy(A)))
        R = maybestatic_reshape(MA, sasz)
        MA[begin] = -v
        @test R[begin, begin, begin] == -v
    end

    @test @inferred(maybestatic_reshape(SVector(v), ())) === SArray{Tuple{},T,0,1}(v)
    @test @inferred(maybestatic_reshape([v], ())) == fill(v)
    @test typeof(maybestatic_reshape([v], ())) == typeof(fill(v))

    @test @inferred(size_tuple(sz)) === sz
    @test @inferred(size_tuple(sasz)) === sisz
    @test @inferred(size_tuple(sisz)) === sisz
    @test @inferred(size_tuple(())) === ()
    @test @inferred(canonical_size(size_tuple(sasz))) === sasz

    # The zero-dimensional size is `()`, with or without a `Size` around it:
    @test @inferred(canonical_size(())) === ()
    @test @inferred(canonical_size(StaticArrays.Size())) === ()
    @test @inferred(canonical_size((Int8(2), static(3)))) === (2, static(3))
    @test @inferred(maybestatic_size(SArray{Tuple{},T,0,1}(v))) === ()
    @test @inferred(staticarray_type(T, ())) === SArray{Tuple{},T,0,1}
    @test @inferred(maybestatic_fill(v, ())) === SArray{Tuple{},T,0,1}(v)
    for s in ((), StaticArrays.Size(), sz, sasz, sisz, (static(2), 3), (Int8(2), UInt8(3)))
        @test canonical_size(size_tuple(s)) === canonical_size(s)
        @test axes2size(size2axes(s)) === canonical_size(s)
    end

    @test @inferred(maybestatic_length(5)) === static(1)
    @test @inferred(maybestatic_length(())) === static(0)
    @test @inferred(maybestatic_length((sz))) === static(3)
    @test @inferred(maybestatic_length((a = 2, b = 4, c = 3))) === static(3)
    @test @inferred(maybestatic_length(Base.OneTo(4))) === 4
    @test @inferred(maybestatic_length(StaticArrays.SOneTo(4))) === static(4)
    @test @inferred(maybestatic_length(Static.SOneTo(4))) === static(4)
    @test @inferred(maybestatic_length(static(2):static(5))) === static(4)
    @test @inferred(maybestatic_length(StaticUnitRange(2, 5))) === static(4)
    @test @inferred(maybestatic_length(static(3):static(1))) === static(0)
    @test @inferred(maybestatic_length(3:1)) === 0
    @test @inferred(maybestatic_length(Int8(-100):Int8(100))) === 201
    @test @inferred(maybestatic_length(static(1):static(-2))) === static(0)
    @test @inferred(canonical_indices(static(1):static(-2))) === StaticOneTo(0)
    @test @inferred(maybestatic_length(canonical_indices(static(typemax(Int)):static(typemin(Int))))) ===
          static(0)
    @test @inferred(maybestatic_length(rshpA)) === length(rshpA)
    @test @inferred(maybestatic_length(rshpFA)) === length(rshpA)
    @test @inferred(maybestatic_length(rshpSA)) === static(length(rshpA))

    @test @inferred(maybestatic_size(5)) === ()
    @test @inferred(maybestatic_size(())) === StaticArrays.Size(0)
    @test @inferred(maybestatic_size((sz))) === StaticArrays.Size(3)
    @test @inferred(maybestatic_size((sasz))) === StaticArrays.Size(3)
    @test @inferred(maybestatic_size((sisz))) === StaticArrays.Size(3)
    @test @inferred(maybestatic_size((a = 2, b = 4, c = 3))) === StaticArrays.Size(3)
    @test @inferred(maybestatic_size(Base.OneTo(4))) === (4,)
    @test @inferred(maybestatic_size(StaticArrays.SOneTo(4))) === StaticArrays.Size(4)
    @test @inferred(maybestatic_size(StaticUnitRange(2, 5))) === StaticArrays.Size(4)
    @test @inferred(maybestatic_size(Static.SOneTo(4))) === StaticArrays.Size(4)
    @test @inferred(maybestatic_size(static(2):static(5))) === StaticArrays.Size(4)
    @test @inferred(maybestatic_size(rshpA)) === size(rshpA)
    @test @inferred(maybestatic_size(rshpFA)) === size(rshpA)
    @test @inferred(maybestatic_size(rshpSA)) === StaticArrays.Size(size(rshpA)...)

    @test @inferred(maybestatic_axes(5)) === ()
    @test @inferred(maybestatic_axes(())) === (StaticOneTo(0),)
    @test @inferred(maybestatic_axes((sz))) === (StaticOneTo(3),)
    @test @inferred(maybestatic_axes((sasz))) === (StaticOneTo(3),)
    @test @inferred(maybestatic_axes((sisz))) === (StaticOneTo(3),)
    @test @inferred(maybestatic_axes((a = 2, b = 4, c = 3))) === (StaticOneTo(3),)
    @test @inferred(maybestatic_axes(Base.OneTo(4))) === (Base.OneTo(4),)
    @test @inferred(maybestatic_axes(StaticArrays.SOneTo(4))) === (StaticOneTo(4),)
    @test @inferred(maybestatic_axes(StaticUnitRange(2, 5))) === (StaticOneTo(4),)
    @test @inferred(maybestatic_axes(Static.SOneTo(4))) === (StaticOneTo(4),)
    @test @inferred(maybestatic_axes(static(2):static(5))) === (StaticOneTo(4),)
    @test @inferred(maybestatic_axes(rshpA)) === axes(rshpA)
    @test @inferred(maybestatic_axes(rshpFA)) === axes(rshpA)
    @test @inferred(maybestatic_axes(rshpSA)) === saaxs1

    @test @inferred(axes2size(())) === ()
    @test @inferred(axes2size(axs)) === sz
    @test @inferred(axes2size(saaxs)) === sasz
    @test @inferred(axes2size(saaxs1)) === sasz
    @test @inferred(axes2size(siaxs)) === sasz
    @test @inferred(axes2size(siaxs1)) === sasz

    @test @inferred(size2axes(())) === ()
    @test @inferred(size2axes(sz)) === axs1
    @test @inferred(size2axes(sasz)) === saaxs1
    @test @inferred(size2axes(sisz)) === saaxs1

    @test @inferred(size2length(())) === static(1)
    @test @inferred(size2length(sz)) === len
    @test @inferred(size2length(sasz)) === slen
    @test @inferred(size2length(sisz)) === slen

    @test @inferred(asaxes(())) === ()
    @test @inferred(asaxes(len)) === (Base.OneTo(len),)
    @test @inferred(asaxes(slen)) === (StaticOneTo(len),)
    @test @inferred(asaxes(sz)) === axs1
    @test @inferred(asaxes(sasz)) === saaxs1
    @test @inferred(asaxes(sisz)) === saaxs1
    @test @inferred(asaxes(axs)) === axs
    @test @inferred(asaxes(axs1)) === axs1
    @test @inferred(asaxes(saaxs)) === saaxs
    @test @inferred(asaxes(saaxs1)) === saaxs1
    @test @inferred(asaxes(siaxs)) === siaxs
    @test @inferred(asaxes(siaxs1)) === siaxs1

    @test @inferred(maybestatic_eachindex(v)) === StaticOneTo(1)
    @test @inferred(maybestatic_eachindex(())) === StaticOneTo(0)
    @test @inferred(maybestatic_eachindex(tpl)) === StaticOneTo(3)
    @test @inferred(maybestatic_eachindex(nt)) === StaticOneTo(3)
    @test @inferred(maybestatic_eachindex(sasz)) === StaticOneTo(3)
    @test @inferred(maybestatic_eachindex(axs[1])) === Base.OneTo(length(axs[1]))
    @test @inferred(maybestatic_eachindex(axs[2])) === Base.OneTo(length(axs[2]))
    @test @inferred(maybestatic_eachindex(saaxs[1])) === StaticOneTo(length(axs[1]))
    @test @inferred(maybestatic_eachindex(saaxs[2])) === StaticOneTo(length(axs[2]))
    @test @inferred(maybestatic_eachindex(siaxs[1])) === StaticOneTo(length(axs[1]))
    @test @inferred(maybestatic_eachindex(siaxs[2])) === StaticOneTo(length(axs[2]))
    @test @inferred(maybestatic_eachindex(A)) === Base.OneTo(24)
    @test @inferred(maybestatic_eachindex(ciA)) === eachindex(ciA)
    @test @inferred(maybestatic_eachindex(FA)) === Base.OneTo(24)
    @test @inferred(maybestatic_eachindex(SA)) === StaticOneTo(24)

    @test_throws BoundsError maybestatic_first(())
    @test @inferred(maybestatic_first(v)) === v
    @test @inferred(maybestatic_first(sv)) === sv
    @test @inferred(maybestatic_first(static(2):5)) === static(2)
    @test @inferred(maybestatic_first(tpl)) === first(tpl)
    @test @inferred(maybestatic_first(nt)) === first(nt)
    @test @inferred(maybestatic_first(sz)) === first(sz)
    @test @inferred(maybestatic_first(sasz)) === static(first(sz))
    @test @inferred(maybestatic_first(sisz)) === static(first(sz))
    @test @inferred(maybestatic_first(axs[1])) === static(first(axs[1]))
    @test @inferred(maybestatic_first(axs[2])) === first(axs[2])
    @test @inferred(maybestatic_first(saaxs[1])) === static(first(axs[1]))
    @test @inferred(maybestatic_first(saaxs[2])) === static(first(axs[2]))
    @test @inferred(maybestatic_first(siaxs[1])) === static(first(axs[1]))
    @test @inferred(maybestatic_first(siaxs[2])) === static(first(axs[2]))
    @test @inferred(maybestatic_first(A)) === first(A)
    @test @inferred(maybestatic_first(ciA)) === first(ciA)
    @test @inferred(maybestatic_first(FA)) === first(FA)
    @test @inferred(maybestatic_first(SA)) === first(SA)
    @test @inferred(maybestatic_first(3:1)) === 3
    @test @inferred(maybestatic_first(Base.OneTo(0))) === static(1)

    @test_throws BoundsError maybestatic_last(())
    @test @inferred(maybestatic_last(v)) === v
    @test @inferred(maybestatic_last(sv)) === sv
    @test @inferred(maybestatic_last(2:static(5))) === static(5)
    @test @inferred(maybestatic_last(tpl)) === last(tpl)
    @test @inferred(maybestatic_last(nt)) === last(nt)
    @test @inferred(maybestatic_last(sz)) === last(sz)
    @test @inferred(maybestatic_last(sasz)) === static(last(sz))
    @test @inferred(maybestatic_last(sisz)) === static(last(sz))
    @test @inferred(maybestatic_last(3:1)) === 2
    @test @inferred(maybestatic_last(Base.OneTo(0))) === 0
    @test @inferred(maybestatic_last(axs[1])) === last(axs[1])
    @test @inferred(maybestatic_last(axs[2])) === last(axs[2])
    @test @inferred(maybestatic_last(saaxs[1])) === static(last(axs[1]))
    @test @inferred(maybestatic_last(saaxs[2])) === static(last(axs[2]))
    @test @inferred(maybestatic_last(siaxs[1])) === static(last(axs[1]))
    @test @inferred(maybestatic_last(siaxs[2])) === static(last(axs[2]))
    @test @inferred(maybestatic_last(A)) === last(A)
    @test @inferred(maybestatic_last(ciA)) === last(ciA)
    @test @inferred(maybestatic_last(FA)) === last(FA)
    @test @inferred(maybestatic_last(SA)) === last(SA)

    @test @inferred(canonical_indices(axs[1])) === axs[1]
    @test @inferred(canonical_indices(axs[2])) === axs[2]
    @test @inferred(canonical_indices(saaxs[1])) === saaxs[1]
    @test @inferred(canonical_indices(saaxs[2])) === saaxs[2]
    @test @inferred(canonical_indices(siaxs[1])) === saaxs[1]
    @test @inferred(canonical_indices(siaxs[2])) === saaxs[2]
    @test @inferred(canonical_indices(static(1):len)) === Base.OneTo(len)
    @test @inferred(canonical_indices(ciidxs)) === ciidxs

    @test @inferred(canonical_size(sz)) === sz
    @test @inferred(canonical_size(sasz)) === sasz
    @test @inferred(canonical_size(sisz)) === sasz

    @test @inferred(canonical_axes(axs)) === axs
    @test @inferred(canonical_axes(axs1)) === axs1
    @test @inferred(canonical_axes(saaxs)) === saaxs
    @test @inferred(canonical_axes(saaxs1)) === saaxs1
    @test @inferred(canonical_axes(siaxs)) === saaxs
    @test @inferred(canonical_axes(siaxs1)) === saaxs1

    @test @inferred(size_from_type(typeof(i))) === maybestatic_size(i)
    @test @inferred(size_from_type(typeof(()))) === maybestatic_size(())
    @test @inferred(size_from_type(typeof(tpl))) === maybestatic_size(tpl)
    @test @inferred(size_from_type(typeof(nt))) === maybestatic_size(nt)
    @test @inferred(size_from_type(typeof(sz))) === maybestatic_size(sz)
    @test @inferred(size_from_type(typeof(sasz))) === maybestatic_size(sasz)
    @test @inferred(size_from_type(typeof(axs))) === maybestatic_size(axs)
    @test @inferred(size_from_type(typeof(axs1))) === maybestatic_size(axs1)
    @test @inferred(size_from_type(typeof(saaxs))) === maybestatic_size(saaxs)
    @test @inferred(size_from_type(typeof(saaxs1))) === maybestatic_size(saaxs1)
    @test @inferred(size_from_type(typeof(siaxs))) === maybestatic_size(siaxs)
    @test @inferred(size_from_type(typeof(sisz))) === maybestatic_size(sisz)
    @test @inferred(size_from_type(typeof(SA))) === maybestatic_size(SA)
    @test @inferred(size_from_type(typeof(rshpSA))) === maybestatic_size(rshpSA)
    @test @inferred(size_from_type(SArray{Tuple{},T,0,1})) === ()
    @test @inferred(size_from_type(typeof(SA'))) === StaticArrays.Size(1, len)
    @test @inferred(size_from_type(typeof(view(rshpSA, :, 1, 1)))) === StaticArrays.Size(2)
    @test @inferred(size_from_type(SVector)) === NoTypeSize{SVector}()
    @test @inferred(size_from_type(eltype(A))) === maybestatic_size(A[1])
    @test @inferred(size_from_type(typeof(A))) === NoTypeSize{typeof(A)}()
    @test @inferred(size_from_type(String)) === NoTypeSize{String}()
end


@testset "static type reductions" begin
    @test @inferred(tuple_type_all(T -> T <: Integer, Tuple{})) === static(true)
    @test @inferred(tuple_type_all(T -> T <: Integer, Tuple{Int,Bool})) === static(true)
    @test @inferred(tuple_type_all(T -> T <: Integer, Tuple{Int,Float64})) === static(false)
    @test @inferred(tuple_type_all(T -> static(T <: Integer), Tuple{Int,Bool})) === static(true)

    @test @inferred(tuple_type_any(T -> T <: Integer, Tuple{})) === static(false)
    @test @inferred(tuple_type_any(T -> T <: Integer, Tuple{Float64,Bool})) === static(true)
    @test @inferred(tuple_type_any(T -> T <: Integer, Tuple{Float64,String})) === static(false)

    @test @inferred(tuple_type_mapreduce(sizeof, +, Tuple{Int32,Int64,Int16})) === 14
    @test @inferred(tuple_type_reduce(promote_type, Tuple{Int,Float32})) === Float32
    @test @inferred(tuple_type_reduce(promote_type, Tuple{Int})) === Int
    @test @inferred(tuple_type_mapreduce(T -> static(T <: Integer), &, Tuple{Int,Bool})) ===
          static(true)
    @test_throws ArgumentError tuple_type_reduce(+, Tuple{})
    @test_throws ArgumentError tuple_type_mapreduce(sizeof, +, Tuple{})

    # Folding needs a fixed length, so `Vararg` tuple types are out:
    @test_throws MethodError tuple_type_all(T -> T <: Integer, Tuple{Vararg{Int}})
    @test_throws MethodError tuple_type_any(T -> T <: Integer, Tuple{Int,Vararg{Int}})
    @test_throws MethodError tuple_type_mapreduce(sizeof, +, Tuple)
    @test_throws MethodError tuple_type_reduce(promote_type, Tuple{Vararg{Int}})

    # Fixed-length tuple types that share a type parameter:
    TU = Tuple{Vector{S},Vector{S}} where S
    @test tuple_type_mapreduce(_ -> 1, +, TU) === 2
    @test tuple_type_all(T -> T <: AbstractVector, TU) === static(true)
    joined = tuple_type_reduce(typejoin, TU)
    @test joined <: Vector && Vector <: joined

    # The results must be constants, not just inferred:
    f_all() = tuple_type_all(T -> T <: Integer, Tuple{Int,Bool,Float64})
    f_any() = tuple_type_any(T -> T <: Integer, Tuple{Float64,Bool})
    f_red() = tuple_type_mapreduce(T -> static(sizeof(T)), +, Tuple{Int32,Int64})
    @test @inferred(Static.False, f_all()) === static(false)
    @test @inferred(Static.True, f_any()) === static(true)
    @test @inferred(Static.StaticInt{12}, f_red()) === static(12)
end


@testset "leading dimensions" begin
    A = rand(2, 3, 4)
    SA = SArray{Tuple{2,3,4}}(A)

    @test @inferred(sum_leading_dims(4.2, static(0))) === 4.2
    @test_throws DimensionMismatch sum_leading_dims(4.2, static(1))

    @test @inferred(sum_leading_dims(A, static(0))) === A
    @test @inferred(sum_leading_dims(A, static(1))) ≈ dropdims(sum(A, dims = 1), dims = 1)
    @test @inferred(sum_leading_dims(A, static(2))) ≈
          dropdims(sum(A, dims = (1, 2)), dims = (1, 2))
    @test @inferred(sum_leading_dims(A, static(3))) ≈ sum(A)

    @test @inferred(sum_leading_dims(SA, static(1))) isa SArray{Tuple{3,4}}
    @test @inferred(sum_leading_dims(SA, static(1))) ≈ sum_leading_dims(A, static(1))
    @test @inferred(sum_leading_dims(SA, static(3))) ≈ sum(A)

    bc = Broadcast.instantiate(Broadcast.broadcasted(+, A, 1))
    @test @inferred(sum_leading_dims(bc, static(3))) ≈ sum(A .+ 1)
    @test @inferred(sum_leading_dims(bc, static(1))) ≈ sum_leading_dims(A .+ 1, static(1))
    sbc = Broadcast.instantiate(Broadcast.broadcasted(+, SA, 1))
    @test @inferred(sum_leading_dims(sbc, static(3))) ≈ sum(A .+ 1)

    @test @inferred(drop_leading_dims(reshape(A, 1, 1, 2, 3, 4), static(2))) == A
    @test @inferred(drop_leading_dims(SArray{Tuple{1,3,4}}(A[1:1, :, :]), static(1))) isa
          SArray{Tuple{3,4}}
    @test_throws DimensionMismatch drop_leading_dims(A, static(4))

    @test @inferred(merge_leading_dims(A, static(0))) == reshape(A, 1, 2, 3, 4)
    @test @inferred(merge_leading_dims(A, static(2))) == reshape(A, 6, 4)
    @test @inferred(merge_leading_dims(SA, static(2))) isa SArray{Tuple{6,4}}
    @test @inferred(merge_leading_dims(SA, static(0))) isa SArray{Tuple{1,2,3,4}}
    @test @inferred(merge_leading_dims(A, static(3))) == reshape(A, 24)

    B = A .> 0.5
    SB = SA .> 0.5
    @test @inferred(all_leading_dims(B, static(3))) === all(B)
    @test @inferred(all_leading_dims(B, static(1))) ==
          dropdims(all(B, dims = 1), dims = 1)
    @test @inferred(all_leading_dims(SB, static(1))) isa SArray{Tuple{3,4},Bool}
    @test all_leading_dims(SB, static(1)) == all_leading_dims(B, static(1))
    @test @inferred(all_leading_dims(SB, static(3))) === all(B)
    @test @inferred(all_leading_dims(B, static(2))) ==
          dropdims(all(B, dims = (1, 2)), dims = (1, 2))

    @test @inferred(all_leading_dims(B, static(0))) === B
    @test @inferred(all_leading_dims(fill(true), static(0))) === true
    @test @inferred(sum_leading_dims(fill(4.2), static(0))) === 4.2
    @test @inferred(sum_leading_dims(bc, static(0))) === bc
    for f in (sum_leading_dims, drop_leading_dims, merge_leading_dims), n in (-1, 4)
        @test_throws DimensionMismatch f(A, static(n))
        @test_throws DimensionMismatch f(SA, static(n))
    end
    for n in (-1, 4)
        @test_throws DimensionMismatch all_leading_dims(B, static(n))
        @test_throws DimensionMismatch all_leading_dims(SB, static(n))
        @test_throws DimensionMismatch sum_leading_dims(bc, static(n))
    end

    # Only dimensions of size one can be dropped, even if the length allows it:
    @test_throws ArgumentError drop_leading_dims(zeros(2, 0), static(1))
    @test_throws ArgumentError drop_leading_dims(SArray{Tuple{2,0},Float64}(), static(1))

    @test @inferred(sum_leading_dims(zeros(0, 3), static(1))) == zeros(3)

    # Reducing an empty dimension gives the reduction of nothing, and a
    # static reduction with an empty result needs its element type from
    # elsewhere:
    @test @inferred(sum_leading_dims(SArray{Tuple{0,0,3},Float64}(), static(2))) ===
          SVector(0.0, 0.0, 0.0)
    @test @inferred(all_leading_dims(SArray{Tuple{0,0,3},Bool}(), static(2))) ===
          SVector(true, true, true)
    @test @inferred(all_leading_dims(SMatrix{2,0,Bool}(), static(1))) === SVector{0,Bool}()
    @test @inferred(sum_leading_dims(SArray{Tuple{0,2,3},Float64}(), static(1))) ==
          sum_leading_dims(zeros(0, 2, 3), static(1))

    # `sum` and `all` share their machinery with other reductions to values
    # that take a `dims` keyword, so it must reduce the elements of `A`, not
    # the results of the reduction itself:
    reduce_dims(red, A, n) = StaticThings._reduce_leading_dims(red, A, n, StaticThings._NoInit())
    E = reshape([1, 100, 2, 3, 4, 40, 5, 6], 2, 2, 2)
    SE = SArray{Tuple{2,2,2}}(E)
    @test reduce_dims(extrema, SE, static(2)) == reduce_dims(extrema, E, static(2))
    @test reduce_dims(maximum, SMatrix{2,0,Float64}(), static(1)) ==
          reduce_dims(maximum, zeros(2, 0), static(1))
    # Reducing nothing without an identity fails. StaticArrays and Base
    # disagree on the exception type before Julia 1.11:
    @test_throws Exception reduce_dims(maximum, SMatrix{0,3,Float64}(), static(1))
    @test_throws ArgumentError reduce_dims(maximum, zeros(0, 3), static(1))
    @test @inferred(sum_leading_dims(Fill(2.0, 2, 3), static(1))) == fill(4.0, 3)
    bc0 = Broadcast.instantiate(Broadcast.broadcasted(+, zeros(0, 3), 1))
    @test @inferred(sum_leading_dims(bc0, static(2))) === 0.0

    # An `init` goes to `sum`, for lazy broadcasts too:
    @test @inferred(sum_leading_dims(A, static(1); init = 0.5)) ≈
          dropdims(sum(A, dims = 1), dims = 1) .+ 0.5
    @test @inferred(sum_leading_dims(A, static(3); init = 0.5)) ≈ sum(A) + 0.5
    @test @inferred(sum_leading_dims(SA, static(1); init = 0.5)) ≈
          sum_leading_dims(A, static(1); init = 0.5)
    @test @inferred(sum_leading_dims(bc, static(3); init = 0.5)) ≈ sum(A .+ 1) + 0.5
    @test @inferred(sum_leading_dims(bc0, static(2); init = 0.5)) === 0.5
    bc_any = Broadcast.instantiate(Broadcast.broadcasted(identity, Any[]))
    @test sum_leading_dims(bc_any, static(1); init = 0.0) === 0.0
    # StaticArrays ignores an `init` over an empty dimension. The result
    # must still be the reduction of nothing with it:
    @test @inferred(sum_leading_dims(SMatrix{0,3,Int}(), static(1); init = 0.5)) ===
          SVector(0.5, 0.5, 0.5)
    @test sum_leading_dims(SMatrix{0,3,Any}(), static(1); init = 0.5) == [0.5, 0.5, 0.5]
end


@testset "vector splitting" begin
    A = rand(6)
    SA = SVector{6}(A)
    tpl = Tuple(A)

    @test @inferred(maybestatic_view(A, 2, 4)) == A[2:4]
    @test @inferred(maybestatic_view(A, 2, 4)) isa SubArray
    @test @inferred(maybestatic_view(SA, static(2), static(4))) === SVector{3}(A[2:4])
    @test @inferred(maybestatic_view(tpl, static(2), static(4))) === Tuple(A[2:4])

    @test @inferred(maybestatic_view(A, 2:4)) == A[2:4]
    @test @inferred(maybestatic_view(SA, StaticOneTo(4))) === SVector{4}(A[1:4])
    @test @inferred(maybestatic_view(tpl, static(2):static(4))) === Tuple(A[2:4])

    a, b = @inferred maybestatic_split(A, 2)
    @test a == A[1:2] && b == A[3:6]
    sa, sb = @inferred maybestatic_split(SA, static(2))
    @test sa === SVector{2}(A[1:2]) && sb === SVector{4}(A[3:6])
    sa0, sb0 = @inferred maybestatic_split(SA, static(0))
    @test sa0 === SVector{0,Float64}() && sb0 === SA
    sa6, sb6 = @inferred maybestatic_split(SA, static(6))
    @test sa6 === SA && sb6 === SVector{0,Float64}()
    ta, tb = @inferred maybestatic_split(tpl, static(2))
    @test ta === tpl[1:2] && tb === tpl[3:6]
    @test maybestatic_split(A, 0) == (A[1:0], A)
    for n in (-1, 7)
        @test_throws ArgumentError maybestatic_split(A, n)
        @test_throws ArgumentError maybestatic_split(SA, static(n))
        @test_throws ArgumentError maybestatic_split(tpl, static(n))
    end

    # Empty ranges:
    @test @inferred(maybestatic_view(A, 3:2)) == Float64[]
    @test @inferred(maybestatic_view(A, 5, 2)) == Float64[]
    @test @inferred(maybestatic_view(SA, static(3):static(2))) === SVector{0,Float64}()
    @test @inferred(maybestatic_view(SA, static(5), static(2))) === SVector{0,Float64}()
    @test @inferred(maybestatic_view(tpl, static(5), static(2))) === ()
    # Extreme endpoints must neither overflow into a non-empty length nor
    # wrap around into an empty one:
    @test @inferred(maybestatic_view(tpl, static(typemax(Int)), static(typemin(Int)))) === ()
    @test @inferred(maybestatic_view(SA, static(typemax(Int)), static(typemin(Int)))) ===
          SVector{0,Float64}()
    @test_throws BoundsError maybestatic_view(tpl, static(typemin(Int)), static(typemax(Int)))
    @test_throws BoundsError maybestatic_view(tpl, typemin(Int), typemax(Int))
    @test_throws BoundsError maybestatic_view(SA, static(typemin(Int)), static(typemax(Int)))
    @test_throws BoundsError maybestatic_view(MVector{6}(A), static(typemin(Int)), static(typemax(Int)))

    # A zero-dimensional array has no first dimension to view along:
    @test_throws DimensionMismatch maybestatic_view(fill(42), 1:1)
    @test_throws DimensionMismatch maybestatic_split(fill(42), 0)
    @test_throws DimensionMismatch maybestatic_split(SArray{Tuple{},Int,0,1}(42), static(0))
    narrow_first, narrow_rest = maybestatic_split(Int8(-100):Int8(100), 1)
    @test collect(narrow_first) == [Int8(-100)] && length(narrow_rest) == 200

    # Arrays are viewed and split along their first dimension:
    M = reshape(collect(1.0:6.0), 3, 2)
    SM = SMatrix{3,2}(M)
    @test @inferred(maybestatic_view(M, 1, 2)) == M[1:2, :]
    @test @inferred(maybestatic_view(SM, static(1), static(2))) === SMatrix{2,2}(M[1:2, :])
    @test @inferred(maybestatic_view(SM, static(3), static(1))) === SMatrix{0,2,Float64}()
    ma, mb = @inferred maybestatic_split(M, 2)
    @test ma == M[1:2, :] && mb == M[3:3, :]
    sma, smb = @inferred maybestatic_split(SM, static(1))
    @test sma === SMatrix{1,2}(M[1:1, :]) && smb === SMatrix{2,2}(M[2:3, :])
    @test_throws ArgumentError maybestatic_split(M, 4)
    MM = MMatrix{3,2}(M)
    mma, _ = @inferred maybestatic_split(MM, static(1))
    MM[1, 1] = 42
    @test mma[1, 1] == 42

    # Index types other than `Int` work:
    WideInt = sizeof(Int) == 4 ? Int64 : Int128
    for I in (Int32, WideInt, BigInt)
        @test maybestatic_view((1, 2, 3), I(1), I(2)) === (1, 2)
        @test maybestatic_split((1, 2, 3), I(1)) === ((1,), (2, 3))
    end

    # Unsigned indices must not wrap around on an empty range, and unsigned
    # counts must not promote negative indices:
    @test maybestatic_view((1, 2, 3), UInt(1), UInt(2)) === (1, 2)
    @test maybestatic_view((1, 2, 3), UInt(3), UInt(1)) === ()
    ov = TestOffsetVector([10, 20, 30], -2)
    @test axes(ov) == (-1:1,)
    for n in (1, UInt(1))
        first_part, rest = maybestatic_split(ov, n)
        @test collect(first_part) == [10] && collect(rest) == [20, 30]
    end

    @test @inferred(maybestatic_view(SA, StaticUnitRange(2, 4))) === SVector{3}(A[2:4])
    @test @inferred(maybestatic_view(tpl, StaticUnitRange(2, 4))) === Tuple(A[2:4])

    # Immutable static vectors give static vectors:
    @test @inferred(maybestatic_view(TestPoint3(1, 2, 3), static(2), static(3))) ===
          SVector(2.0, 3.0)
    @test @inferred(maybestatic_view(StaticUnitRange(3, 8), static(2), static(3))) === SVector(4, 5)

    # Views of mutable static vectors share their memory:
    for MA in (MVector{6}(A), SizedVector{6}(copy(A)))
        va = @inferred maybestatic_view(MA, static(2), static(4))
        @test va isa StaticVector{3}
        ma, mb = @inferred maybestatic_split(MA, static(2))
        @test ma isa StaticVector{2} && mb isa StaticVector{4}
        MA[2] = 42
        @test va[1] == 42 && ma[2] == 42
    end
end


@testset "type-level axes2size" begin
    @test @inferred(axes2size(Tuple{})) === ()
    @test @inferred(axes2size(typeof((StaticOneTo(2), StaticOneTo(3))))) ===
          StaticArrays.Size(2, 3)
    @test @inferred(axes2size(typeof((Static.SOneTo(2), StaticOneTo(3))))) ===
          StaticArrays.Size(2, 3)
    @test @inferred(axes2size(typeof((StaticOneTo(2),)))) === StaticArrays.Size(2)
    @test_throws MethodError axes2size(Tuple{Vararg{StaticOneTo{2}}})

    for axs in (
        (),
        (StaticUnitRange(2, 4), static(0):static(1), StaticOneTo(2)),
        (static(3):static(2), StaticUnitRange(3, 2)),
        (static(1):static(-2),),
    )
        @test @inferred(axes2size(typeof(axs))) === axes2size(axs)
    end
end
