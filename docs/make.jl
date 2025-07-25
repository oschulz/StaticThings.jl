# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [nonstrict] [fixdoctests]
#
# for local builds.

using Documenter
using StaticThings

# Doctest setup
DocMeta.setdocmeta!(
    StaticThings,
    :DocTestSetup,
    :(using StaticThings);
    recursive=true,
)

makedocs(
    sitename = "StaticThings",
    modules = [StaticThings],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://oschulz.github.io/StaticThings.jl/stable/"
    ),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
        "LICENSE" => "LICENSE.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
    linkcheck = !("nonstrict" in ARGS),
    warnonly = ("nonstrict" in ARGS),
)

deploydocs(
    repo = "github.com/oschulz/StaticThings.jl.git",
    forcepush = true,
    push_preview = true,
)
