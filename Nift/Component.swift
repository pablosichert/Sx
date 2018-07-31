public class Component<Mount> {
    let instances: [NodeInstance]

    public init(_ nodes: [Node]) {
        instances = instantiate(nodes)
    }

    public convenience init(_ node: Node) {
        self.init([node])
    }

    public func mount() -> [Mount] {
        return instances.flatMap({ $0.mount() }) as! [Mount]
    }
}
