import class AppKit.NSMenu
import class AppKit.NSMenuItem
import protocol Sx.Native
import protocol Sx.Node
import struct Sx.Operations
import struct Sx.Properties
import struct Sx.Property

public protocol NSMenuNode {}

public extension NSMenuNode where Self: NSMenu {
    static func Node(
        key: String? = nil,
        _ properties: Property<Self>...,
        children: [Node] = []
    ) -> Node {
        return Native.Node(
            key: key,
            properties: Sx.Properties<Self>(properties),
            Type: Component<Self>.self,
            children
        )
    }
}

extension NSMenu: NSMenuNode {}

private struct Component<Menu: NSMenu>: Native.Renderable {
    typealias Properties = Sx.Properties<Menu>

    let menu = Menu.init()

    init(properties: Any, children: [Any]) {
        apply((next: properties as! Properties, previous: Properties()))

        for child in children {
            if let item = child as? NSMenuItem {
                menu.addItem(item)
            }
        }
    }

    func apply(_ properties: (next: Properties, previous: Properties)) {
        for property in properties.next where !properties.previous.contains(property) {
            property.apply(menu)
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
        if let item = mount as? NSMenuItem {
            menu.addItem(item)
        }
    }

    func remove(mount: Any, index _: Int) {
        if let item = mount as? NSMenuItem {
            menu.removeItem(item)
        }
    }

    func reorder(mount: Any, from _: Int, to: Int) {
        if let item = mount as? NSMenuItem {
            menu.removeItem(item)
            menu.insertItem(item, at: to)
        }
    }

    func replace(old: Any, new: Any, index: Int) {
        if let old = old as? NSMenuItem, let new = new as? NSMenuItem {
            menu.removeItem(old)
            menu.insertItem(new, at: index)
        }
    }

    func render() -> [Any] {
        return [menu]
    }
}
