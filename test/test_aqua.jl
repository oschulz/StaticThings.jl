# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

import Test
import Aqua
import StaticThings

Test.@testset "Package ambiguities" begin
    Test.@test isempty(Test.detect_ambiguities(StaticThings))
end # testset

Test.@testset "Aqua tests" begin
    Aqua.test_all(
        StaticThings,
        ambiguities = true
    )
end # testset
