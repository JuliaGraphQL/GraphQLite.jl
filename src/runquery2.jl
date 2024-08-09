struct Node
    key::String
    is_leaf::Bool
    value
    value_type::String
    children::Dict
    function Node(key, is_leaf, value)
        new(key, is_leaf, value, string(typeof(value)), Dict())
    end
end

function makefield2(n::Node)
    n.is_leaf ? makescalar2(n) : makedict2(n)
end

function makefield2(nodes::Vector)
    makelist2(nodes)
end

function makelist2(nodes::Vector)
    map(nodes) do node
        makefield2(node)
    end
end

function makescalar2(node::Node)
    node.value
end

function makedict2(node::Node)
    if isnothing(node.value)
        return nothing
    end
    d = Dict()
    for child_key in keys(node.children)
        child_name = lastpart(child_key).alias
        d[Symbol(child_name)] = makefield2(node.children[child_key])
    end
    d
end

function rungql(gql::String, operation::Symbol, vars, extra; show_planning=false, kwargs...)
    req = GQLRequest(gql, string(operation), Dict(:vars=>vars, :extra=>extra); kwargs...)
    nodes = buildbottomup(req, operation)
    if show_planning
        println("\n~~~~~~~~~~~~~~~~~NODE TREE:")
        JSON3.pretty(nodes)
        println("~~~~~~~~~~~~~~~~~(end)\n")
    end
    makedict2(nodes[1]) |> JSON3.write |> JSON3.read |> copy
end

function buildbottomup(req::GQLRequest, operation::Symbol)
    clone = cloneflatmap(req.flat_data)
    function buildkey(key)
        parents_key = getparentkey(key)
        parents = getatoms(Val(getshape(parents_key)), clone[parents_key])
        children = clone[key]
        @assert length(parents) === length(children) "Parent count doesn't match child count"
        for (parent,child) in zip(parents, children)
            parent.children[key] = child
        end
    end
    buildkey.(keys(clone))
    clone[NodeName(string(operation))]
end

function cloneflatmap(flat_map)
    c = Dict()
    for (k,v) in flat_map
        c[k] = nodetransform(k, v)
    end
    c
end

getatoms(::Val{:scalar}, list::Vector) = list

getatoms(::Val{:object}, list::Vector) = list

function getatoms(::Val{:list}, list_of_lists::Vector)
    v = []
    for list in list_of_lists
        append!(v, list)
    end
    v
end

function nodetransform(key::NodeName, value)
    nodetransform(Val(getshape(key)), key, value)
end

nodetransform(::Val{:scalar}, key::NodeName, list::Vector) = Node.(key.alias, true, list)
nodetransform(::Val{:object}, key::NodeName, list::Vector) = Node.(key.alias, false, list)

function nodetransform(::Val{:list}, key::NodeName, list_of_list::Vector)
    is_leaf = isleaf(key)
    map(list_of_list) do list
        Node.(key.alias, is_leaf, list)
    end
end