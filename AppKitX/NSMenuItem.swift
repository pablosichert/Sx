import class AppKit.NSMenu
import class AppKit.NSMenuItem
import struct ObjectiveC.Selector
import protocol Sx.Native
import protocol Sx.Node
import struct Sx.Operations
import struct Sx.Properties
import struct Sx.Property

public protocol NSMenuItemNode {}

public extension NSMenuItemNode where Self: NSMenuItem {
    static func Node(
        key: String,
        _ properties: Property<Self>...,
        children: [Node] = []
    ) -> Node {
        return Native.Node(
            key: key,
            properties: Properties<Self>(properties),
            Type: Component<Self>.self,
            children
        )
    }
}

extension NSMenuItem: NSMenuItemNode {}

private struct Component<MenuItem: NSMenuItem>: Native.Renderable {
    typealias Properties = Sx.Properties<MenuItem>

    let item = MenuItem()

    init(properties: Any, children: [Any]) {
        apply((next: properties as! Properties, previous: Properties()))

        if children.count >= 1 {
            if let menu = children[0] as? NSMenu {
                item.submenu = menu
            }
        }
    }

    func apply(_ properties: (next: Properties, previous: Properties)) {
        for property in properties.next where !properties.previous.contains(property) {
            property.apply(item)
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
        if let menu = mount as? NSMenu {
            item.submenu = menu
        }
    }

    func remove(mount: Any, index _: Int) {
        if let menu = mount as? NSMenu {
            if item.submenu == menu {
                item.submenu = nil
            }
        }
    }

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old: Any, new: Any, index _: Int) {
        if let old = old as? NSMenu, let new = new as? NSMenu {
            if item.submenu == old {
                item.submenu = new
            }
        }
    }

    func render() -> [Any] {
        return [item]
    }
}
