import struct Foundation.UUID

open class Native: NativeNode {
    public typealias Component = NativeComponent

    public struct NoProperties {
        public init() {}
    }

    public var type: UUID
    public var create: Native.Create
    public var properties: Any
    public var children: [Node]
    public var key: String?

    public init(type: UUID, create: @escaping Native.Create, properties: Any = NoProperties(), key: String? = nil, _ children: [Node] = []) {
        self.type = type
        self.create = create
        self.properties = properties
        self.children = children
        self.key = key
    }
}

public protocol NativeNode: Node {
    typealias Create = (Any, [Any]) -> NativeComponent
    var create: Create { get }
}

public protocol NativeComponent {
    init(properties: Any, children: [Any])

    func render() -> Any

    func update(properties: Any, operations: [Operation])

    func remove(_ mount: Any)
}
