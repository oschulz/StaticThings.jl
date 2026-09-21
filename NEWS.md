# StaticThings.jl news

## v0.3.0

Breaking:

* `maybestatic_reshape(A, sz)` only returns a static array if `A` is one.
  It used to wrap any array in a `StaticArrays.SArray` for a static `sz`,
  which copies device arrays and traced arrays to the host. The input
  decides now: a static-size variate taken from a plain `Vector` is a
  plain array or view, one taken from an `SVector` stays static.

New:

* `size_dims(sz)`, the inverse of `canonical_size`, and a type-level
  `axes2size(::Type{<:Tuple{Vararg{StaticOneToLike}}})`.
* `static_mapreduce(f, op, T)`, `static_reduce(op, T)`, `static_all(f, T)`
  and `static_any(f, T)`, pairwise folds over the element types of a tuple
  type that infer as compile-time constants.
* `sum_leading_dims(A, n)`, `drop_leading_dims(A, n)`,
  `merge_leading_dims(A, n)` and `all_leading_dims(A, n)` over a static
  number of leading dimensions, keeping static arrays static.
* `maybestatic_view(A, r)` and `split_at(A, n)`, views and splits of
  vectors and tuples that stay static for static inputs and indices.
