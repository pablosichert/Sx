func insert(
    instance: NodeInstance,
    insert: Insert
) -> Int {
    let mounts = instance.mount()

    for i in 0 ..< mounts.count {
        let mount = mounts[i]

        insert((mount: mount, index: instance.index + 1))
    }

    return mounts.count
}
