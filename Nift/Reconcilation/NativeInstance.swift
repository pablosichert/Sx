class NativeInstance: NodeInstance {
    let component: Native.Renderable
    var index: Int
    var instances: [NodeInstance]
    var node: Node
    weak var parent: NodeInstance?

    required init(node: Node, parent: NodeInstance? = nil, index: Int) {
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
            instantiate: instantiate,
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
