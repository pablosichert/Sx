import protocol Reconcilation.Node

public typealias Node = Reconcilation.Node

func != (lhs: [Node], rhs: [Node]) -> Bool {
    return !(lhs == rhs)
}

func == (lhs: [Node], rhs: [Node]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }

    for i in 0 ..< lhs.count where lhs[i] != rhs[i] {
        return false
    }

    return true
}

func != (lhs: Node, rhs: Node) -> Bool {
    return !(lhs == rhs)
}

func == (lhs: Node, rhs: Node) -> Bool {
    return (
        lhs.type == rhs.type &&
            lhs.ComponentType == rhs.ComponentType &&
            lhs.key == rhs.key &&
            lhs.equal(lhs.properties, rhs.properties) &&
            lhs.children == rhs.children
    )
}
