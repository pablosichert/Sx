open class Base: Composite {
    public struct NoProperties {
        public init() {}
    }

    public typealias Create = (Any, [Node]) -> Renderable
    public var create: Create
    public var properties: Any
    public var children: [Node]

    public init(create: @escaping Create, properties: Any = NoProperties(), _ children: [Node] = []) {
        self.create = create
        self.properties = properties
        self.children = children
    }
}
