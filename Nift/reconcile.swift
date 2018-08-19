private func updateIndices(instance: NodeInstance, index: Int) {
    instance.index = index

    var count = index

    for instance in instance.instances {
        updateIndices(instance: instance, index: count)

        count += instance.mount().count
    }
}

func reconcile(instances: [NodeInstance], nodes: [Node], parent: NodeInstance) -> ([NodeInstance], Operations) {
    var operations = Operations()
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

                        operations.reorders.append(
                            Operation.Reorder(mount: mount, from: instance.index + i, to: index + i)
                        )
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
                        operations.replaces.append(
                            Operation.Replace(old: mountsOld[i], new: mounts[i], index: index + i)
                        )
                    }

                    let numInsert = mounts.count - numReplace

                    if numInsert > 0 {
                        for i in numReplace ..< numReplace + numInsert {
                            operations.inserts.append(
                                Operation.Insert(mount: mounts[i], index: index + i)
                            )
                        }
                    } else {
                        for i in numReplace ..< mountsOld.count {
                            operations.removes.append(
                                Operation.Remove(mount: mountsOld[i], index: index + i)
                            )
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

            operations.inserts.append(
                Operation.Insert(mount: mount, index: index + 1)
            )
        }

        return instance
    })

    for instance in keysToInstances.values + rest {
        let mounts = instance.mount()

        for i in 0 ..< mounts.count {
            let mount = mounts[i]

            operations.removes.append(
                Operation.Remove(mount: mount, index: instance.index + i)
            )
        }
    }

    return (instances, operations)
}
