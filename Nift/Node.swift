import struct Foundation.UUID

public protocol Node: class {
    var children: [Node] { get }
    var key: String? { get }
    var properties: Any { get }
    var type: UUID { get }
}
