protocol Renderable {
    init(properties: Any, children: [Node]?)
    func render() -> [Node]?
}

protocol Node {
    typealias Create = (Any, [Node]?) -> Renderable
    var create: Create { get }
    var properties: Any { get }
    var children: [Node]? { get }
}

class Base: Node {
    struct NoProperties {}
    typealias Create = (Any, [Node]?) -> Renderable
    var create: Create
    var properties: Any
    var children: [Node]?

    init(create: @escaping Create, properties: Any = NoProperties(), _ children: [Node]? = nil) {
        self.create = create
        self.properties = properties
        self.children = children
    }
}

class Scroll: Base {
    class Component: Renderable {
        var children: [Node]?

        required init(properties _: Any, children: [Node]?) {
            self.children = children
        }

        func render() -> [Node]? {
            print("Hello \(type(of: self))")

            return nil
        }
    }

    init(_ children: [Node]? = nil) {
        super.init(create: Component.init, children)

        print("create \(type(of: self))")
    }
}

class Section: Base {
    struct Properties {
        let heading: String
    }

    class Component: Renderable {
        var properties: Properties
        var children: [Node]?

        required init(properties: Any, children: [Node]?) {
            self.properties = properties as! Properties
            self.children = children
        }

        func render() -> [Node]? {
            print("Hello \(type(of: self)) \(properties.heading)")

            return nil
        }
    }

    init(heading: String, _ children: [Node]? = nil) {
        super.init(create: Component.init, properties: Properties(heading: heading), children)

        print("create \(type(of: self))")
    }
}

class Label: Base {
    struct Properties {
        let text: String
    }

    class Component: Renderable {
        var properties: Properties

        required init(properties: Any, children _: [Node]?) {
            self.properties = properties as! Properties
        }

        func render() -> [Node]? {
            print("Hello \(type(of: self)) \(properties.text)")

            return nil
        }
    }

    init(text: String, _ children: [Node]? = nil) {
        super.init(create: Component.init, properties: Properties(text: text), children)

        print("create \(type(of: self))")
    }
}

func render(_ root: Node) {
    root.create(root.properties, root.children).render()

    render(root.children)
}

func render(_ children: [Node]?) {
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
