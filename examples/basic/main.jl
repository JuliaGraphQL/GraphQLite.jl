include("imports.jl")

@schema """
type Query { 
    getUsersByLastName(lastName: String!): [User]
}
type User {
    id: Int!
    firstName: String
    lastName: String
}
"""

response = runquery(
    "query GetUsersByLastName(\$lastName: String!){getUsersByLastName(lastName: \$lastName){id firstName}}", 
    Dict(:lastName => "Baggins"),
)
    
list_of_dicts = response[:getUsersByLastName]

JSON3.pretty(list_of_dicts)