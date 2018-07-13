public protocol Node {
    var properties: Any { get }
    var children: [Node] { get }
}
