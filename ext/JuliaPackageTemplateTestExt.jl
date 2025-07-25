# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

module JuliaPackageTemplateTestExt

using Test: @test, @testset
using StaticThings

function StaticThings.test_hellofunc(f)
    @testset "test_hellofunc for $(nameof(typeof(f)))" begin
        @test f() == "Hello, World!"
    end
    return nothing
end

end # module JuliaPackageTemplateTestExt
