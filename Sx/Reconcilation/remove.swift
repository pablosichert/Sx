func remove(
    instance: NodeInstance,
    remove: Remove
) {
    let mounts = instance.mount()

    for i in 0 ..< mounts.count {
        let mount = mounts[i]

        remove((mount: mount, index: instance.index + i))
    }
}
