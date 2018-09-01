private func updateIndices(index: Int, instance: inout NodeInstance) {
    var instance = instance
    instance.index = index

    var index = index

    for var instance in instance.instances {
        updateIndices(index: index, instance: &instance)

        index += instance.mount().count
    }
}

func update(
    index: Int,
    instance: inout NodeInstance,
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

        updateIndices(index: index, instance: &instance)
    }

    return mounts.count
}
