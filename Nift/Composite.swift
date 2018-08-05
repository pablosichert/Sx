import struct Foundation.UUID

open class Composite: Node {
    public typealias Create = (Any, [Node]) -> Composite.Interface
    public typealias Interface = CompositeComponentInterface
    public typealias Component = CompositeComponent

    public struct NoProperties {
        public init() {}
    }

    public let create: Create

    public init(
        type: UUID,
        create: @escaping Composite.Create,
        properties: Any = NoProperties(),
        key: String? = nil,
        _ children: [Node] = []
    ) {
        self.create = create

        super.init(children: children, key: key, properties: properties, type: type)
    }
}

public protocol CompositeComponentInterfaceBase {
    var rerender: () -> Void { get set }

    func equal(a: Any, b: Any) -> Bool // swiftlint:disable:this identifier_name
}

public protocol CompositeComponentInterface: CompositeComponentInterfaceBase {
    init(properties: Any, children: [Node])

    func update(properties: Any)

    func render() -> [Node]
}

open class CompositeComponent<Properties: Equatable, State: Equatable>: CompositeComponentInterfaceBase {
    public var properties: Properties
    public var rerender = {}
    public var state: State

    public init(properties: Properties, state: State) {
        self.properties = properties
        self.state = state
    }

    public func equal(a: Any, b: Any) -> Bool { // swiftlint:disable:this identifier_name
        return equal(a: a as! Properties, b: b as! Properties)
    }

    public func equal(a: Properties, b: Properties) -> Bool { // swiftlint:disable:this identifier_name
        return a == b
    }

    public func setState(_ state: State) {
        if self.state == state {
            return
        }

        self.state = state
        self.rerender()
    }
}
