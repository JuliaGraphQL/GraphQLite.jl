cd(@__DIR__)
import Pkg
Pkg.activate(".")
using GraphQLite
using JSON3
include("schema.jl")
include("types.jl")
include("db.jl")
include("resolvers.jl")
include("input_resolvers.jl")
