function getiterators(data)
    Dict([k, Iterators.Stateful(v)] for (k, v) in data)
end

initial = initdata(nodes)
fulfill(initial, nodes[1])
fulfill(initial, nodes[2])
fulfill(initial, nodes[3])
fulfill(initial, nodes[4])
fulfill(initial, nodes[5])
fulfill(initial, nodes[6])
fulfill(initial, nodes[7])
fulfill(initial, nodes[8])
fulfill(initial, nodes[9])
fulfill(initial, nodes[10])
fulfill(initial, nodes[11])
fulfill(initial, nodes[12])