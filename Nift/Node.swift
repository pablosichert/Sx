public struct Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return (
            lhs.type == rhs.type &&
                lhs.Component == rhs.Component &&
                lhs.key == rhs.key &&
                lhs.equal(lhs.properties, rhs.properties) &&
                lhs.children == rhs.children
        )
    }

    public let children: [Node]
    public let Component: Any.Type
    public let equal: (Any, Any) -> Bool
    public let key: String?
    public let properties: Any
    public let type: Behavior
}
