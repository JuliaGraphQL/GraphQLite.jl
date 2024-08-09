function GraphQLite.resolve(parents::GQLMutation, field::Val{:addItemToCart}, args)
    push!(cart_items, CartItem(length(cart_items)+1, 1, 5))
    carts[1]
end

function GraphQLite.resolve(parent::GQLQuery, field::Val{:getCart}, args)
    "GQLQuery->getCart" |> resolvelog
    idx = args[:vars][:id]
    carts[idx]
end

function GraphQLite.resolve(parent::GQLQuery, field::Val{:getCustomers}, args)
    "GQLQuery->getCustomers" |> resolvelog
    customers
end

function GraphQLite.resolve(parents::Vector{Cart}, field::Val{:items}, args)
    "Cart->items" |> resolvelog
    map(parents) do cart
        map(
            x -> items[x.item_id], 
            filter(x -> x.cart_id == cart.id, cart_items)
        )
    end
end

function GraphQLite.resolve(parents::Vector{Item}, field::Val{:brand}, args)
    "Item->brand" |> resolvelog
    map(x -> brands[x.brand_id], parents)
end

function GraphQLite.resolve(parents::Vector{Item}, field::Val{:categories}, args)
    "Item->categories" |> resolvelog
    map(parents) do item
        item_cats = filter(x -> x.item_id == item.id, item_categories)
        cat_ids = [x.category_id for x in item_cats]
        map(x -> categories[x], cat_ids)
    end
end

function GraphQLite.resolve(parents::Vector{Category}, field::Val{:groups}, args)
    "Category->groups" |> resolvelog
    map(parents) do cat
        filtered = filter(x -> x.category_id == cat.id, cat_groups)
        group_ids = [x.group_id for x in filtered]
        map(x -> groups[x], group_ids)
    end
end

function GraphQLite.resolve(parents::Vector{Brand}, field::Val{:company}, args)
    "Brand->company" |> resolvelog
    map(x -> companies[x.company_id], parents)
end

function GraphQLite.resolve(parents::Vector{Customer}, field::Val{:cart}, args)
    "Customer->cart" |> resolvelog
    map(x -> carts[x.cart_id], parents)
end

function resolvelog(x)
    return
    println("resolver: $x ~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    sleep(0)
    println("resolver: $x; Done.")
end