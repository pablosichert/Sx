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

private func insert(instance: NodeInstance) -> (
    count: Int,
    inserts: [Operation.Insert]
) {
    var inserts: [Operation.Insert] = []
    let mounts = instance.mount()

    for i in 0 ..< mounts.count {
        let mount = mounts[i]

        inserts.append(
            Operation.Insert(mount: mount, index: instance.index + 1)
        )
    }

    return (
        count: mounts.count,
        inserts: inserts
    )
}

private func remove(instance: NodeInstance) -> [Operation.Remove] {
    var removes: [Operation.Remove] = []
    let mounts = instance.mount()

    for i in 0 ..< mounts.count {
        let mount = mounts[i]

        removes.append(
            Operation.Remove(mount: mount, index: instance.index + i)
        )
    }

    return removes
}

private func replace(new: NodeInstance, old: NodeInstance) -> (
    count: Int,
    inserts: [Operation.Insert],
    removes: [Operation.Remove],
    replaces: [Operation.Replace]
) {
    var inserts: [Operation.Insert] = []
    var removes: [Operation.Remove] = []
    var replaces: [Operation.Replace] = []

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
        removes.append(
            Operation.Remove(mount: mountsOld[i - leadingOld.lowerBound], index: i)
        )
    }

    for i in leadingNew {
        inserts.append(
            Operation.Insert(mount: mountsNew[i - leadingNew.lowerBound], index: i)
        )
    }

    if let shared = shared, let trailingOld = trailingOld, let trailingNew = trailingNew {
        for i in shared {
            replaces.append(
                Operation.Replace(
                    old: mountsOld[leadingOld.count + i - shared.lowerBound],
                    new: mountsNew[leadingNew.count + i - shared.lowerBound],
                    index: i
                )
            )
        }

        for i in old {
            removes.append(
                Operation.Remove(
                    mount: mountsOld[leadingOld.count + shared.count + i - trailingOld.lowerBound],
                    index: i
                )
            )
        }

        for i in new {
            inserts.append(
                Operation.Insert(
                    mount: mountsNew[leadingNew.count + shared.count + i - trailingNew.lowerBound],
                    index: i
                )
            )
        }
    }

    return (
        count: mountsNew.count,
        inserts: inserts,
        removes: removes,
        replaces: replaces
    )
}

private func update(index: Int, instance: NodeInstance, node: Node) -> (
    count: Int,
    reorders: [Operation.Reorder]
) {
    instance.update(node: node)

    let mounts = instance.mount()
    var reorders: [Operation.Reorder] = []

    if instance.index != index {
        for i in 0 ..< mounts.count {
            let mount = mounts[i]

            reorders.append(
                Operation.Reorder(mount: mount, from: instance.index + i, to: index + i)
            )
        }

        updateIndices(index: index, instance: instance)
    }

    return (mounts.count, reorders: reorders)
}

func reconcile(instances: [NodeInstance], nodes: [Node], parent: NodeInstance) -> ([NodeInstance], Operations) {
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
                let (count, reorders) = update(index: index, instance: instance, node: node)

                index += count
                operations.reorders += reorders

                return instance
            } else {
                let new = instantiate(node: node, parent: parent, index: index)

                let (count, inserts, removes, replaces) = replace(
                    new: new,
                    old: instance
                )

                index += count
                operations.inserts += inserts
                operations.removes += removes
                operations.replaces += replaces

                return new
            }
        }

        let new = instantiate(node: node, parent: parent, index: index)
        let (count, inserts) = insert(instance: new)

        index += count
        operations.inserts += inserts

        return new
    })

    for instance in keysToInstances.values {
        operations.removes += remove(instance: instance)
    }

    for instance in rest {
        operations.removes += remove(instance: instance)
    }

    return (instances, operations)
}
