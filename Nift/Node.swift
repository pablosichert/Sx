import struct Foundation.UUID

open class Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return (
            lhs.type == rhs.type &&
                lhs.key == rhs.key &&
                lhs.equal(lhs.properties, rhs.properties) &&
                lhs.children == rhs.children
        )
    }

    public let children: [Node]
    public let key: String?
    public let properties: Any
    public let equal: (Any, Any) -> Bool
    public let type: UUID

    public init(
        children: [Node],
        equal: @escaping (Any, Any) -> Bool,
        key: String?,
        properties: Any,
        type: UUID
    ) {
        self.children = children
        self.equal = equal
        self.key = key
        self.properties = properties
        self.type = type
    }
}
