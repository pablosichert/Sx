public func mount(_ node: Composite) -> Any {
    let instance = node.create(node.properties, node.children)

    return mount(instance.render())
}

public func mount(_ node: Native) -> Any {
    let mounts = node.children.map({ mount($0) })
    let instance = node.create(node.properties, mounts)

    return instance.render()
}

public func mount(_ node: Node) -> Any {
    switch node {
    case is Native:
        return mount(node as! Native)
    case is Composite:
        return mount(node as! Composite)
    default:
        return []
    }
}

public func mount(_ nodes: [Node]) -> [Any] {
    return nodes.map({ mount($0) })
}
