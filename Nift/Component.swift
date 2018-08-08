public struct Component<Mount> {
    let instances: [NodeInstance]

    public var elements: [Mount] {
        if let elements = instances.flatMap({ $0.mount() }) as? [Mount] {
            return elements
        }

        return []
    }

    public init(_ nodes: [Node]) {
        instances = instantiate(nodes)
    }

    public init(_ node: Node) {
        self.init([node])
    }

    public subscript(index: Int) -> Mount {
        return elements[index]
    }
}
