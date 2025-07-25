# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

"""
    StaticThings

StaticThings provides tools to help write generic code that works with both
static and non-static values and arrays.
"""
module StaticThings

import FillArrays
using FillArrays: Fill

import Static
using Static: StaticInteger, static, dynamic

import StaticArrays
using StaticArrays: StaticArray, SArray, SVector

include("aliases.jl")
include("tools.jl")

end # module
