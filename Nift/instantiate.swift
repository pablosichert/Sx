protocol NodeInstance: class {
    var parent: NodeInstance? { get set }
    var node: Node { get }

    func mount() -> [Any]

    func remove(_ mount: Any)

    func update(_ node: Node)
}

class CompositeInstance: NodeInstance {
    weak var parent: NodeInstance?
    var node: Node
    var component: Composite.Renderable
    var instances: [NodeInstance]

    init(_ node: Node) {
        let Component = node.Component as! Composite.Renderable.Type
        let component = Component.init(properties: node.properties, children: node.children)
        let nodes = component.render()
        let instances = instantiate(nodes)

        self.node = node
        self.component = component
        self.instances = instances

        for instance in instances {
            instance.parent = self
        }
    }

    func rerender() {
        var (keysToInstances, rest) = keysTo(instances: self.instances)

        let nodes = component.render()

        let instances = nodes.map({ (node: Node) -> NodeInstance in
            if let key = node.key {
                if let instance = keysToInstances[key] {
                    if node.type == instance.node.type {
                        keysToInstances[key] = nil

                        instance.update(node)

                        return instance
                    }
                }
            }

            return instantiate(node, parent: self)
        })

        for instance in keysToInstances.values + rest {
            let mounts = instance.mount()

            for mount in mounts {
                remove(mount)
            }
        }

        self.instances = instances
    }

    func force() {
        rerender()
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

        rerender()

        self.node = node
    }

    func mount() -> [Any] {
        return instances.flatMap({ $0.mount() })
    }

    func remove(_ mount: Any) {
        parent?.remove(mount)
    }
}

class NativeInstance: NodeInstance {
    weak var parent: NodeInstance?
    var node: Node
    var component: Native.Renderable
    var instances: [NodeInstance]

    init(_ node: Node) {
        let instances = node.children.map({ instantiate($0) })
        let mounts = instances.flatMap({ $0.mount() })
        let Component = node.Component as! Native.Renderable.Type
        let component = Component.init(properties: node.properties, children: mounts)

        self.node = node
        self.component = component
        self.instances = instances

        for instance in instances {
            instance.parent = self
        }
    }

    func update(_ node: Node) {
        var (keysToInstances, rest) = keysTo(instances: self.instances.enumerated())

        var operations: [Operation] = []

        let instances = node.children.enumerated().map({ (index: Int, node: Node) -> NodeInstance in
            if let key = node.key {
                if let (indexOld, instance) = keysToInstances[key] {
                    if node.type == instance.node.type {
                        keysToInstances[key] = nil

                        instance.update(node)

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

                    let instance = instantiate(node, parent: self)

                    operations.append(
                        Operation.replace(old: old, new: instance.mount())
                    )

                    return instance
                }
            }

            let instance = instantiate(node, parent: self)

            let mounts = instance.mount()

            for mount in mounts {
                operations.append(
                    Operation.add(mount: mount)
                )
            }

            return instance
        })

        for (_, instance) in keysToInstances.values + rest {
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

        self.instances = instances
    }

    func mount() -> [Any] {
        return [component.render()]
    }

    func remove(_ mount: Any) {
        component.remove(mount)
    }
}

func instantiate(composite node: Node, parent: NodeInstance? = nil) -> CompositeInstance {
    let instance = CompositeInstance(node)
    var component = instance.component

    component.rerender = { [unowned instance] in
        instance.force()
    }

    return instance
}

func instantiate(native node: Node, parent: NodeInstance? = nil) -> NativeInstance {
    return NativeInstance(node)
}

func instantiate(_ node: Node, parent: NodeInstance? = nil) -> NodeInstance {
    switch node.type {
    case .Native:
        return instantiate(native: node, parent: parent)
    case .Composite:
        return instantiate(composite: node, parent: parent)
    }
}

func instantiate(_ nodes: [Node], parent: NodeInstance? = nil) -> [NodeInstance] {
    return nodes.map({ instantiate($0, parent: parent) })
}
