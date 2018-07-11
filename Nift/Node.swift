public protocol Node {
    typealias Create = (Any, [Node]?) -> Renderable
    var create: Create { get }
    var properties: Any { get }
    var children: [Node]? { get }
}
