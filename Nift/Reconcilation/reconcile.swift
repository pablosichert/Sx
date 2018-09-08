public func reconcile(
    instances: [NodeInstance],
    instantiate: ((node: Node, parent: NodeInstance, index: Int)) -> NodeInstance,
    nodes: [Node],
    parent: NodeInstance
) -> (
    instances: [NodeInstance],
    operations: Operations
) {
    var operations = Operations()

    let tryMap = keysTo(instances: instances)
    var keysToInstances = tryMap.map
    var rest = StaticQueue(tryMap.rest)
    var index = 0

    let instances = nodes.map({ (node: Node) -> NodeInstance in
        let instance: NodeInstance?

        if let key = node.key {
            instance = keysToInstances[key]
            keysToInstances[key] = nil
        } else {
            instance = rest.dequeue()
        }

        if let instance = instance {
            if instance.node.type == node.type {
                index += update(
                    index: index,
                    instance: instance,
                    node: node,
                    reorder: { operations.reorder($0) }
                )

                return instance
            } else {
                let new = instantiate((node: node, parent: parent, index: index))

                index += replace(
                    new: new,
                    old: instance,
                    insert: { operations.insert($0) },
                    remove: { operations.remove($0) },
                    replace: { operations.replace($0) }
                )

                return new
            }
        }

        let new = instantiate((node: node, parent: parent, index: index))

        index += insert(
            instance: new,
            insert: { operations.insert($0) }
        )

        return new
    })

    for instance in keysToInstances.values {
        remove(
            instance: instance,
            remove: { operations.remove($0) }
        )
    }

    for instance in rest {
        remove(
            instance: instance,
            remove: { operations.remove($0) }
        )
    }

    return (
        instances: instances,
        operations: operations
    )
}
