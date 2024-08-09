cd(@__DIR__)
import Pkg
Pkg.activate(".")
using GraphQLite
using JSON3
include("resolvers.jl")