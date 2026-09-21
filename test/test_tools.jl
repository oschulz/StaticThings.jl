# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

using StaticThings
using Test

using StaticThings: NoTypeSize

import FillArrays
using FillArrays: Fill

import Static
using Static: static

import StaticArrays
using StaticArrays: SArray, SVector


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

    # Only static arrays become static arrays, other arrays keep their type:
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

    @test @inferred(maybestatic_reshape(SVector(v), ())) === SArray{Tuple{},T,0,1}(v)
    @test @inferred(maybestatic_reshape([v], ())) == fill(v)
    @test typeof(maybestatic_reshape([v], ())) == typeof(fill(v))

    @test @inferred(size_dims(sz)) === sz
    @test @inferred(size_dims(sasz)) === sisz
    @test @inferred(size_dims(sisz)) === sisz
    @test @inferred(size_dims(())) === ()
    @test @inferred(canonical_size(size_dims(sasz))) === sasz

    @test @inferred(maybestatic_length(5)) === static(1)
    @test @inferred(maybestatic_length(())) === static(0)
    @test @inferred(maybestatic_length((sz))) === static(3)
    @test @inferred(maybestatic_length((a = 2, b = 4, c = 3))) === static(3)
    @test @inferred(maybestatic_length(Base.OneTo(4))) === 4
    @test @inferred(maybestatic_length(StaticArrays.SOneTo(4))) === static(4)
    @test @inferred(maybestatic_length(Static.SOneTo(4))) === static(4)
    @test @inferred(maybestatic_length(static(2):static(5))) === static(4)
    @test @inferred(maybestatic_length(StaticUnitRange(2, 5))) === static(4)
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

    @test_throws BoundsError maybestatic_last(())
    @test @inferred(maybestatic_last(v)) === v
    @test @inferred(maybestatic_last(sv)) === sv
    @test @inferred(maybestatic_last(2:static(5))) === static(5)
    @test @inferred(maybestatic_last(tpl)) === last(tpl)
    @test @inferred(maybestatic_last(nt)) === last(nt)
    @test @inferred(maybestatic_last(sz)) === last(sz)
    @test @inferred(maybestatic_last(sasz)) === static(last(sz))
    @test @inferred(maybestatic_last(sisz)) === static(last(sz))
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
    @test @inferred(size_from_type(SArray{Tuple{},T,0,1})) === StaticArrays.Size()
    @test @inferred(size_from_type(typeof(SA'))) === StaticArrays.Size(1, len)
    @test @inferred(size_from_type(typeof(view(rshpSA, :, 1, 1)))) === StaticArrays.Size(2)
    @test @inferred(size_from_type(SVector)) === NoTypeSize{SVector}()
    @test @inferred(size_from_type(eltype(A))) === maybestatic_size(A[1])
    @test @inferred(size_from_type(typeof(A))) === NoTypeSize{typeof(A)}()
    @test @inferred(size_from_type(String)) === NoTypeSize{String}()
end


@testset "static type reductions" begin
    @test @inferred(static_all(T -> T <: Integer, Tuple{})) === static(true)
    @test @inferred(static_all(T -> T <: Integer, Tuple{Int,Bool})) === static(true)
    @test @inferred(static_all(T -> T <: Integer, Tuple{Int,Float64})) === static(false)
    @test @inferred(static_all(T -> static(T <: Integer), Tuple{Int,Bool})) === static(true)

    @test @inferred(static_any(T -> T <: Integer, Tuple{})) === static(false)
    @test @inferred(static_any(T -> T <: Integer, Tuple{Float64,Bool})) === static(true)
    @test @inferred(static_any(T -> T <: Integer, Tuple{Float64,String})) === static(false)

    @test @inferred(static_reduce(+, sizeof, Tuple{Int32,Int64,Int16})) === 14
    @test @inferred(static_reduce(promote_type, Tuple{Int,Float32})) === Float32
    @test @inferred(static_reduce(&, T -> static(T <: Integer), Tuple{Int,Bool})) ===
          static(true)

    # The results must be constants, not just inferred:
    f_all() = static_all(T -> T <: Integer, Tuple{Int,Bool,Float64})
    f_any() = static_any(T -> T <: Integer, Tuple{Float64,Bool})
    f_red() = static_reduce(+, T -> static(sizeof(T)), Tuple{Int32,Int64})
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
end


@testset "vector splitting" begin
    A = rand(6)
    SA = SVector{6}(A)
    tpl = Tuple(A)

    @test @inferred(maybestatic_view(A, 2, 4)) == A[2:4]
    @test @inferred(maybestatic_view(A, 2, 4)) isa SubArray
    @test @inferred(maybestatic_view(SA, static(2), static(4))) === SVector{3}(A[2:4])
    @test @inferred(maybestatic_view(tpl, static(2), static(4))) === Tuple(A[2:4])

    a, b = @inferred split_at(A, 2)
    @test a == A[1:2] && b == A[3:6]
    sa, sb = @inferred split_at(SA, static(2))
    @test sa === SVector{2}(A[1:2]) && sb === SVector{4}(A[3:6])
    sa0, sb0 = @inferred split_at(SA, static(0))
    @test sa0 === SVector{0,Float64}() && sb0 === SA
end


@testset "type-level axes2size" begin
    @test @inferred(axes2size(Tuple{})) === StaticArrays.Size()
    @test @inferred(axes2size(typeof((StaticOneTo(2), StaticOneTo(3))))) ===
          StaticArrays.Size(2, 3)
    @test @inferred(axes2size(typeof((Static.SOneTo(2), StaticOneTo(3))))) ===
          StaticArrays.Size(2, 3)
    @test @inferred(axes2size(typeof((StaticOneTo(2),)))) === StaticArrays.Size(2)
end
