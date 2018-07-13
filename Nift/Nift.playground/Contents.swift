import Nift

class Scroll: Base {
    class Component: Renderable {
        var children: [Node]

        required init(properties _: Any, children: [Node] = []) {
            self.children = children
        }

        func render() -> [Node] {
            print("Hello \(type(of: self))")

            return []
        }
    }

    init(_ children: [Node] = []) {
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
        var children: [Node]

        required init(properties: Any, children: [Node] = []) {
            self.properties = properties as! Properties
            self.children = children
        }

        func render() -> [Node] {
            print("Hello \(type(of: self)) \(properties.heading)")

            return []
        }
    }

    init(heading: String, _ children: [Node] = []) {
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

        required init(properties: Any, children _: [Node]) {
            self.properties = properties as! Properties
        }

        func render() -> [Node] {
            print("Hello \(type(of: self)) \(properties.text)")

            return []
        }
    }

    init(text: String, _ children: [Node] = []) {
        super.init(create: Component.init, properties: Properties(text: text), children)

        print("create \(type(of: self))")
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
