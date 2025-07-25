# StaticThings.jl

StaticThings provides tools to help write generic code that works with both
static and non-static values and arrays. It bridges between
[Static](https://github.com/SciML/Static.jl) values,
[StaticArrays](https://github.com/JuliaArrays/StaticArrays.jl) and
[FillArrays](https://github.com/JuliaArrays/FillArrays.jl), as well as
non-static values and arrays.

The package provides the type aliases [`StaticUnitRange`](@ref), [`StaticOneTo`](@ref), [`IntegerLike`](@ref), [`SizeLike`](@ref), [`StaticSizeLike`](@ref), [`AxesLike`](@ref), [`StaticAxesLike`](@ref), [`OneToLike`](@ref), [`StaticOneToLike`](@ref) and [`StaticUnitRangeLike`](@ref), as union-based super-types for related types across Static, StaticArrays and Base.

Built around these alias types, StaticThings provides:

* Generative functions: [`maybestatic_oneto`](@ref), [`asnonstatic`](@ref), [`maybestatic_fill`](@ref), [`staticarray_type`](@ref) and [`maybestatic_reshape`](@ref).

* Length/size/axes query functions: [`maybestatic_length`](@ref), [`maybestatic_size`](@ref), [`maybestatic_axes`](@ref), [`maybestatic_eachindex`](@ref), [`maybestatic_first`](@ref), [`maybestatic_last`](@ref) and [`size_from_type`](@ref).

* Size/axes conversion functions: [`axes2size`](@ref), [`size2axes`](@ref), [`size2length`](@ref), [`asaxes`](@ref), [`canonical_indices`](@ref), [`canonical_size`](@ref) and [`canonical_axes`](@ref).

When creating arrays, StaticThings prefers allocation-free
types like `StaticArrays.SArray` and `FillArrays.Fill` where feasible.
