struct NodeArgVal
    variable::Bool
    name::String
    value
end

struct NodeName
    nome::String
    alias::String
    vars::Vector
    function NodeName(nome, alias, vars=[])
        new(nome, alias, vars)
    end
end
NodeName(nome) = NodeName(nome, nome, [])
Base.hash(x::NodeName, h::UInt) = hash(x.alias)
Base.:(==)(a::NodeName, b::NodeName) = a.alias == b.alias

struct GQLType{T}
    t::Val{T}
    custom::Bool
    non_null::Bool
    function GQLType(name::Symbol, non_null=false)
        custom = !in(name, (:String, :Int, :Float, :Boolean, :ID))
        new{name}(Val(name), custom, non_null)
    end
end

struct GQLInputTypeVect{T}
    t::Val{T}
    custom::Bool
    non_null::Bool
    function GQLInputTypeVect(name::Symbol, non_null=false)
        custom = !in(name, (:String, :Int, :Float, :Boolean, :ID))
        new{name}(Val(name), custom, non_null)
    end
end
export GQLInputTypeVect

struct GQLInputType{T}
    t::Val{T}
    custom::Bool
    non_null::Bool
    function GQLInputType(name::Symbol, non_null=false)
        custom = !in(name, (:String, :Int, :Float, :Boolean, :ID))
        new{name}(Val(name), custom, non_null)
    end
end

struct GQLFieldArg
    name::Symbol
    t::Union{GQLInputType,GQLInputTypeVect}
end

struct GQLTypeVect{T}
    t::GQLType{T}
    non_null::Bool
    element_non_null::Bool
    function GQLTypeVect(name::Symbol, non_null=false, element_non_null=false)
        new{name}(GQLType(name), non_null, element_non_null)
    end
end

getschematype(v::GQLTypeVect, field) = getschematype(v.t, field)

function getshaperoot(key_node::NodeName)
    queryMutationSubscription = split(key_node.nome, ".")[1]
    if queryMutationSubscription == "query"
        return GQLType(:GQLQuery)
    elseif queryMutationSubscription == "mutation"
        return GQLType(:GQLMutation)
    elseif queryMutationSubscription == "subscription"
        return GQLType(:GQLSubscription)
    end
    error("getshaperoot() not implemented for $queryMutationSubscription")
end

function getschematype(key_node::NodeName)
    curr = getshaperoot(key_node)
    #@show key_node
    for el in split(key_node.nome, ".")[2:end]
        curr = GraphQLite.getschematype(curr, Val(Symbol(el)))
    end
    curr
end

getshape(s::String) = getshape(NodeName(s))

function getshape(child_key::NodeName)
    if isempty(child_key.alias)
        # Root of GQL tree.
        return :object
    end
    schema_type = getschematype(child_key)
    if isa(schema_type, GQLTypeVect)
        return :list
    elseif isa(schema_type, GQLType)
        return schema_type.custom ? :object : :scalar
    end
    error("getshape() not implemented for $schema_type")
end

function isleaf(child_key::NodeName)
    if isempty(child_key.alias)
        # Root of GQL tree.
        return false
    end
    schema_type = getschematype(child_key)
    if isa(schema_type, GQLTypeVect)
        return !schema_type.t.custom
    elseif isa(schema_type, GQLType)
        return !schema_type.custom
    end
    error("getshape() not implemented for $schema_type")
end