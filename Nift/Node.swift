import struct Foundation.UUID

public protocol Node: class {
    var type: UUID { get }
    var properties: Any { get }
    var children: [Node] { get }
    var key: String? { get }
}
