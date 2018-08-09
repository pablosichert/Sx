import struct Foundation.UUID

public struct Native {
    public typealias Create = (Any, [Any]) -> Renderable
    public typealias Renderable = NativeComponentRenderable

    public static func create<Properties>(
        Component: Renderable.Type,
        key: String?,
        properties: Properties,
        _ children: [Node] = []
    ) -> Node where Properties: Equatable {
        return Node(
            children: children,
            Component: Component,
            equal: Equal<Properties>.call,
            key: key,
            properties: properties,
            type: .Native
        )
    }
}

public protocol NativeComponentRenderable {
    init(properties: Any, children: [Any])

    func update(properties: Any)

    func update(operations: [Operation])

    func update(properties: Any, operations: [Operation])

    func remove(_ mount: Any)

    func render() -> Any
}
