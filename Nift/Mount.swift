import func Reconcilation.instantiate
import protocol Reconcilation.NodeInstance

public struct Mount<T> {
    let instances: [NodeInstance]

    public var elements: [Any] {
        return instances.flatMap({ $0.mount() })
    }

    public init(_ nodes: [Node]) {
        instances = instantiate(nodes: nodes, index: 0)
    }

    public init(_ node: Node) {
        self.init([node])
    }

    public subscript(index: Int) -> T {
        return elements[index] as! T
    }
}
