func keysTo(instances: EnumeratedSequence<[NodeInstance]>) -> Dictionary<String, (Int, NodeInstance)> {
    var keysToInstances = Dictionary<String, (Int, NodeInstance)>()

    for (index, instance) in instances {
        if let key = instance.node.key {
            keysToInstances[key] = (index, instance)
        }
    }

    return keysToInstances
}

func keysTo(instances: [NodeInstance]) -> Dictionary<String, NodeInstance> {
    var keysToInstances = Dictionary<String, NodeInstance>()

    for instance in instances {
        if let key = instance.node.key {
            keysToInstances[key] = instance
        }
    }

    return keysToInstances
}

func keysTo(nodes: [Node]) -> Dictionary<String, Node> {
    var keysToNodes = Dictionary<String, Node>()

    for node in nodes {
        if let key = node.key {
            keysToNodes[key] = node
        }
    }

    return keysToNodes
}

protocol NodeInstance {
    var parent: NodeInstance? { get set }
    var node: Node { get }

    func mount() -> [Any]

    func remove(_ mount: Any)

    func update(_ node: Node)
}

class HostInstance: NodeInstance {
    var parent: NodeInstance?
    var node: Node

    init(_ node: Node) {
        self.node = node
    }

    func mount() -> [Any] {
        return []
    }

    func remove(_: Any) {}

    func update(_: Node) {}
}

class InvalidInstance: NodeInstance {
    var parent: NodeInstance?
    var node: Node

    init(_ node: Node) {
        self.node = node
    }

    func mount() -> [Any] {
        return [node]
    }

    func remove(_ mount: Any) {
        parent?.remove(mount)
    }

    func update(_ node: Node) {
        self.node = node
    }
}

class CompositeInstance: NodeInstance {
    var parent: NodeInstance?
    var node: Node
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
                return []
            }
        }()

        self.node = node
        self.component = component
        self.children = children

        for var child in children {
            child.parent = self
        }
    }

    func update(_ node: Node) {
        component.update(properties: node.properties)

        var instances = keysTo(instances: self.children)

        let children = { () -> [Node] in
            switch component {
            case let component as CompositeComponentSingle:
                return [component.render()]
            case let component as CompositeComponentMultiple:
                return component.render()
            default:
                return []
            }
        }().map({ (child: Node) -> NodeInstance in
            if let key = child.key {
                if let instance = instances[key] {
                    if child.type == instance.node.type {
                        instances[key] = nil

                        instance.update(child)

                        return instance
                    }
                }
            }

            var instance = instantiate(child)
            instance.parent = self

            return instance
        })

        for (_, instance) in instances {
            remove(instance.mount())
        }

        self.node = node
        self.children = children
    }

    func mount() -> [Any] {
        return children.flatMap({ $0.mount() })
    }

    func remove(_ mount: Any) {
        parent?.remove(mount)
    }
}

class NativeInstance: NodeInstance {
    var parent: NodeInstance?
    var node: Node
    var component: NativeComponent
    var children: [NodeInstance]

    init(_ node: NativeNode) {
        let children = node.children.map({ instantiate($0) })
        let mounts = children.flatMap({ $0.mount() })
        let component = node.create(node.properties, mounts)

        self.node = node
        self.component = component
        self.children = children

        for var child in children {
            child.parent = self
        }
    }

    func update(_ node: Node) {
        var instances = keysTo(instances: self.children.enumerated())

        var operations: [Operation] = []

        let children = node.children.enumerated().map({ (index: Int, child: Node) -> NodeInstance in
            if let key = child.key {
                if let (indexOld, instance) = instances[key] {
                    if node.type == instance.node.type {
                        instances[key] = nil

                        instance.update(node)

                        if index == indexOld {
                            return instance
                        }

                        operations.append(
                            Operation.reorder(mount: instance.mount(), index: index)
                        )

                        return instance
                    }

                    let old = instance.mount()

                    let instance = instantiate(node)

                    operations.append(
                        Operation.replace(old: old, new: instance.mount())
                    )

                    return instance
                }
            }

            let instance = instantiate(node)

            operations.append(
                Operation.add(mount: instance.mount())
            )

            return instance
        })

        for (_, (_, instance)) in instances {
            operations.append(
                Operation.remove(mount: instance.mount())
            )
        }

        component.update(properties: node.properties, operations: operations)

        self.children = children
    }

    func mount() -> [Any] {
        return [component.render()]
    }

    func remove(_ mount: Any) {
        component.remove(mount)
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
    let host = HostInstance(node)
    let instance = instantiate(node)
    instance.parent = host
    let mount = instance.mount()

    switch instance.component {
    case is CompositeComponentSingle:
        return mount[0]
    case is CompositeComponentMultiple:
        return mount
    default:
        return mount
    }
}

public func render(_ node: NativeNode) -> Any {
    let instance = instantiate(node)
    let mount = instance.mount()

    return mount[0]
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
