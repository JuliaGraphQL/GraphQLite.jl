function unittest()
    gql = """
        query GetCart(\$id: Int){
            getCart(id: \$id){
                id
                name
                items {
                    id
                    name
                    brand {
                        id name company {id name}
                    }
                    categories {
                        id
                        name
                        groups {id name}
                    }
                }
            }
        }
    """
    #JSON3.write("test.txt", runquery(gql, Dict(:id=>1)))
    @assert read("test.txt", String) == JSON3.write(runquery(gql, Dict(:id=>1)))
end