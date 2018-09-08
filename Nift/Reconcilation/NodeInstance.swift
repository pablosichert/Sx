public protocol NodeInstance: class {
    var node: Node { get }
    var index: Int { get set }
    var instances: [NodeInstance] { get }
    var parent: NodeInstance? { get set }

    func mount() -> [Any]

    func update(node: Node)

    func update(operations: Operations)
}
