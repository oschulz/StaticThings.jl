# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

using StaticThings
using Test

using Base: Broadcast

import JLArrays
using JLArrays: JLArray

import Static
using Static: static


# JLArrays stands in for GPU arrays here: with scalar indexing disabled it
# fails on everything that a real device array can't do either.
@testset "device arrays" begin
    JLArrays.allowscalar(false)

    A_h = rand(2, 3, 4)
    A = JLArray(A_h)
    B_h = A_h .> 0.5
    B = JLArray(B_h)
    v_h = rand(6)
    v = JLArray(v_h)

    @test @inferred(maybestatic_reshape(A, (static(6), static(4)))) isa JLArray{Float64,2}
    @test Array(maybestatic_reshape(A, (static(6), static(4)))) == reshape(A_h, 6, 4)

    @test @inferred(sum_leading_dims(A, static(0))) === A
    @test Array(@inferred(sum_leading_dims(A, static(2)))) ≈
          dropdims(sum(A_h, dims = (1, 2)), dims = (1, 2))
    @test @inferred(sum_leading_dims(A, static(3))) ≈ sum(A_h)

    @test Array(@inferred(all_leading_dims(B, static(2)))) ==
          dropdims(all(B_h, dims = (1, 2)), dims = (1, 2))
    @test @inferred(all_leading_dims(B, static(3))) === all(B_h)

    @test Array(@inferred(merge_leading_dims(A, static(2)))) == reshape(A_h, 6, 4)
    @test Array(@inferred(drop_leading_dims(JLArray(reshape(A_h, 1, 1, 24)), static(2)))) ==
          vec(A_h)

    bc = Broadcast.instantiate(Broadcast.broadcasted(*, A, 2))
    @test @inferred(sum_leading_dims(bc, static(3))) ≈ 2 * sum(A_h)
    @test Array(@inferred(sum_leading_dims(bc, static(1)))) ≈
          2 * dropdims(sum(A_h, dims = 1), dims = 1)

    @test Array(@inferred(maybestatic_view(v, static(2), static(4)))) == v_h[2:4]
    va, vb = @inferred split_at(v, static(2))
    @test Array(va) == v_h[1:2] && Array(vb) == v_h[3:6]
end # testset
