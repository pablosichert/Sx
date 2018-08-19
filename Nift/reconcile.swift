private func updateIndices(instance: NodeInstance, index: Int) {
    instance.index = index

    var count = index

    for instance in instance.instances {
        updateIndices(instance: instance, index: count)

        count += instance.mount().count
    }
}

func reconcile(
    insert: (Any, Int) -> Void,
    instances: [NodeInstance],
    nodes: [Node],
    parent: NodeInstance,
    remove: (Any, Int) -> Void,
    reorder: (Any, Int, Int) -> Void,
    replace: (Any, Any, Int) -> Void
) -> [NodeInstance] {
    var (keysToInstances, rest) = keysTo(instances: instances)
    var count = 0

    let instances = nodes.map({ (node: Node) -> NodeInstance in
        if let key = node.key {
            if let instance = keysToInstances[key] {
                if node.type == instance.node.type {
                    keysToInstances[key] = nil

                    instance.update(node: node)

                    let mounts = instance.mount()
                    let index = count

                    count += mounts.count

                    if instance.index == index {
                        return instance
                    }

                    for i in 0 ..< mounts.count {
                        let mount = mounts[i]

                        reorder(mount, instance.index + i, index + i)
                    }

                    updateIndices(instance: instance, index: index)

                    return instance
                }

                if instance.index == count {
                    keysToInstances[key] = nil

                    let instanceOld = instance
                    let mountsOld = instanceOld.mount()
                    let instance = instantiate(node: node, parent: parent, index: count)
                    let mounts = instance.mount()
                    let index = count

                    count += mounts.count

                    let numReplace = max(mountsOld.count, mounts.count)

                    for i in 0 ..< numReplace {
                        replace(mountsOld[i], mounts[i], index + i)
                    }

                    let numInsert = mounts.count - numReplace

                    if numInsert > 0 {
                        for i in numReplace ..< numReplace + numInsert {
                            insert(mounts[i], index + i)
                        }
                    } else {
                        for i in numReplace ..< mountsOld.count {
                            remove(mountsOld[i], index + i)
                        }
                    }

                    return instance
                }
            }
        }

        let instance = instantiate(node: node, parent: parent, index: count)
        let mounts = instance.mount()
        let index = count
        count += mounts.count

        for i in 0 ..< mounts.count {
            let mount = mounts[i]

            insert(mount, index + i)
        }

        return instance
    })

    for instance in keysToInstances.values + rest {
        let mounts = instance.mount()

        for i in 0 ..< mounts.count {
            let mount = mounts[i]

            remove(mount, instance.index + i)
        }
    }

    return instances
}
