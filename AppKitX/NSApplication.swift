import class AppKit.NSApplication
import protocol AppKit.NSApplicationDelegate
import class AppKit.NSWindow
import protocol Sx.Native
import protocol Sx.Node
import struct Sx.Operations
import struct Sx.Properties
import struct Sx.Property

private typealias Properties = Sx.Properties<NSApplication>

public extension NSApplication {
    static func Node(
        key: String,
        _ properties: Property<NSApplication>...,
        children: [Node] = []
    ) -> Node {
        return Native.Node(
            key: key,
            properties: Properties(properties),
            Type: Component.self,
            children
        )
    }
}

private struct Component: Native.Renderable {
    var application = NSApplication.shared

    init(properties: Any, children: [Any]) {
        apply((next: properties as! Properties, previous: Properties()))

        for child in children {
            if let window = child as? NSWindow {
                window.orderFront(self)
            }
        }
    }

    func apply(_ properties: (next: Properties, previous: Properties)) {
        for property in properties.next where !properties.previous.contains(property) {
            property.apply(application)
        }
    }

    func update(properties: (next: Any, previous: Any)) {
        apply((
            next: properties.next as! Properties,
            previous: properties.previous as! Properties
        ))
    }

    func update(operations: Operations) {
        for replace in operations.replaces {
            self.replace(old: replace.old, new: replace.new, index: replace.index)
        }

        for remove in operations.removes {
            self.remove(mount: remove.mount, index: remove.index)
        }

        for reorder in operations.reorders {
            self.reorder(mount: reorder.mount, from: reorder.from, to: reorder.to)
        }

        for insert in operations.inserts {
            self.insert(mount: insert.mount, index: insert.index)
        }
    }

    func update(properties: (next: Any, previous: Any), operations: Operations) {
        update(properties: properties)
        update(operations: operations)
    }

    func insert(mount: Any, index _: Int) {
        if let window = mount as? NSWindow {
            window.orderFront(self)
        }
    }

    func remove(mount _: Any, index _: Int) {}

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old: Any, new: Any, index: Int) {
        remove(mount: old, index: index)
        insert(mount: new, index: index)
    }

    func render() -> [Any] {
        return [application]
    }
}
