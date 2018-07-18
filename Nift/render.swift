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
    var component: CompositeComponent
    var children: [NodeInstance]

    init(_ node: CompositeNode) {
        let component = node.create(node.properties, node.children)
        let children: [NodeInstance] = {
            switch component {
            case let component as CompositeComponentSingle:
                return [instantiate(component.render())]
            case let component as CompositeComponentMultiple:
                return instantiate(component.render())
            default:
                return [InvalidInstance(component)]
            }
        }()

        self.node = node
        self.component = component
        self.children = children
    }

    func mount() -> Any {
        return children.compactMap({ $0.mount() })
    }
}

class NativeInstance: NodeInstance {
    var node: NativeNode
    var component: NativeComponent
    var children: [NodeInstance]

    init(_ node: NativeNode) {
        let children = node.children.map({ instantiate($0) })
        let mounts = children.map({ $0.mount() })
        let component = node.create(node.properties, mounts)

        self.node = node
        self.component = component
        self.children = children
    }

    func mount() -> Any {
        return component.render()
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

    switch instance.component {
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
