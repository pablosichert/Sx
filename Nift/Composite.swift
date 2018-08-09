import struct Foundation.UUID

public struct Composite {
    public typealias Create = (Any, [Node]) -> Renderable
    public typealias Renderable = CompositeComponentRenderable
    public typealias Component = CompositeComponent

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
            type: .Composite
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
        update(properties: properties as! Properties)
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
