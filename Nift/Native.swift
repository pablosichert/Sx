import struct Foundation.UUID

open class Native: Node {
    public typealias Create = (Any, [Any]) -> Renderable
    public typealias Renderable = NativeComponent

    public let create: Create

    public init<Properties>(
        Component: Renderable.Type,
        key: String?,
        properties: Properties,
        _ children: [Node] = []
    ) where Properties: Equatable {
        self.create = Component.init

        super.init(
            children: children,
            equal: Equal<Properties>.call,
            key: key,
            properties: properties,
            type: Component
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
