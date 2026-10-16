# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

using StaticThings
using Test

using OffsetArrays: OffsetArray

import Static
using Static: static


# Operations over leading dimensions leave the remaining dimensions alone,
# including their axes:
@testset "offset axes" begin
    A = OffsetArray(reshape(collect(1.0:6.0), 1, 2, 3), 0:0, 4:5, 7:9)
    B = A .> 2

    @test axes(@inferred(drop_leading_dims(A, static(1)))) == axes(dropdims(A; dims = 1))
    @test drop_leading_dims(A, static(1)) == dropdims(A; dims = 1)

    @test axes(@inferred(sum_leading_dims(A, static(1)))) ==
          axes(dropdims(sum(A; dims = 1); dims = 1))
    @test sum_leading_dims(A, static(1)) == dropdims(sum(A; dims = 1); dims = 1)
    @test sum_leading_dims(A, static(2)) == dropdims(sum(A; dims = (1, 2)); dims = (1, 2))

    @test axes(@inferred(all_leading_dims(B, static(1)))) ==
          axes(dropdims(all(B; dims = 1); dims = 1))
    @test all_leading_dims(B, static(1)) == dropdims(all(B; dims = 1); dims = 1)

    # A merged dimension is new, so it is one-based:
    @test axes(@inferred(merge_leading_dims(A, static(2)))) == (Base.OneTo(2), axes(A, 3))
    @test axes(@inferred(merge_leading_dims(A, static(0)))) == (Base.OneTo(1), axes(A)...)

    a, b = @inferred maybestatic_split(OffsetArray([10, 20, 30], -1:1), 1)
    @test collect(a) == [10] && collect(b) == [20, 30]

    # A `view` or `PermutedDimsArray` of an offset array has to be reshaped
    # to axes, because a plain size throws:
    for W in (view(A, :, :, :), PermutedDimsArray(A, (1, 2, 3)))
        @test axes(merge_leading_dims(W, static(2))) == (Base.OneTo(2), axes(A, 3))
        @test axes(drop_leading_dims(W, static(1))) == (axes(A, 2), axes(A, 3))
        @test sum_leading_dims(W, static(1)) == dropdims(sum(A; dims = 1); dims = 1)
    end

    w = OffsetArray([10, 20, 30], -1:1)
    for W in (view(w, :), PermutedDimsArray(w, (1,)))
        merged = merge_leading_dims(W, static(1))
        @test axes(merged) == (Base.OneTo(3),)
        @test collect(merged) == [10, 20, 30]
    end

    empty_offset = OffsetArray(Int[], 0:-1)
    @test size(merge_leading_dims(view(empty_offset, :), static(1))) == (0,)
end # testset
