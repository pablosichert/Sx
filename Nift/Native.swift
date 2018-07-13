open class NativeBase: Native {
    public struct NoProperties {
        public init() {}
    }

    public var create: Native.Create
    public var properties: Any
    public var children: [Node]

    public init(create: @escaping Native.Create, properties: Any = NoProperties(), _ children: [Node] = []) {
        self.create = create
        self.properties = properties
        self.children = children
    }
}

public protocol NativeRenderable {
    init(properties: Any, children: [Node])
    func render(_ mounts: [Any]) -> Any
}

public protocol Native: Node {
    typealias Base = NativeBase
    typealias Renderable = NativeRenderable
    typealias Create = (Any, [Node]) -> Renderable
    var create: Create { get }
}
