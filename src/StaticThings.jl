# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

"""
    StaticThings

StaticThings provides tools to help write generic code that works with both
static and non-static values and arrays.
"""
module StaticThings

using FillArrays: FillArrays, Fill

using Static: Static, StaticInteger, static, dynamic

using StaticArrayInterface: StaticArrayInterface

using StaticArrays: StaticArrays, StaticArray, SArray, SVector

include("aliases.jl")
include("tools.jl")

end # module
