public class NativeInstance: NodeInstance {
    let component: Native.Renderable
    public var index: Int
    public var instances: [NodeInstance]
    public var node: Node
    public weak var parent: NodeInstance?

    public required init(node: Node, parent: NodeInstance? = nil, index: Int) {
        assert(node.InstanceType is NativeInstance.Type)
        assert(node.ComponentType is Native.Renderable.Type)

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

    public func mount() -> [Any] {
        return component.render()
    }

    public func update(node: Node) {
        assert(node.InstanceType is NativeInstance.Type)
        assert(node.ComponentType == self.node.ComponentType)

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
            component.update(properties: (
                next: node.properties,
                previous: self.node.properties
            ))
        case (false, true):
            component.update(operations: operations)
        case (true, true):
            component.update(
                properties: (
                    next: node.properties,
                    previous: self.node.properties
                ),
                operations: operations
            )
        }

        self.instances = instances
        self.node = node
    }

    public func update(operations: Operations) {
        component.update(operations: operations)
    }
}
