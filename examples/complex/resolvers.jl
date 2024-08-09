function GraphQLite.resolve(::GQLMutation, ::Val{:addItemToCart}, args)
    cart_item_input = args[:vars][:input]
    for _ in 1:cart_item_input.quantity
        push!(cart_items, CartItem(length(cart_items)+1, cart_item_input.cart_id, cart_item_input.item_id))
    end
    carts[1]
end

function GraphQLite.resolve(::GQLQuery, ::Val{:getCart}, args)
    carts[args[:vars][:id]]
end

function GraphQLite.resolve(::GQLQuery, ::Val{:getCustomers}, args)
    customers
end

function GraphQLite.resolve(parents::Vector{Cart}, ::Val{:items}, args)
    map(parents) do cart
        map(
            x -> items[x.item_id], 
            filter(x -> x.cart_id == cart.id, cart_items)
        )
    end
end

function GraphQLite.resolve(parents::Vector{Item}, ::Val{:brand}, args)
    map(x -> brands[x.brand_id], parents)
end

function GraphQLite.resolve(parents::Vector{Item}, ::Val{:categories}, args)
    map(parents) do item
        item_cats = filter(x -> x.item_id == item.id, item_categories)
        cat_ids = [x.category_id for x in item_cats]
        map(x -> categories[x], cat_ids)
    end
end

function GraphQLite.resolve(parents::Vector{Category}, ::Val{:groups}, args)
    map(parents) do cat
        filtered = filter(x -> x.category_id == cat.id, cat_groups)
        group_ids = [x.group_id for x in filtered]
        map(x -> groups[x], group_ids)
    end
end

function GraphQLite.resolve(parents::Vector{Brand}, ::Val{:company}, args)
    map(x -> companies[x.company_id], parents)
end

function GraphQLite.resolve(parents::Vector{Customer}, ::Val{:cart}, args)
    map(x -> carts[x.cart_id], parents)
end