protocol NodeInstance: class {
    var parent: NodeInstance? { get set }
    var node: Node { get }

    func mount() -> [Any]

    func remove(_ mount: Any)

    func force()

    func update(_ node: Node)
}

class CompositeInstance: NodeInstance {
    weak var parent: NodeInstance?
    var node: Node
    var component: Composite.Renderable
    var children: [NodeInstance]

    init(_ node: Node) {
        let Component = node.Component as! Composite.Renderable.Type
        let component = Component.init(properties: node.properties, children: node.children)
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
    var component: Native.Renderable
    var children: [NodeInstance]

    init(_ node: Node) {
        let children = node.children.map({ instantiate($0) })
        let mounts = children.flatMap({ $0.mount() })
        let Component = node.Component as! Native.Renderable.Type
        let component = Component.init(properties: node.properties, children: mounts)

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

func instantiate(composite node: Node) -> CompositeInstance {
    let instance = CompositeInstance(node)

    instance.component.rerender = { [unowned instance] in
        instance.force()
    }

    return instance
}

func instantiate(native node: Node) -> NativeInstance {
    return NativeInstance(node)
}

func instantiate(_ node: Node) -> NodeInstance {
    switch node.type {
    case .Native:
        return instantiate(native: node)
    case .Composite:
        return instantiate(composite: node)
    }
}

func instantiate(_ nodes: [Node]) -> [NodeInstance] {
    return nodes.map({ instantiate($0) })
}
