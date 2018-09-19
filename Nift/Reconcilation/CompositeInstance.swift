class CompositeInstance: NodeInstance {
    let component: Composite.Renderable
    var index: Int
    var instances: [NodeInstance]
    var node: Node
    weak var parent: NodeInstance?

    required init(node: Node, parent: NodeInstance? = nil, index: Int) {
        let Component = node.ComponentType as! Composite.Renderable.Type
        var component = Component.init(properties: node.properties, children: node.children)
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

        component.rerender = { [unowned self] in
            self.rerender()
        }
    }

    func mount() -> [Any] {
        return instances.flatMap({ $0.mount() })
    }

    func rerender() {
        let (instances, operations) = reconcile(
            instances: self.instances,
            instantiate: instantiate,
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
