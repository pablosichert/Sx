open class Composite: Node {
    public typealias Composite = CompositeComponent
    public typealias Create = (Any, [Node]) -> Renderable
    public typealias Renderable = CompositeComponentRenderable

    public let children: [Node]
    public let ComponentType: Any.Type
    public let equal: (Any, Any) -> Bool
    public let InstanceType: NodeInstance.Type = CompositeInstance.self
    public let key: String?
    public let properties: Any
    public let state: Any

    public init<Properties, State>(
        _ RenderableType: Renderable.Type,
        key: String?,
        properties: Properties,
        state: State,
        _ children: [Node] = []
    ) where Properties: Equatable {
        self.children = children
        self.ComponentType = RenderableType
        self.equal = Equal<Properties>.call
        self.key = key
        self.properties = properties
        self.state = state
    }
}

public protocol CompositeComponentRenderableBase {
    var rerender: () -> Void { get set }

    init(properties: Any, state: Any, children: [Node])

    func update(properties: Any)

    func update(children: [Node])

    func update(properties: Any, children: [Node])
}

public protocol CompositeComponentRenderable: CompositeComponentRenderableBase {
    func render() -> [Node?]
}

open class CompositeComponent<Properties: Equatable, State: Equatable>: CompositeComponentRenderableBase {
    public var properties: Properties
    public var children: [Node]
    public var rerender = {}
    public var state: State

    public required convenience init(properties: Any, state: Any, children: [Node]) {
        self.init(
            properties: properties as! Properties,
            state: state as! State,
            children: children
        )
    }

    public init(properties: Properties, state: State, children: [Node]) {
        self.properties = properties
        self.state = state
        self.children = children
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
