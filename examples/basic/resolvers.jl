struct User
    id::Int
    first_name::Union{Nothing,String}
    last_name::Union{Nothing,String}
end

const all_users = [
    User(1, "Frodo", "Baggins"),
    User(2, "Bilbo", "Baggins"),
    User(3, "Samwise", "Gamgee"),
]

function GraphQLite.resolve(::GQLQuery, ::Val{:getUsersByLastName}, args)
    last_name = args[:vars][:lastName]
    filter(x->x.last_name == last_name, all_users)
end