typealias TryMap<Key: Hashable, Value> = (map: [Key: Value], rest: [Value])

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

    return (map: keysToInstances, rest: rest)
}
