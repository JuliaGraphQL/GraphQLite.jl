parsejson(raw_json::String) = raw_json |> JSON3.read |> copy

function json2dict(raw_json::String)
    json = parsejson(raw_json)
    @assert json isa Dict
    json
end
export json2dict

function json2array(raw_json::String)
    json = parsejson(raw_json)
    @assert json isa Vector
    json
end
export json2array


snakecase(s) = lowercase(replace(s, r"([0-9a-z])([A-Z])" => s"\1_\2"))

function camel2snake(s::String)
    lowercase(join([isuppercase(c) && i != 1 ? "_" * lowercase(c) : lowercase(c) for (i, c) in enumerate(s)], ""))
end

cast(::Type{Union{Missing, Nothing, T}}, v::Number) where T <: Number = T(v)
cast(::Type{Union{Missing, T}}, v::Number) where T <: Number = T(v)
cast(::Type{Union{Missing,T}}, v::Missing) where T = missing
cast(::Type{Union{Missing,Nothing,T}}, v::Missing) where T = missing
cast(::Type{Union{Nothing,T}}, v::Nothing) where T = nothing
cast(::Type{Union{Missing,Nothing,T}}, v::Nothing) where T = nothing
cast(::Type{T}, v::T) where T = v
export cast

getnamedtuple(ks, vs) = NamedTuple{Tuple(Symbol.(ks))}(vs)

"""
    dict2struct(::Type{T}, d::Dict)

## Convenience method for converting a Dict to a custom type.
## Example:

```julia

@kwdef struct CartItemInput
    quantity::Int = 1
    cart_id::Int
    item_id::Int
end

@assert dict2struct(CartItemInput, Dict(:cart_id=>1, :item_id=>2)) == CartItemInput(1, 1, 2)
```
"""
function dict2struct(::Type{T}, d::Dict) where T
    fieldname2type = Dict((n,t) for (n,t) in zip(fieldnames(T), fieldtypes(T)))
    nt = getnamedtuple(camel2snake.(string.(Base.keys(d))), Base.values(d))
    all_pairs = collect(pairs(nt))
    filtered_pairs = filter(all_pairs) do (k,v)
        haskey(fieldname2type, k)
    end
    new_pairs = map(filtered_pairs) do (k,v)
        (k, cast(fieldname2type[k], v))
    end
    keys = first.(new_pairs)
    values = last.(new_pairs)
    new_nt = NamedTuple{Tuple(keys)}(values)
    T(; new_nt...)
end
export dict2struct