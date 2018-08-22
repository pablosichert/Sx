public class Operations {
    var inserts: [Operation.Insert] = []
    var removes: [Operation.Remove] = []
    var reorders: [Operation.Reorder] = []
    var replaces: [Operation.Replace] = []

    var isEmpty: Bool {
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
