import struct Foundation.UUID

open class Composite: Node {
    public typealias Init = (Any, [Node]) -> Composite.Interface
    public typealias Create = Handler<Init>
    public typealias Interface = CompositeComponentInterface
    public typealias Component = CompositeComponent

    public struct NoProperties {
        public init() {}
    }

    public let create: Create

    public init(
        create: Composite.Create,
        equal: @escaping (Any, Any) -> Bool,
        properties: Any = NoProperties(),
        key: String? = nil,
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

public protocol CompositeComponentInterfaceBase {
    var rerender: () -> Void { get set }

    func update(properties: Any)

    func update(children: [Node])

    func update(properties: Any, children: [Node])
}

public protocol CompositeComponentInterface: CompositeComponentInterfaceBase {
    init(properties: Any, children: [Node])

    func render() -> [Node]
}

open class CompositeComponent<Properties: Equatable, State: Equatable>: CompositeComponentInterfaceBase {
    public var properties: Properties
    public var children: [Node]
    public var rerender = {}
    public var state: State

    public init(properties: Properties, state: State, _ children: [Node]) {
        self.properties = properties
        self.children = children
        self.state = state
    }

    public func update(properties: Any) {
        self.properties = properties as! Properties
    }

    public func update(children: [Node]) {
        self.children = children
    }

    public func update(properties: Any, children: [Node]) {
        update(properties: properties)
        update(children: children)
    }

    public func setState(_ state: State) {
        if self.state == state {
            return
        }

        self.state = state
        self.rerender()
    }
}
