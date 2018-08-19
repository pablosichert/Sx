protocol NodeInstance: class {
    var node: Node { get }
    var index: Int { get set }
    var instances: [NodeInstance] { get }
    var parent: NodeInstance? { get set }

    func insert(mount: Any, index: Int)

    func mount() -> [Any]

    func remove(mount: Any, index: Int)

    func reorder(mount: Any, from: Int, to: Int)

    func replace(old: Any, new: Any, index: Int)

    func update(node: Node)
}

class CompositeInstance: NodeInstance {
    var component: Composite.Renderable
    var index: Int
    var instances: [NodeInstance]
    var node: Node
    weak var parent: NodeInstance?

    init(_ node: Node, parent: NodeInstance? = nil, index: Int) {
        let Component = node.Component as! Composite.Renderable.Type
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

    func insert(mount: Any, index: Int) {
        parent?.insert(mount: mount, index: index)
    }

    func mount() -> [Any] {
        return instances.flatMap({ $0.mount() })
    }

    func remove(mount: Any, index: Int) {
        parent?.remove(mount: mount, index: index)
    }

    func reorder(mount: Any, from: Int, to: Int) {
        parent?.reorder(mount: mount, from: from, to: to)
    }

    func replace(old: Any, new: Any, index: Int) {
        parent?.replace(old: old, new: new, index: index)
    }

    func rerender() {
        instances = reconcile(
            insert: insert,
            instances: instances,
            nodes: component.render(),
            parent: self,
            remove: remove,
            reorder: reorder,
            replace: replace
        )
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
}

class NativeInstance: NodeInstance {
    var component: Native.Renderable
    var index: Int
    var instances: [NodeInstance]
    var node: Node
    weak var parent: NodeInstance?

    init(node: Node, parent: NodeInstance? = nil, index: Int) {
        let instances = instantiate(nodes: node.children, index: index)
        let mounts = instances.flatMap({ $0.mount() })
        let Component = node.Component as! Native.Renderable.Type
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

    func insert(mount: Any, index: Int) {
        component.insert(mount: mount, index: index)
    }

    func mount() -> [Any] {
        return [component.render()]
    }

    func remove(mount: Any, index: Int) {
        component.remove(mount: mount, index: index)
    }

    func reorder(mount: Any, from: Int, to: Int) {
        component.reorder(mount: mount, from: from, to: to)
    }

    func replace(old: Any, new: Any, index: Int) {
        component.replace(old: old, new: new, index: index)
    }

    func update(node: Node) {
        var operations = Operations()

        instances = reconcile(
            insert: { mount, index in
                operations.inserts.append(
                    Operation.Insert(mount: mount, index: index)
                )
            },
            instances: instances,
            nodes: node.children,
            parent: self,
            remove: { mount, index in
                operations.removes.append(
                    Operation.Remove(mount: mount, index: index)
                )
            },
            reorder: { mount, from, to in
                operations.reorders.append(
                    Operation.Reorder(mount: mount, from: from, to: to)
                )
            },
            replace: { old, new, index in
                operations.replaces.append(
                    Operation.Replace(old: old, new: new, index: index)
                )
            }
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

        self.node = node
    }
}

func instantiate(composite node: Node, parent: NodeInstance? = nil, index: Int) -> CompositeInstance {
    let instance = CompositeInstance(node, parent: parent, index: index)
    var component = instance.component

    component.rerender = { [unowned instance] in
        instance.rerender()
    }

    return instance
}

func instantiate(native node: Node, parent: NodeInstance? = nil, index: Int) -> NativeInstance {
    return NativeInstance(node: node, parent: parent, index: index)
}

func instantiate(node: Node, parent: NodeInstance? = nil, index: Int) -> NodeInstance {
    switch node.type {
    case .Native:
        return instantiate(native: node, parent: parent, index: index)
    case .Composite:
        return instantiate(composite: node, parent: parent, index: index)
    }
}

func instantiate(nodes: [Node], parent: NodeInstance? = nil, index: Int) -> [NodeInstance] {
    var count = index

    return nodes.map({
        let instance = instantiate(node: $0, parent: parent, index: count)

        count += instance.mount().count

        return instance
    })
}
