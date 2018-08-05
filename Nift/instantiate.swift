protocol NodeInstance: class {
    var parent: NodeInstance? { get set }
    var node: Node { get }

    func mount() -> [Any]

    func remove(_ mount: Any)

    func update(_ node: Node)
}

class InvalidInstance: NodeInstance {
    weak var parent: NodeInstance?
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
    weak var parent: NodeInstance?
    var node: Node
    var component: Composite.Interface
    var children: [NodeInstance]

    init(_ node: Composite) {
        let component = node.create.function(node.properties, node.children)
        let children = instantiate(component.render())

        self.node = node
        self.component = component
        self.children = children

        for child in children {
            child.parent = self
        }
    }

    func update(_ node: Node) {
        force(node)
    }

    func force(_ node: Node) {
        var (instances, rest) = keysTo(instances: self.children)

        let children = component.render().map({ (child: Node) -> NodeInstance in
            if let key = child.key {
                if let instance = instances[key] {
                    if child.type == instance.node.type {
                        instances[key] = nil

                        instance.update(child)

                        return instance
                    }
                }
            }

            let instance = instantiate(child)
            instance.parent = self

            return instance
        })

        for instance in instances.values + rest {
            let mounts = instance.mount()

            for mount in mounts {
                remove(mount)
            }
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
    weak var parent: NodeInstance?
    var node: Node
    var component: NativeComponent
    var children: [NodeInstance]

    init(_ node: Native) {
        let children = node.children.map({ instantiate($0) })
        let mounts = children.flatMap({ $0.mount() })
        let component = node.create.function(node.properties, mounts)

        self.node = node
        self.component = component
        self.children = children

        for child in children {
            child.parent = self
        }
    }

    func update(_ node: Node) {
        var (instances, rest) = keysTo(instances: self.children.enumerated())

        var operations: [Operation] = []

        let children = node.children.enumerated().map({ (index: Int, child: Node) -> NodeInstance in
            if let key = child.key {
                if let (indexOld, instance) = instances[key] {
                    if child.type == instance.node.type {
                        instances[key] = nil

                        instance.update(child)

                        if index == indexOld {
                            return instance
                        }

                        let mounts = instance.mount()

                        for mount in mounts {
                            operations.append(
                                Operation.reorder(mount: mount, index: index)
                            )
                        }

                        return instance
                    }

                    let old = instance.mount()

                    let instance = instantiate(child)

                    operations.append(
                        Operation.replace(old: old, new: instance.mount())
                    )

                    return instance
                }
            }

            let instance = instantiate(child)

            let mounts = instance.mount()

            for mount in mounts {
                operations.append(
                    Operation.add(mount: mount)
                )
            }

            return instance
        })

        for (_, instance) in instances.values + rest {
            let mounts = instance.mount()

            for mount in mounts {
                operations.append(
                    Operation.remove(mount: mount)
                )
            }
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

func instantiate(_ node: Composite) -> CompositeInstance {
    let instance = CompositeInstance(node)

    instance.component.rerender = { [unowned instance, unowned node] in
        instance.force(node)
    }

    return instance
}

func instantiate(_ node: Native) -> NativeInstance {
    return NativeInstance(node)
}

func instantiate(_ node: Node) -> NodeInstance {
    switch node {
    case let node as Native:
        return instantiate(node)
    case let node as Composite:
        return instantiate(node)
    default:
        return InvalidInstance(node)
    }
}

func instantiate(_ nodes: [Node]) -> [NodeInstance] {
    return nodes.map({ instantiate($0) })
}
