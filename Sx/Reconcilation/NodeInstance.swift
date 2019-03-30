public protocol NodeInstance: AnyObject {
    var node: Node { get }
    var index: Int { get set }
    var instances: [NodeInstance] { get }
    var parent: NodeInstance? { get set }

    init(node: Node, parent: NodeInstance?, index: Int)

    func mount() -> [Any]

    func update(node: Node)

    func update(operations: Operations)
}
