public struct Operations {
    public var inserts: [Operation.Insert] = []
    public var removes: [Operation.Remove] = []
    public var reorders: [Operation.Reorder] = []
    public var replaces: [Operation.Replace] = []

    public var isEmpty: Bool {
        return inserts.isEmpty && removes.isEmpty && reorders.isEmpty && replaces.isEmpty
    }

    mutating func insert(mount: Any, index: Int) {
        inserts.append(
            Operation.Insert(mount: mount, index: index)
        )
    }

    mutating func insert(_ operation: (mount: Any, index: Int)) {
        insert(mount: operation.mount, index: operation.index)
    }

    mutating func remove(mount: Any, index: Int) {
        removes.append(
            Operation.Remove(mount: mount, index: index)
        )
    }

    mutating func remove(_ operation: (mount: Any, index: Int)) {
        remove(mount: operation.mount, index: operation.index)
    }

    mutating func reorder(mount: Any, from: Int, to: Int) {
        reorders.append(
            Operation.Reorder(mount: mount, from: from, to: to)
        )
    }

    mutating func reorder(_ operation: (mount: Any, from: Int, to: Int)) {
        reorder(mount: operation.mount, from: operation.from, to: operation.to)
    }

    mutating func replace(old: Any, new: Any, index: Int) {
        replaces.append(
            Operation.Replace(old: old, new: new, index: index)
        )
    }

    mutating func replace(_ operation: (old: Any, new: Any, index: Int)) {
        replace(old: operation.old, new: operation.new, index: operation.index)
    }
}
