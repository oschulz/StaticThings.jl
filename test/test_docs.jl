# This file is a part of StaticThings.jl, licensed under the MIT License (MIT).

using Test
using StaticThings
import Documenter

Documenter.DocMeta.setdocmeta!(
    StaticThings,
    :DocTestSetup,
    :(using StaticThings);
    recursive=true,
)
Documenter.doctest(StaticThings)
