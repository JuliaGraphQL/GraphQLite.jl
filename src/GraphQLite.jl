module GraphQLite

include("imports.jl")
include("utils.jl")

struct GQLRoot end
struct GQLQuery end
struct GQLMutation end
struct GQLSubscription end
export GQLRoot, GQLQuery, GQLMutation, GQLSubscription

getfieldargs() = nothing
export getfieldargs, GQLInputType, GQLFieldArg, constructinput

include("schema.jl")
export getschematype, GQLType, GQLTypeVect, getshape

include("input.jl")
export isinputtype

include("macros.jl")
export @schema

include("resolve.jl")
export resolve

include("request.jl")
export runquery, runmutation, runsubscription, runremotequery, runremotemutate

include("runquery2.jl")
export rungql

include("quick.jl")
export query, mutate!, pquery, pmutate!

include("other/precompile.jl")

end