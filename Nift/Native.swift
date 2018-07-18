open class Native: NativeNode {
    public typealias Component = NativeComponent

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

public protocol NativeNode: Node {
    typealias Create = (Any, [Any]) -> NativeComponent
    var create: Create { get }
}

public protocol NativeComponent {
    init(properties: Any, children: [Any])
    func render() -> Any
}
