public protocol Native: Node {
    typealias Create = (Any, [Any]) -> Renderable
    typealias Node = NativeNode
    typealias Renderable = NativeComponentRenderable
}

public struct NativeNode: Node {
    public let children: [Node]
    public let ComponentType: Any.Type
    public let equal: (Any, Any) -> Bool
    public let key: String?
    public let properties: Any
    public let type = Behavior.Native

    public init<Properties>(
        key: String?,
        properties: Properties,
        Type: Native.Renderable.Type,
        _ children: [Node] = []
    ) where Properties: Equatable {
        self.children = children
        self.ComponentType = Type
        self.equal = Equal<Properties>.call
        self.key = key
        self.properties = properties
    }
}

public protocol NativeComponentRenderable {
    init(properties: Any, children: [Any])

    func insert(mount: Any, index: Int)

    func update(properties: Any)

    func update(operations: Operations)

    func update(properties: Any, operations: Operations)

    func remove(mount: Any, index: Int)

    func render() -> Any

    func reorder(mount: Any, from: Int, to: Int)

    func replace(old: Any, new: Any, index: Int)
}
