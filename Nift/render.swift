public func render(_ node: CompositeNode) -> Any {
    let instance = node.create(node.properties, node.children)

    switch instance {
    case let instance as CompositeComponentSingle:
        return render(instance.render())
    case let instance as CompositeComponentMultiple:
        return render(instance.render())
    default:
        return []
    }
}

public func render(_ node: NativeNode) -> Any {
    let children = node.children.map({ render($0) })
    let instance = node.create(node.properties, children)

    return instance.render()
}

public func render(_ node: Node) -> Any {
    switch node {
    case is NativeNode:
        return render(node as! NativeNode)
    case is CompositeNode:
        return render(node as! CompositeNode)
    default:
        return []
    }
}

public func render(_ nodes: [Node]) -> [Any] {
    return nodes.map({ render($0) })
}
