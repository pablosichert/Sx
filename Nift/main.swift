protocol Renderable {
    init(properties: Any, children: [RenderTree]?)
    func render() -> [RenderTree]?
}

class RenderTree {
    struct NoProperties {}
    typealias Factory = (Any, [RenderTree]?) -> Renderable
    var factory: Factory
    var properties: Any
    var children: [RenderTree]?

    init(factory: @escaping Factory, properties: Any = NoProperties(), _ children: [RenderTree]? = nil) {
        self.factory = factory
        self.properties = properties
        self.children = children
    }
}

class Scroll: RenderTree {
    class Component: Renderable {
        var children: [RenderTree]?

        required init(properties _: Any, children: [RenderTree]?) {
            self.children = children
        }

        func render() -> [RenderTree]? {
            print("Hello \(type(of: self))")

            return nil
        }
    }

    init(_ children: [RenderTree]? = nil) {
        super.init(factory: Component.init, children)

        print("create \(type(of: self))")
    }
}

class Section: RenderTree {
    struct Properties {
        let heading: String
    }

    class Component: Renderable {
        var properties: Properties
        var children: [RenderTree]?

        required init(properties: Any, children: [RenderTree]?) {
            self.properties = properties as! Properties
            self.children = children
        }

        func render() -> [RenderTree]? {
            print("Hello \(type(of: self)) \(properties.heading)")

            return nil
        }
    }

    init(heading: String, _ children: [RenderTree]? = nil) {
        super.init(factory: Component.init, properties: Properties(heading: heading), children)

        print("create \(type(of: self))")
    }
}

class Label: RenderTree {
    struct Properties {
        let text: String
    }

    class Component: Renderable {
        var properties: Properties

        required init(properties: Any, children _: [RenderTree]?) {
            self.properties = properties as! Properties
        }

        func render() -> [RenderTree]? {
            print("Hello \(type(of: self)) \(properties.text)")

            return nil
        }
    }

    init(text: String, _ children: [RenderTree]? = nil) {
        super.init(factory: Component.init, properties: Properties(text: text), children)

        print("create \(type(of: self))")
    }
}

func render(_ root: RenderTree) {
    root.factory(root.properties, root.children).render()

    render(root.children)
}

func render(_ children: [RenderTree]?) {
    if let children = children {
        for child in children {
            for (property, value) in Mirror(reflecting: child.properties).children {
                print("\(property!): \(value)")
            }

            child.factory(child.properties, child.children).render()

            render(child.children)
        }
    }
}

let foo = "Some"
let bar = "labels"
let baz = "Some"
let bat = "more"

let tree = (
    Scroll([
        Section(heading: "Section one", [
            Label(text: foo),
            Label(text: bar),
        ]),
        Section(heading: "Section two", [
            Label(text: baz),
            Label(text: bat),
        ]),
        Section(heading: "Section tree"),
    ])
)

render(tree)
