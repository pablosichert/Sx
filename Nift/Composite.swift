open class CompositeBase: Composite {
    public struct NoProperties {
        public init() {}
    }

    public var create: Composite.Create
    public var properties: Any
    public var children: [Node]

    public init(create: @escaping Composite.Create, properties: Any = NoProperties(), _ children: [Node] = []) {
        self.create = create
        self.properties = properties
        self.children = children
    }
}

public protocol CompositeRenderable {
    init(properties: Any, children: [Node])
    func render() -> [Node]
}

public protocol Composite: Node {
    typealias Base = CompositeBase
    typealias Renderable = CompositeRenderable
    typealias Create = (Any, [Node]) -> Renderable
    var create: Create { get }
}
