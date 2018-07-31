import struct Foundation.UUID

open class Composite: CompositeNode {
    public typealias Interface = CompositeComponentInterface
    public typealias Component = CompositeComponent

    public struct NoProperties {
        public init() {}
    }

    public var type: UUID
    public var create: Composite.Create
    public var properties: Any
    public var children: [Node]
    public var key: String?

    public init(type: UUID, create: @escaping Composite.Create, properties: Any = NoProperties(), key: String? = nil, _ children: [Node] = []) {
        self.type = type
        self.create = create
        self.properties = properties
        self.children = children
        self.key = key
    }
}

public protocol CompositeNode: Node {
    typealias Create = (Any, [Node]) -> Composite.Interface
    var create: Create { get }
}

public protocol CompositeComponentInterface {
    var rerender: () -> Void { get set }

    init(properties: Any, children: [Node])

    func update(properties: Any)

    func render() -> [Node]
}

open class CompositeComponent<State, Properties> {
    public var rerender = {}
    public var state: State
    public var properties: Properties

    public init(state: State, properties: Properties) {
        self.state = state
        self.properties = properties
    }

    public func setState(_ state: State) {
        self.state = state
        self.rerender()
    }
}
