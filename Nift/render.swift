public func render(_ root: Node) {
    for case let (property?, value) in Mirror(reflecting: root.properties).children {
        print("\(property): \(value)")
    }

    root.create(root.properties, root.children).render()

    render(root.children)
}

public func render(_ children: [Node]) {
    for child in children {
        render(child)
    }
}
