private class CompositeInstance: NodeInstance {
    let component: Composite.Renderable
    var index: Int
    var instances: [NodeInstance]
    var node: Node
    weak var parent: NodeInstance?

    init(_ node: Node, parent: NodeInstance? = nil, index: Int) {
        let Component = node.ComponentType as! Composite.Renderable.Type
        let component = Component.init(properties: node.properties, children: node.children)
        let nodes = component.render()
        let instances = instantiate(nodes: nodes, index: index)

        self.component = component
        self.index = index
        self.instances = instances
        self.node = node
        self.parent = parent

        for instance in instances {
            instance.parent = self
        }
    }

    func mount() -> [Any] {
        return instances.flatMap({ $0.mount() })
    }

    func rerender() {
        let (instances, operations) = reconcile(
            instances: self.instances,
            instantiate: instantiate(node:parent:index:),
            nodes: component.render(),
            parent: self
        )

        update(operations: operations)

        self.instances = instances
    }

    func update(node: Node) {
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

    func update(operations: Operations) {
        parent?.update(operations: operations)
    }
}

private class NativeInstance: NodeInstance {
    let component: Native.Renderable
    var index: Int
    var instances: [NodeInstance]
    var node: Node
    weak var parent: NodeInstance?

    init(node: Node, parent: NodeInstance? = nil, index: Int) {
        let instances = instantiate(nodes: node.children, index: index)
        let mounts = instances.flatMap({ $0.mount() })
        let Component = node.ComponentType as! Native.Renderable.Type
        let component = Component.init(properties: node.properties, children: mounts)

        self.component = component
        self.index = index
        self.instances = instances
        self.node = node
        self.parent = parent

        for instance in instances {
            instance.parent = self
        }
    }

    func mount() -> [Any] {
        return [component.render()]
    }

    func update(node: Node) {
        let (instances, operations) = reconcile(
            instances: self.instances,
            instantiate: instantiate(node:parent:index:),
            nodes: node.children,
            parent: self
        )

        let newProperties = !self.node.equal(self.node.properties, node.properties)
        let newOperations = !operations.isEmpty

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
        self.node = node
    }

    func update(operations: Operations) {
        component.update(operations: operations)
    }
}

private func instantiate(composite node: Node, parent: NodeInstance? = nil, index: Int) -> CompositeInstance {
    let instance = CompositeInstance(node, parent: parent, index: index)
    var component = instance.component

    component.rerender = { [unowned instance] in
        instance.rerender()
    }

    return instance
}

private func instantiate(native node: Node, parent: NodeInstance? = nil, index: Int) -> NativeInstance {
    return NativeInstance(node: node, parent: parent, index: index)
}

public func instantiate(node: Node, parent: NodeInstance? = nil, index: Int) -> NodeInstance {
    switch node.type {
    case .Native:
        return instantiate(native: node, parent: parent, index: index)
    case .Composite:
        return instantiate(composite: node, parent: parent, index: index)
    }
}

public func instantiate(nodes: [Node], parent: NodeInstance? = nil, index: Int) -> [NodeInstance] {
    var count = index

    return nodes.map({
        let instance = instantiate(node: $0, parent: parent, index: count)

        count += instance.mount().count

        return instance
    })
}
