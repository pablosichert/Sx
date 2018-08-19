public struct Operations {
    var inserts: [Operation.Insert] = []
    var removes: [Operation.Remove] = []
    var reorders: [Operation.Reorder] = []
    var replaces: [Operation.Replace] = []

    var isEmpty: Bool {
        return inserts.isEmpty && removes.isEmpty && reorders.isEmpty && replaces.isEmpty
    }
}
