protocol NodeInstance: class {
    var parent: NodeInstance? { get set }
    var node: Node { get }

    func mount() -> [Any]

    func remove(_ mount: Any)

    func force()

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

    func force() {
        parent?.force()
    }
}

class CompositeInstance: NodeInstance {
    weak var parent: NodeInstance?
    var node: Node
    var component: Composite.Interface
    var children: [NodeInstance]

    init(_ node: Composite) {
        let component = node.create.call(node.properties, node.children)
        let children = instantiate(component.render())

        self.node = node
        self.component = component
        self.children = children

        for child in children {
            child.parent = self
        }
    }

    func rerender(_ node: Node) {
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

            return instantiate(child, parent: self)
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

    func force() {
        rerender(node)

        parent?.force()
    }

    func update(_ node: Node) {
        let newProperties = !self.node.equal(self.node.properties, node.properties)
        let newChildren = self.node.children != node.children

        switch (newProperties, newChildren) {
        case (false, false):
            return
        case (true, false):
            component.update(properties: node.properties)
        case (false, true):
            component.update(children: node.children)
        case (true, true):
            component.update(properties: node.properties, children: node.children)
        }

        rerender(node)
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
    var component: Native.Component
    var children: [NodeInstance]

    init(_ node: Native) {
        let children = node.children.map({ instantiate($0) })
        let mounts = children.flatMap({ $0.mount() })
        let component = node.create.call(node.properties, mounts)

        self.node = node
        self.component = component
        self.children = children

        for child in children {
            child.parent = self
        }
    }

    func force(_ node: Node) {
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

                    let instance = instantiate(child, parent: self)

                    operations.append(
                        Operation.replace(old: old, new: instance.mount())
                    )

                    return instance
                }
            }

            let instance = instantiate(child, parent: self)

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

        let newProperties = !self.node.equal(self.node.properties, node.properties)
        let newOperations = operations.count > 0

        switch (newProperties, newOperations) {
        case (false, false):
            break
        case (true, false):
            component.update(properties: node.properties)
        case (false, true):
            component.update(operations: operations)
        case (true, true):
            component.update(properties: node.properties, operations: operations)
        }

        self.node = node
        self.children = children
    }

    func force() {
        force(node)
    }

    func update(_ node: Node) {
        if self.node == node {
            return
        }

        force(node)
    }

    func mount() -> [Any] {
        return [component.render()]
    }

    func remove(_ mount: Any) {
        component.remove(mount)
    }
}

func instantiate(_ node: Node, parent: NodeInstance) -> NodeInstance {
    let instance = instantiate(node)
    instance.parent = parent

    return instance
}

func instantiate(_ node: Composite) -> CompositeInstance {
    let instance = CompositeInstance(node)

    instance.component.rerender = { [unowned instance] in
        instance.force()
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
