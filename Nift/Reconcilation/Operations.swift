public class Operations {
    public var inserts: [Operation.Insert] = []
    public var removes: [Operation.Remove] = []
    public var reorders: [Operation.Reorder] = []
    public var replaces: [Operation.Replace] = []

    public var isEmpty: Bool {
        return inserts.isEmpty && removes.isEmpty && reorders.isEmpty && replaces.isEmpty
    }

    func insert(mount: Any, index: Int) {
        inserts.append(
            Operation.Insert(mount: mount, index: index)
        )
    }

    func remove(mount: Any, index: Int) {
        removes.append(
            Operation.Remove(mount: mount, index: index)
        )
    }

    func reorder(mount: Any, from: Int, to: Int) {
        reorders.append(
            Operation.Reorder(mount: mount, from: from, to: to)
        )
    }

    func replace(old: Any, new: Any, index: Int) {
        replaces.append(
            Operation.Replace(old: old, new: new, index: index)
        )
    }
}
