import struct Foundation.UUID

open class Composite: Node {
    public typealias Create = (Any, [Node]) -> Renderable
    public typealias Renderable = CompositeComponentRenderable
    public typealias Composite = CompositeComponent

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

public protocol CompositeComponentRenderableBase {
    var rerender: () -> Void { get set }

    func update(properties: Any)

    func update(children: [Node])

    func update(properties: Any, children: [Node])
}

public protocol CompositeComponentRenderable: CompositeComponentRenderableBase {
    init(properties: Any, children: [Node])

    func render() -> [Node]
}

open class CompositeComponent<Properties: Equatable, State: Equatable>: CompositeComponentRenderableBase {
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
        if let properties = properties as? Properties {
            update(properties: properties)
        }
    }

    public func update(properties: Properties) {
        self.properties = properties
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
