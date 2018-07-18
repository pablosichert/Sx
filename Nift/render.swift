protocol NodeInstance {
    func mount() -> Any
}

class InvalidInstance: NodeInstance {
    let invalid: Any

    init(_ invalid: Any) {
        self.invalid = invalid
    }

    func mount() -> Any {
        return invalid
    }
}

class CompositeInstance: NodeInstance {
    var node: CompositeNode
    var instance: CompositeComponent
    var rendered: [NodeInstance]

    init(_ node: CompositeNode) {
        let node = node
        let instance = node.create(node.properties, node.children)
        let rendered: [NodeInstance] = {
            switch instance {
            case let instance as CompositeComponentSingle:
                return [instantiate(instance.render())]
            case let instance as CompositeComponentMultiple:
                return instantiate(instance.render())
            default:
                return [InvalidInstance(instance)]
            }
        }()

        self.node = node
        self.instance = instance
        self.rendered = rendered
    }

    func mount() -> Any {
        return rendered.compactMap({ $0.mount() })
    }
}

class NativeInstance: NodeInstance {
    var node: NativeNode
    var instance: NativeComponent
    var rendered: [Any]

    init(_ node: NativeNode) {
        let rendered = node.children.map({ instantiate($0) })
        let children = rendered.map({ $0.mount() })
        let instance = node.create(node.properties, children)

        self.node = node
        self.instance = instance
        self.rendered = rendered
    }

    func mount() -> Any {
        return instance.render()
    }
}

func instantiate(_ node: CompositeNode) -> CompositeInstance {
    return CompositeInstance(node)
}

func instantiate(_ node: NativeNode) -> NativeInstance {
    return NativeInstance(node)
}

func instantiate(_ node: Node) -> NodeInstance {
    switch node {
    case let node as NativeNode:
        return instantiate(node)
    case let node as CompositeNode:
        return instantiate(node)
    default:
        return InvalidInstance(node)
    }
}

func instantiate(_ nodes: [Node]) -> [NodeInstance] {
    return nodes.map({ instantiate($0) })
}

public func render(_ node: CompositeNode) -> Any {
    let instance = instantiate(node)
    let mount = instance.mount()

    switch instance.instance {
    case is CompositeComponentSingle:
        return (mount as! [Any])[0]
    case is CompositeComponentMultiple:
        return mount
    default:
        return mount
    }
}

public func render(_ node: NativeNode) -> Any {
    let instance = instantiate(node)
    let mount = instance.mount()

    return mount
}

public func render(_ node: Node) -> Any {
    switch node {
    case let node as NativeNode:
        return render(node)
    case let node as CompositeNode:
        return render(node)
    default:
        return []
    }
}

public func render(_ nodes: [Node]) -> [Any] {
    return nodes.map({ render($0) })
}
