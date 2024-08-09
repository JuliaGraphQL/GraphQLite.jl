cd(@__DIR__)
import Pkg
Pkg.activate(".")
using Documenter, GraphQLite
makedocs(
    sitename="GraphQLite.jl",
    modules=[GraphQLite],
)
deploydocs(
    repo = "github.com/JuliaGraphQL/GraphQLite.jl.git",
)