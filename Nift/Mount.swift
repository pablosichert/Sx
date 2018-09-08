import protocol Reconcilation.NodeInstance
import func Reconcilation.instantiate

public struct Mount<Mount> {
    let instances: [NodeInstance]

    public var elements: [Mount] {
        return instances.flatMap({ $0.mount() }) as! [Mount]
    }

    public init(_ nodes: [Node]) {
        instances = instantiate(nodes: nodes, index: 0)
    }

    public init(_ node: Node) {
        self.init([node])
    }

    public subscript(index: Int) -> Mount {
        return elements[index]
    }
}
