public func instantiate(node: Node, parent: NodeInstance? = nil, index: Int) -> NodeInstance {
    let instance = node.InstanceType.init(node: node, parent: parent, index: index)

    return instance
}

public func instantiate(nodes: [Node], parent: NodeInstance? = nil, index: Int) -> [NodeInstance] {
    var count = index

    return nodes.map({
        let instance = instantiate(node: $0, parent: parent, index: count)

        count += instance.mount().count

        return instance
    })
}
