struct Cart
    id::Int
    name::String
end

struct Customer
    id::Int
    name::String
    cart_id::Int
end

struct CartItem
    id::Int
    cart_id::Int
    item_id::Int
end

@kwdef struct CartItemInput
    quantity::Int = 1
    cart_id::Int
    item_id::Int
end

struct Item
    id::Int
    name::String
    alternate_names::Vector{String}
    brand_id::Int
end

struct Brand
    id::Int
    name::String
    company_id::Int
end

struct Company
    id::Int
    name::String
end

struct Category
    id::Int
    name::String
end

struct Group
    id::Int
    name::String
end

struct CatGroup
    id::Int
    category_id::Int
    group_id::Int
end

struct ItemCategory
    id::Int
    item_id::Int
    category_id::Int
end