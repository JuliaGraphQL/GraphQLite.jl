cd(@__DIR__)
import Pkg
Pkg.activate(".")
using GraphQLite
using JSON3
include("db.jl")
include("resolvers.jl")
include("tests.jl")

@schema """
type Query {
    getCart(id: Int): Cart
    getCustomers: [Customer]
}
type Mutation {
    addItemToCart: Cart
}
type Customer {
    cart: Cart
}
type Cart {
    id: Int
    name: String
    items: [Item]
}
type Item {
    id: Int
    name: String
    alternateNames: [String]
    brandId: Int
    brand: Brand
    categories: [Category]
}
type Brand {
    id: Int
    name: String
    company: Company
}
type Company {
    id: Int
    name: String
}
type Category {
    id: Int
    name: String
    groups: [Group]
}
type Group {
    id: Int
    name: String
}
"""

using Diana

getCart = """
    query GetCart(\$id: Int){
        foo: getCart(id: \$id){
            items { id name alternateNames brandId brand{name} }
        }
        bar: getCart(id: 2){
            items { id name alternateNames brandId brand{name} }
        }
    }
"""

parsed = Parse(getCart)
unittest() 
JSON3.pretty(GraphQLite.runquery(getCart, Dict(:id=>1)))
getshape("query.getCart.items.brand.company")
# TODO: test nulls

# addItem = """
#     mutation AddItem {
#         addItemToCart{
#             items { id name }
#         }
#     }
# """
# JSON3.pretty(runmutation(addItem))

getCustomers = """
    query GetCustomers{
        getCustomers{
            cart{items{id name brand{name company{id name}}}}
        }
    }
"""
JSON3.pretty(GraphQLite.runquery(getCustomers; show_planning=true))





JSON3.pretty(GraphQLite.runquery(getCustomers))
getshape("query")
getshape("query.getCustomers")
getshape("query.getCustomers.cart")
getshape("query.getCustomers.cart.items")
getshape("query.getCustomers.cart.items.name")