public struct Operations {
    public var inserts: [Operation.Insert] = []
    public var removes: [Operation.Remove] = []
    public var reorders: [Operation.Reorder] = []
    public var replaces: [Operation.Replace] = []

    public init() {}

    public var isEmpty: Bool {
        return inserts.isEmpty && removes.isEmpty && reorders.isEmpty && replaces.isEmpty
    }

    public mutating func add(insert: (mount: Any, index: Int)) {
        inserts.append(
            Operation.Insert(mount: insert.mount, index: insert.index)
        )
    }

    public mutating func add(remove: (mount: Any, index: Int)) {
        removes.append(
            Operation.Remove(mount: remove.mount, index: remove.index)
        )
    }

    public mutating func add(reorder: (mount: Any, from: Int, to: Int)) {
        reorders.append(
            Operation.Reorder(mount: reorder.mount, from: reorder.from, to: reorder.to)
        )
    }

    public mutating func add(replace: (old: Any, new: Any, index: Int)) {
        replaces.append(
            Operation.Replace(old: replace.old, new: replace.new, index: replace.index)
        )
    }
}
