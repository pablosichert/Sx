private extension Operations {
    func insert(_ operation: (mount: Any, index: Int)) {
        insert(mount: operation.mount, index: operation.index)
    }

    func remove(_ operation: (mount: Any, index: Int)) {
        remove(mount: operation.mount, index: operation.index)
    }

    func reorder(_ operation: (mount: Any, from: Int, to: Int)) {
        reorder(mount: operation.mount, from: operation.from, to: operation.to)
    }

    func replace(_ operation: (old: Any, new: Any, index: Int)) {
        replace(old: operation.old, new: operation.new, index: operation.index)
    }
}

public func reconcile(
    instances: [NodeInstance],
    instantiate: ((node: Node, parent: NodeInstance, index: Int)) -> NodeInstance,
    nodes: [Node],
    parent: NodeInstance
) -> (
    instances: [NodeInstance],
    operations: Operations
) {
    let operations = Operations()

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

        if var instance = instance {
            if instance.node.type == node.type {
                index += update(
                    index: index,
                    instance: &instance,
                    node: node,
                    reorder: operations.reorder as Reorder
                )

                return instance
            } else {
                let new = instantiate((node: node, parent: parent, index: index))

                index += replace(
                    new: new,
                    old: instance,
                    insert: operations.insert as Insert,
                    remove: operations.remove as Remove,
                    replace: operations.replace as Replace
                )

                return new
            }
        }

        let new = instantiate((node: node, parent: parent, index: index))

        index += insert(
            instance: new,
            insert: operations.insert as Insert
        )

        return new
    })

    for instance in keysToInstances.values {
        remove(
            instance: instance,
            remove: operations.remove as Remove
        )
    }

    for instance in rest {
        remove(
            instance: instance,
            remove: operations.remove as Remove
        )
    }

    return (
        instances: instances,
        operations: operations
    )
}
