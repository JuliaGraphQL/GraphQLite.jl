query(args...) = fastop(:query, args...)
mutate!(args...) = fastop(:mutation, args...)
pquery(args...) = query(args...) |> JSON3.pretty
pmutate!(args...) = mutate!(args...) |> JSON3.pretty

function fastop(operation_name::Symbol, field_name::Union{String,Symbol}, vars::Dict)
    fastop(operation_name, field_name, "", vars)
end

function fastop(operation_name::Symbol, field_name::Union{String,Symbol}, out_structure::String="", vars::Dict=Dict(), extra::Dict=Dict())
    if isempty(vars)
        vars_str = ""
    else
        vars_str = string("(", join(["$v: \$$v" for v in keys(vars)], " "), ")")
    end
    if isempty(out_structure)
        out_structure_str = ""
    else
        out_structure_str = "{$out_structure}"
    end
    gql_str = string(
        "$operation_name{",
        join([field_name, vars_str, out_structure_str]),
        "}",
    )
    GraphQLite.rungql(gql_str, operation_name, vars, extra)[Symbol(field_name)]
end