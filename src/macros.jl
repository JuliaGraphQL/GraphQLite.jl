function getgqltypename(type_name)
    if type_name == "Query"
        return "GQLQuery"
    elseif type_name == "Mutation"
        return "GQLMutation"
    elseif type_name == "Subscription"
        return "GQLSubscription"
    end
    type_name
end

function getrestype(fielddef)
    list_not_null = nothing
    if typeof(fielddef.tipe) == Diana.ListType
        name = "GQLTypeVect"
        list_not_null = false
        if typeof(fielddef.tipe.tipe) == Diana.NonNullType
            el_not_null = true
            # list_nnel
            el_type = fielddef.tipe.tipe.tipe.name.value
        else
            el_not_null = false
            # list_el
            el_type = fielddef.tipe.tipe.name.value
        end
    elseif typeof(fielddef.tipe) == Diana.NonNullType
        if typeof(fielddef.tipe.tipe) == Diana.Diana.ListType
            name = "GQLTypeVect"
            list_not_null = true
            if typeof(fielddef.tipe.tipe.tipe) == Diana.NonNullType
                el_not_null = true
                # nnlist_nnel
                el_type = fielddef.tipe.tipe.tipe.tipe.name.value
            else
                # nnlist_el
                el_not_null = false
                el_type = fielddef.tipe.tipe.tipe.name.value
            end
        else
            name = "GQLType"
            el_not_null = true
            el_type = fielddef.tipe.tipe.name.value
        end
    else
        name = "GQLType"
        el_not_null = false
        el_type = fielddef.tipe.name.value
    end
    el_type_sym = ":$(el_type)"
    if !isnothing(list_not_null)
        return "$(name)($(el_type_sym), $(list_not_null), $(el_not_null))"
    else
        return "$(name)($(el_type_sym), $(el_not_null))"
    end
end

macro schema(str)
    doc = Parse(str)
    exprs = []

    for def in doc.definitions
        type_name = def.name.value
        if def.kind == "InputObjectTypeDefinition"
            # Do nothing.
        else
            gql_type_name = getgqltypename(type_name)
            gql_type_name_symbol = Meta.parse(":$gql_type_name")
            for field in def.fields
                name = field.name.value
                name_symbol = Meta.parse(":$name")
                res_type = Meta.parse(getrestype(field))
                push!(
                    exprs,
                    :(GraphQLite.getschematype(::GQLType{$gql_type_name_symbol}, ::Val{$name_symbol}) = $res_type),
                )
                meta_args = map(field.arguments) do argdef
                    arg_name = argdef.name.value
                    name = "GQLInputType"
                    el_type = nothing
                    el_not_null = false
                    
                    if typeof(argdef.tipe) == Diana.ListType
                        # @TODO handle lists of inputs
                        name = "GQLInputTypeVect"
                        list_not_null = false
                        if typeof(argdef.tipe.tipe) == Diana.NonNullType
                            el_not_null = true
                            # list_nnel
                            el_type = argdef.tipe.tipe.tipe.name.value
                        else
                            el_not_null = false
                            # list_el
                            el_type = argdef.tipe.tipe.name.value
                        end
                    elseif typeof(argdef.tipe) == Diana.NonNullType
                        if typeof(argdef.tipe.tipe) == Diana.Diana.ListType
                            name = "GQLInputTypeVect"
                            list_not_null = true
                            if typeof(argdef.tipe.tipe.tipe) == Diana.NonNullType
                                el_not_null = true
                                # nnlist_nnel
                                el_type = argdef.tipe.tipe.tipe.tipe.name.value
                            else
                                # nnlist_el
                                el_not_null = false
                                el_type = argdef.tipe.tipe.tipe.name.value
                            end
                        else
                            name = "GQLInputType"
                            el_not_null = true
                            el_type = argdef.tipe.tipe.name.value
                        end
                    else
                        name = "GQLInputType"
                        el_not_null = false
                        el_type = argdef.tipe.name.value
                    end

                    #nullable_prefix = el_not_null ? "" : "Nullable"
                    #full_el_type = "$nullable_prefix$el_type"

                    "GQLFieldArg(:$(arg_name), $name(:$el_type, $el_not_null))"
                end
                if !isempty(meta_args)
                    all_meta_args = Meta.parse(string("[", join(meta_args, ", "), "]"))
                    # @show all_meta_args
                    push!(
                        exprs,
                        :(GraphQLite.getfieldargs(::GQLType{$gql_type_name_symbol}, ::Val{$name_symbol}) = $all_meta_args),
                    )
                end
            end
        end
    end

    quote
        for expr in $exprs
            eval(expr)
        end
    end |> esc
end