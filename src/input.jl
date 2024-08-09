function constructfrom(T, args)
    StructTypes.constructfrom(T, args)
end

function getinput(T::Type, args)
    @assert isinputtype(Val(Symbol(T))) "Type $T is not defined as a GraphQLite \"input\" type"
    constructfrom(T, args)
end

isinputtype(::Val) = false

# function getinput(s::Symbol, d::Dict)
#     getinput(Val(s), d)
# end

function parseinput(gql)
    document = Parse(gql)
    root = document.definitions[1]
    if isa(root.name, String)
        node_name = nothing
    else
        node_name = Symbol(root.name.value)
    end
    (
        document=document, 
        root=root, 
        node_name=node_name,
    )
end