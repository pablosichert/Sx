import struct Foundation.UUID

open class Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return (
            lhs.type == rhs.type &&
                lhs.key == rhs.key &&
                lhs.children == rhs.children
        )
    }

    public let children: [Node]
    public let key: String?
    public let properties: Any
    public let type: UUID

    public init(children: [Node], key: String?, properties: Any, type: UUID) {
        self.children = children
        self.key = key
        self.properties = properties
        self.type = type
    }
}
