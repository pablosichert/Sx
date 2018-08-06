import struct Foundation.UUID

open class Native: Node {
    public typealias Init = (Any, [Any]) -> Native.Component
    public typealias Create = Handler<Init>
    public typealias Component = NativeComponent

    public struct NoProperties {
        public init() {}
    }

    public let create: Create

    public init(
        create: Native.Create,
        equal: @escaping (Any, Any) -> Bool,
        key: String? = nil,
        properties: Any = NoProperties(),
        _ children: [Node] = []
    ) {
        self.create = create

        super.init(
            children: children,
            equal: equal,
            key: key,
            properties: properties,
            type: create.id
        )
    }
}

public protocol NativeComponent {
    init(properties: Any, children: [Any])

    func update(properties: Any)

    func update(operations: [Operation])

    func update(properties: Any, operations: [Operation])

    func remove(_ mount: Any)

    func render() -> Any
}
