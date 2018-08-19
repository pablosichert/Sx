typealias TryMap<Key: Hashable, Value> = ([Key: Value], [Value])

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
