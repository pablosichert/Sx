typealias TryMap<Key: Hashable, Value> = ([Key: Value], [Value])

func keysTo(instances: EnumeratedSequence<[NodeInstance]>) -> TryMap<String, (Int, NodeInstance)> {
    var keysToInstances = [String: (Int, NodeInstance)]()
    var rest: [(Int, NodeInstance)] = []

    for (index, instance) in instances {
        if let key = instance.node.key {
            keysToInstances[key] = (index, instance)
        } else {
            rest.append((index, instance))
        }
    }

    return (keysToInstances, rest)
}

func keysTo(instances: [NodeInstance]) -> TryMap<String, NodeInstance> {
    var keysToInstances = [String: NodeInstance]()
    var rest: [NodeInstance] = []

    for instance in instances {
        if let key = instance.node.key {
            keysToInstances[key] = instance
        } else {
            rest.append(instance)
        }
    }

    return (keysToInstances, rest)
}
