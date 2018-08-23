public protocol Node {
    var children: [Node] { get }
    var ComponentType: Any.Type { get }
    var equal: (Any, Any) -> Bool { get }
    var key: String? { get }
    var properties: Any { get }
    var type: Behavior { get }
}

func != (lhs: [Node], rhs: [Node]) -> Bool {
    return !(lhs == rhs)
}

func == (lhs: [Node], rhs: [Node]) -> Bool {
    return lhs == rhs
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
