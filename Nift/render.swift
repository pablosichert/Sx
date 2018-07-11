public func render(_ root: Node) {
    root.create(root.properties, root.children).render()

    render(root.children)
}

public func render(_ children: [Node]?) {
    if let children = children {
        for child in children {
            for case let (property?, value) in Mirror(reflecting: child.properties).children {
                print("\(property): \(value)")
            }

            child.create(child.properties, child.children).render()

            render(child.children)
        }
    }
}
