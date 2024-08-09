include("imports.jl")

# Show the empty cart
item_fragment = "id name alternateNames brandId brand{name}"
get_cart = """
    query GetCarts(\$id: Int!){
        myShoppingCart: getCart(id: \$id){
            items { $item_fragment }
        }
    }
"""
runquery(get_cart, json2dict("""{"id":1}""")) |> JSON3.pretty

# Add an item to the cart
add_item = """
    mutation AddShoppingCartItem(\$input: CartItemInput!){
        addItemToCart(input: \$input){
            items { $item_fragment }
        }
    }
"""
runmutation(
    add_item, 
    json2dict("""{"input":{"cartId":1, "itemId":5}}"""),
) |> JSON3.pretty

# Show all customers
get_customers = """
    query GetCustomers{
        getCustomers{
            name
            cart { name items{ $item_fragment } }
        }
    }
"""
runquery(get_customers) |> JSON3.pretty
