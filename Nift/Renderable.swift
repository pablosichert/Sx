public protocol Renderable {
    init(properties: Any, children: [Node])
    func render() -> [Node]
}
