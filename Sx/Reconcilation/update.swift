private func updateIndices(index: Int, instance: NodeInstance) {
    instance.index = index

    var index = index

    for instance in instance.instances {
        updateIndices(index: index, instance: instance)

        index += instance.mount().count
    }
}

public func update(
    index: Int,
    instance: NodeInstance,
    node: Node,
    reorder: Reorder
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
