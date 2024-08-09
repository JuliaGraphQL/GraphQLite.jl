@schema """
type Query {
    getCart(id: Int): Cart
    getCustomers: [Customer]
}
type Mutation {
    addItemToCart(input: CartItemInput): Cart
}
type Customer {
    id: Int!
    name: String!
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
input CartItemInput {
    cartId: Int!
    itemId: Int!
    quantity: Int!
}
"""
