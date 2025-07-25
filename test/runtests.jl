# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

import Test

Test.@testset "Package StaticThings" begin
    include("test_aqua.jl")
    include("test_tools.jl")
    include("test_docs.jl")
end # testset
