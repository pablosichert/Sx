open class Composite: CompositeNode {
    public typealias Component = CompositeComponent

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

public protocol CompositeNode: Node {
    typealias Create = (Any, [Node]) -> CompositeComponent
    var create: Create { get }
}

public protocol CompositeComponent {
    init(properties: Any, children: [Node])
    func render() -> [Node]
}
