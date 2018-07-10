protocol Renderable {
    init(properties: Any, children: [RenderTree]?)
    func render() -> [RenderTree]?
}

class RenderTree {
    typealias Factory = (Any, [RenderTree]?) -> Renderable
    var factory: Factory
    var properties: Any
    var children: [RenderTree]?

    init(factory: @escaping Factory, properties: Any, _ children: [RenderTree]? = nil) {
        self.factory = factory
        self.properties = properties
        self.children = children
    }
}

class Scroll: Renderable {
    struct ScrollProperties {}

    var children: [RenderTree]?

    static func createElement(_ children: [RenderTree]? = nil) -> RenderTree {
        print("create \(type(of: self))")

        return RenderTree(
            factory: Scroll.init,
            properties: ScrollProperties(),
            children
        )
    }

    required init(properties _: Any, children: [RenderTree]?) {
        self.children = children
    }

    func render() -> [RenderTree]? {
        print("Hello \(type(of: self))")

        return nil
    }
}

class Section: Renderable {
    struct SectionProperties {
        let heading: String
    }

    var properties: SectionProperties
    var children: [RenderTree]?

    static func createElement(heading: String, _ children: [RenderTree]? = nil) -> RenderTree {
        print("create \(type(of: self))")

        return RenderTree(
            factory: Section.init,
            properties: SectionProperties(heading: heading),
            children
        )
    }

    required init(properties: Any, children: [RenderTree]?) {
        self.properties = properties as! SectionProperties
        self.children = children
    }

    func render() -> [RenderTree]? {
        print("Hello \(type(of: self)) \(properties.heading)")

        return nil
    }
}

class Label: Renderable {
    struct LabelProperties {
        let text: String
    }

    var properties: LabelProperties
    var children: [RenderTree]?

    static func createElement(text: String, _ children: [RenderTree]? = nil) -> RenderTree {
        print("create \(type(of: self))")

        return RenderTree(
            factory: Label.init,
            properties: LabelProperties(text: text),
            children
        )
    }

    required init(properties: Any, children _: [RenderTree]?) {
        self.properties = properties as! LabelProperties
    }

    func render() -> [RenderTree]? {
        print("Hello \(type(of: self)) \(properties.text)")

        return nil
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
    Scroll.createElement([
        Section.createElement(heading: "Section one", [
            Label.createElement(text: foo),
            Label.createElement(text: bar),
        ]),
        Section.createElement(heading: "Section two", [
            Label.createElement(text: baz),
            Label.createElement(text: bat),
        ]),
        Section.createElement(heading: "Section tree"),
    ])
)

render(tree)
