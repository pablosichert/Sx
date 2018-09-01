public protocol NodeInstance {
    var node: Node { get }
    var index: Int { get set }
    var instances: [NodeInstance] { get }
    var parent: NodeInstance? { get set }

    func mount() -> [Any]

    mutating func update(node: Node)

    mutating func update(operations: Operations)
}
