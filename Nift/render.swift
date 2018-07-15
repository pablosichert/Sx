public func render(_ node: Composite) -> Any {
    let instance = node.create(node.properties, node.children)

    return render(instance.render())
}

public func render(_ node: Native) -> Any {
    let mounts = node.children.map({ render($0) })
    let instance = node.create(node.properties, mounts)

    return instance.render()
}

public func render(_ node: Node) -> Any {
    switch node {
    case is Native:
        return render(node as! Native)
    case is Composite:
        return render(node as! Composite)
    default:
        return []
    }
}

public func render(_ nodes: [Node]) -> [Any] {
    return nodes.map({ render($0) })
}
