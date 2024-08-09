function getkid(request, parent_gql_type, key, parent_idx)
    parent_key = getparentkey(key)
    parent_overall_idx = request.counters[parent_key] + parent_idx
    request.flat_data[key][parent_overall_idx]
end

function getkids(request, parent_gql_type::Val{:object}, key, parent_idx)
    request.flat_data[key][1]
end

function getkids(request, parent_gql_type::Val{:list}, key, parent_idx)
    parent_key = getparentkey(key)
    parent_overall_idx = request.counters[parent_key] + parent_idx
    request.flat_data[key][parent_overall_idx]
end

function runremote(url::String, operation::Symbol, gql::String, vars::AbstractDict; headers=nothing)
    body = JSON3.write(Dict(operation=>gql, :vars=>vars))
    res = HTTP.post(url, headers=headers, body=body)
    copy(JSON3.read(res.body)[:data])
end

function runremotemutation(url::String, gql::String; headers=nothing)
    runremotemutation(url, gql, Dict(); headers=headers)
end
function runremotemutation(url::String, gql::String, vars::Dict; headers=nothing)
    runremote(url, :mutation, gql, vars; headers=headers)
end

function runremotequery(url::String, gql::String; headers=nothing)
    runremotequery(url, gql, Dict(); headers=headers)
end
function runremotequery(url::String, gql::String, vars::Dict; headers=nothing)
    runremote(url, :query, gql, vars; headers=headers)
end

"""
    runquery(gql::String, vars::Union{<:AbstractDict,Nothing}=nothing, extra::Union{<:AbstractDict,Nothing}=nothing; kwargs...)

## Example:

```julia
get_cart = "
    query GetCarts(\\\$id: Int!){
        myShoppingCart: getCart(id: \$id){
            items { id name alternateNames brandId brand{name} }
        }
    }
"
response = runquery(get_cart, json2dict(\"\"\"{"id":1}\"\"\"))
@assert response isa Dict   
@assert response[:myShoppingCart] isa Dict
@assert response[:myShoppingCart][:items] isa Vector{<:AbstractDict}
```
"""
function runquery(gql::String, vars::Union{<:AbstractDict,Nothing}=nothing, extra::Union{<:AbstractDict,Nothing}=nothing; kwargs...)
    rungql(gql, :query, vars, extra; kwargs...)
end

function runsubscription(gql::String, vars::Union{<:AbstractDict,Nothing}=nothing, extra::Union{<:AbstractDict,Nothing}=nothing; kwargs...)
    rungql(gql, :subscription, vars, extra; kwargs...)
end

"""
    runmutation(gql::String, vars::Union{<:AbstractDict,Nothing}=nothing, extra::Union{<:AbstractDict,Nothing}=nothing; kwargs...)

## Example:

```julia
add_item = "
    mutation AddShoppingCartItem(\$input: CartItemInput!){
        addItemToCart(input: \$input){
            items { \$item_fragment }
        }
    }
"
response = runmutation(
    add_item, 
    json2dict(\"\"\"{"input":{"cartId":1, "itemId":5}}\"\"\"),
)
@assert response isa Dict   
@assert response[:addItemToCart] isa Dict
@assert response[:addItemToCart][:items] isa Vector{<:AbstractDict}
```
"""
function runmutation(gql::String, vars::Union{<:AbstractDict,Nothing}=nothing, extra::Union{<:AbstractDict,Nothing}=nothing; kwargs...)
    rungql(gql, :mutation, vars, extra; kwargs...)
end

function isfulfillable(d, node_path)
    isnothing(d[node_path]) && !isnothing(getparents(d, node_path))
end

function getflatdata(gql, args; show_planning=false)
    d = initflatdata(gql)
    node_paths = getflatgql(gql)
    allfulfilled = ()->all(v->!isnothing(v), values(d))
    max_iters = 1000
    while !allfulfilled()
        if max_iters <= 0
            error("getflatdata() max_iters exceeded")
        end
        fulfillable = filter(x->isfulfillable(d, x), node_paths)
        if show_planning
            @show fulfillable
        end
        parents = getparents.(Ref(d), fulfillable)
        to_be_fulfilled = zip(fulfillable, parents, Ref(args))
        resolutions = asyncmap(fulfill, to_be_fulfilled)
        for (node_path, resolved) in resolutions
            d[node_path] = resolved
        end
        max_iters -= 1
    end
    if show_planning
        for (k,v) in d
            println("\n~~~~~~~~~~~~~~~~~~[")
            println("$k")
            JSON3.pretty(v)
            println("\n~~~~~~~~~~~~~~~~~~]\n")
        end
    end
    d
end

getparentkey(key::NodeName) = NodeName(join(split(key.nome, ".")[1:end-1], "."), join(split(key.alias, ".")[1:end-1], "."))
lastpart(key::NodeName) = NodeName(last(split(key.nome, ".")), last(split(key.alias, ".")))


function initcounters(gql)
    counters = Dict((requested_node, 0) for requested_node in getflatgql(gql))
    counters[NodeName("")] = 0
    counters
end

function initflatdata(gql)
    d = Dict{NodeName,Union{Nothing,Vector}}((requested_node, nothing) for requested_node in getflatgql(gql))
    d[NodeName("")] = [GQLRoot()]
    operation = gql[NodeName("")][1]
    if operation == NodeName("query")
        d[NodeName("query")] = [GQLQuery()]
    elseif operation == NodeName("mutation")
        d[NodeName("mutation")] = [GQLMutation()]
    elseif operation == NodeName("subscription")
        d[NodeName("subscription")] = [GQLSubscription()]
    else
        error("initflatdata() not implemented for $operation")
    end
    d
end

function getflatgql(gql)
    requested_nodes = NodeName[]
    for (key,value) in gql
        for v in value
            node = isempty(key.nome) ? v : NodeName("$(key.nome).$(v.nome)", "$(key.alias).$(v.alias)", v.vars)
            push!(requested_nodes, node)
        end
    end
    requested_nodes
end

getpathkey(path::Vector) = join(path, ".")

function flattenparents(parents)
    if isa(parents, AbstractVector{<:AbstractVector})
        return collect(Iterators.flatten(parents))
    end
    parents
end

function getparents(d::Dict, node_path)
    line = NodeName(
        getpathkey(split(node_path.nome, ".")[1:end-1]),
        getpathkey(split(node_path.alias, ".")[1:end-1]),
        node_path.vars
    )
    if line == NodeName("")
        return nothing
    end
    d[line]
end

ensurecorrectshape(::Val, resolutions) = resolutions
function ensurecorrectshape(::Val{:list}, resolutions)
    empty_list = []
    map(resolutions) do x
        isnothing(x) ? empty_list : x
    end
end

function getresolverargs(node_path, args)
    Dict{Symbol,Any}(
        :vars=>Dict(
            map(node_path.vars) do node_arg_var
                var_name = Symbol(node_arg_var.name)
                if node_arg_var.variable
                    var_symbol = Symbol(replace(node_arg_var.value, r"\$"=>""))
                    return (var_name, args[:vars][var_symbol])
                else
                    return (var_name, node_arg_var.value)
                end
            end
        ),
        :extra=>args[:extra],
    )
end

function fulfill(x)
    (node_path, parents, args) = x
    field_name = Val(Symbol(lastpart(node_path).nome))
    flat_parents = flattenparents(parents)
    shape = Val(getshape(node_path))

    #JSON3.pretty(args)
    resolver_args = getresolverargs(node_path, args)
    if !isempty(flat_parents)
        resolver_args[:vars] = transformvars(flat_parents[1], field_name, resolver_args[:vars])
    end
    
    resolved_uncorrected = resolve(flat_parents, field_name, resolver_args)
    resolved = ensurecorrectshape(shape, resolved_uncorrected)
    @assert length(resolved) == length(flat_parents) "Length of \"GraphQLite.resolve(parents::$(typeof(flat_parents)), ::$(typeof(field_name)))\" response ($(length(resolved))) doesn't match the length of the \"parents\" argument ($(length(flat_parents))). This violates the batched resolver contract."
    (node_path, resolved)
end

function makefield(request, child_key, kid_idx)
    gql_type = getshape(child_key)
    if gql_type === :scalar
        return makescalar(request, child_key, kid_idx)
    elseif gql_type === :object
        return makeobject(request, child_key, kid_idx)
    elseif gql_type === :list
        return makelist(
            request,
            child_key,
            kid_idx,
        )
    end
    error("makefield() not implemented for $gql_type")
end

function makescalar(request, key, kid_idx)
    parent_key = getparentkey(key)
    parent_overall_idx = request.counters[parent_key] + kid_idx
    request.flat_data[key][parent_overall_idx]
end

islistofprimitives(key) = !getschematype(key).t.custom

function makelist(request, key, parent_idx)
    parent_gql_type = getshape(getparentkey(key))
    kids = getkids(request, Val(parent_gql_type), key, parent_idx)
    if islistofprimitives(key)
        return kids
    end
    base_idx = request.counters[key]
    name = split(key,".") |> last
    results = map(enumerate(kids)) do (kid_idx, kid_x)
        makekid!(request, key, name, kid_idx)
    end
    request.counters[key] = base_idx + length(kids)
    results
end

function makekid!(request, key, name, kid_idx)
    fields = map(request.gql[key]) do child_key
        (
            Symbol(child_key), 
            makefield(request, "$key.$child_key", kid_idx),
        )
    end
    Dict{Symbol,Any}(fields)
end

function makeobject(request, key, parent_idx)
    parent_gql_type = getshape(getparentkey(key))
    kid = getkid(request, Val(parent_gql_type), key, parent_idx)
    if isnothing(kid)
        return nothing
    end
    base_idx = request.counters[key]
    name = split(key,".") |> last
    result = makekid!(request, key, name, 1)
    request.counters[key] = base_idx + 1
    result
end

struct GQLRequest
    gql::Dict
    counters::Dict
    flat_data::Dict
    function GQLRequest(gql_raw::String, operation::String, args; kwargs...)
        parsed = Parse(gql_raw)
        definition = parsed.definitions[1]
        function getnodename(node)
            selection_name = node.name.value
            selection_alias = isnothing(node.alias) ? selection_name : node.alias.value
            node_arg_vals = map(node.arguments) do arg
                arg_name = arg.name.value
                if arg.value[2] isa Diana.Variable
                    arg_value = "\$$(arg.value[2].name.value)"
                    is_variable = true
                else
                    arg_value = arg.value[2].value
                    is_variable = false
                end
                #@show arg_name, arg_value, is_variable
                NodeArgVal(is_variable, arg_name, arg_value)
            end
            # @show selection_name, node_arg_vals
            NodeName(selection_name, selection_alias, node_arg_vals)
        end
        function traverse!(d, parent_key::NodeName, selectionSet)
            d[parent_key] = NodeName[]
            if !isnothing(selectionSet)
                for selection in selectionSet.selections
                    node_name = getnodename(selection)
                    full_name = NodeName(
                        "$(parent_key.nome).$(node_name.nome)",
                        "$(parent_key.alias).$(node_name.alias)",
                        node_name.vars,
                    )
                    push!(d[parent_key], node_name)
                    if getshape(full_name) !== :scalar
                        traverse!(d, full_name, selection.selectionSet)
                    end
                end
            end
            nothing
        end
        gql = Dict(NodeName("")=>[NodeName(operation)])
        traverse!(gql, NodeName(operation), definition.selectionSet)
        # gql = Dict(
        #     "" => [operation],
        #     "query" => ["getCart"],
        #     "query.getCart" => ["id","name","items"],
        #     "query.getCart.items" => ["id","name","brand","categories"],
        #     "query.getCart.items.brand" => ["id","name","company"],
        #     "query.getCart.items.brand.company" => ["id","name"],
        #     "query.getCart.items.categories" => ["id","name","groups"],
        #     "query.getCart.items.categories.groups" => ["id","name"],
        # )
        # JSON3.pretty(gql)
        new(
            gql,
            initcounters(gql),
            getflatdata(gql, args; kwargs...),
        )
    end
end