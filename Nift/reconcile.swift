private func updateIndices(index: Int, instance: NodeInstance) {
    instance.index = index

    var index = index

    for instance in instance.instances {
        updateIndices(index: index, instance: instance)

        index += instance.mount().count
    }
}

private func intersect<T>(_ a: CountableRange<T>, _ b: CountableRange<T>) -> CountableRange<T>? {
    let lowerBoundMax = max(a.lowerBound, b.lowerBound)
    let upperBoundMin = min(a.upperBound, b.upperBound)

    let lowerBeforeUpper = lowerBoundMax <= a.upperBound && lowerBoundMax <= b.upperBound
    let upperBeforeLower = upperBoundMin >= a.lowerBound && upperBoundMin >= b.lowerBound

    if lowerBeforeUpper && upperBeforeLower {
        return lowerBoundMax ..< upperBoundMin
    } else {
        return nil
    }
}

private func insert(
    instance: NodeInstance,
    insert: ((mount: Any, index: Int)) -> Void
) -> Int {
    let mounts = instance.mount()

    for i in 0 ..< mounts.count {
        let mount = mounts[i]

        insert((mount: mount, index: instance.index + 1))
    }

    return mounts.count
}

private func remove(
    instance: NodeInstance,
    remove: ((mount: Any, index: Int)) -> Void
) {
    let mounts = instance.mount()

    for i in 0 ..< mounts.count {
        let mount = mounts[i]

        remove((mount: mount, index: instance.index + i))
    }
}

private func replace(
    new: NodeInstance,
    old: NodeInstance,
    insert: ((mount: Any, index: Int)) -> Void,
    remove: ((mount: Any, index: Int)) -> Void,
    replace: ((old: Any, new: Any, index: Int)) -> Void
) -> Int {
    let mountsOld = old.mount()
    let old = old.index ..< old.index + mountsOld.count

    let mountsNew = new.mount()
    let new = new.index ..< new.index + mountsNew.count

    let shared = intersect(old, new)

    let leadingOld: CountableRange<Int>
    let trailingOld: CountableRange<Int>?

    let leadingNew: CountableRange<Int>
    let trailingNew: CountableRange<Int>?

    if let shared = shared {
        leadingOld = old.lowerBound ..< shared.lowerBound
        trailingOld = shared.upperBound ..< old.upperBound

        leadingNew = new.lowerBound ..< shared.lowerBound
        trailingNew = shared.upperBound ..< new.upperBound
    } else {
        leadingOld = old
        trailingOld = nil

        leadingNew = new
        trailingNew = nil
    }

    for i in leadingOld {
        remove((mount: mountsOld[i - leadingOld.lowerBound], index: i))
    }

    for i in leadingNew {
        insert((mount: mountsNew[i - leadingNew.lowerBound], index: i))
    }

    if let shared = shared, let trailingOld = trailingOld, let trailingNew = trailingNew {
        for i in shared {
            replace((
                old: mountsOld[leadingOld.count + i - shared.lowerBound],
                new: mountsNew[leadingNew.count + i - shared.lowerBound],
                index: i
            ))
        }

        for i in old {
            remove((
                mount: mountsOld[leadingOld.count + shared.count + i - trailingOld.lowerBound],
                index: i
            ))
        }

        for i in new {
            insert((
                mount: mountsNew[leadingNew.count + shared.count + i - trailingNew.lowerBound],
                index: i
            ))
        }
    }

    return mountsNew.count
}

private func update(
    index: Int,
    instance: NodeInstance,
    node: Node,
    reorder: ((mount: Any, from: Int, to: Int)) -> Void
) -> Int {
    instance.update(node: node)

    let mounts = instance.mount()

    if instance.index != index {
        for i in 0 ..< mounts.count {
            let mount = mounts[i]

            reorder((mount: mount, from: instance.index + i, to: index + i))
        }

        updateIndices(index: index, instance: instance)
    }

    return mounts.count
}

func reconcile(
    instances: [NodeInstance],
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
                    reorder: {
                        operations.reorders.append(
                            Operation.Reorder(mount: $0.mount, from: $0.from, to: $0.to)
                        )
                    }
                )

                return instance
            } else {
                let new = instantiate(node: node, parent: parent, index: index)

                index += replace(
                    new: new,
                    old: instance,
                    insert: {
                        operations.inserts.append(
                            Operation.Insert(mount: $0.mount, index: $0.index)
                        )
                    },
                    remove: {
                        operations.removes.append(
                            Operation.Remove(mount: $0.mount, index: $0.index)
                        )
                    },
                    replace: {
                        operations.replaces.append(
                            Operation.Replace(old: $0.old, new: $0.new, index: $0.index)
                        )
                    }
                )

                return new
            }
        }

        let new = instantiate(node: node, parent: parent, index: index)

        index += insert(
            instance: new,
            insert: {
                operations.inserts.append(
                    Operation.Insert(mount: $0.mount, index: $0.index)
                )
            }
        )

        return new
    })

    for instance in keysToInstances.values {
        remove(
            instance: instance,
            remove: {
                operations.removes.append(
                    Operation.Remove(mount: $0.mount, index: $0.index)
                )
            }
        )
    }

    for instance in rest {
        remove(
            instance: instance,
            remove: {
                operations.removes.append(
                    Operation.Remove(mount: $0.mount, index: $0.index)
                )
            }
        )
    }

    return (
        instances: instances,
        operations: operations
    )
}
