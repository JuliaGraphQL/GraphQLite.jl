function resolve(::Nothing, ::Val{F}, ::Any) where F
    nothing
end

"""
    resolve(parent::T, field::Val{F}, args)

## Example:

```julia
function GraphQLite.resolve(parent::GQLQuery, field::Val{:getCart}, args)
    # return a object of type Cart
end
```
"""
function resolve(parent::T, field::Val{F}, args) where T where F
    @assert !isa(T, AbstractArray)
    if T === Nothing
        return nothing
    end
    field_name = F |> string |> snakecase |> Symbol
    if !hasfield(T, field_name)
        error("$T type doesn't have the field \"$field_name\", nor is GraphQLite.resolve(::$(T), ::Val{:$F}) defined.")
    end
    getfield(parent, field_name)
end

function resolve(parents::AbstractArray, field::Val, args)
    resolve.(parents, Ref(field), Ref(args))
end

GraphQLite.getfieldargs(::GQLType, ::Val) = GQLFieldArg[]

function transformvars(parent::T, field::Val{F}, vars) where {T, F}
    field_args = getfieldargs(GQLType(Symbol(T)), field)
    Dict{Symbol,Any}(
        (field_arg.name, constructinput(field_arg.t, vars[field_arg.name])) for field_arg in field_args
    )
end

"""
    resolveinput(field::Val{F}, d::T)

## Example:

```julia

@schema \"\"\"
...
type Mutation {
    addItemToCart(input: CartItemInput): Cart
}
...
input CartItemInput {
    cartId: Int!
    itemId: Int!
    quantity: Int!
}
...
\"\"\"

@kwdef struct CartItemInput
    quantity::Int = 1
    cart_id::Int
    item_id::Int
end

GraphQLite.resolveinput(::Val{:CartItemInput}, d::Dict) = CartItemInput(d)
```
"""
function resolveinput(field::Val{F}, d::T) where T where F
    error("GraphQLite.resolveinput(::Val{:$F}, ::$(T)) is not defined for input type \"$F\"")
end
export resolveinput

constructinput(::GQLInputType, ::Nothing) = nothing
function constructinput(::GQLInputType{T}, d::Dict) where T
    resolveinput(Val(T), d)
end
constructinput(::GQLInputType{:String}, v::String) = v
constructinput(::GQLInputType{:Int}, v::Number) = v
constructinput(::GQLInputType{:Float}, v::Number) = v
constructinput(::GQLInputType{:Boolean}, v::Bool) = v
constructinput(::GQLInputType{:ID}, v::String) = v

constructinput(::GQLInputTypeVect, v::Vector{Nothing}) = v
function constructinput(::GQLInputTypeVect{T}, v::Vector{<:AbstractDict}) where T
    [resolveinput(Val(T), d) for d in v]
end
constructinput(::GQLInputTypeVect{:String}, v::Vector{String}) = v
constructinput(::GQLInputTypeVect{:Int}, v::Vector{Number}) = v
constructinput(::GQLInputTypeVect{:Float}, v::Vector{Number}) = v
constructinput(::GQLInputTypeVect{:Boolean}, v::Vector{Bool}) = v
constructinput(::GQLInputTypeVect{:ID}, v::Vector{String}) = v