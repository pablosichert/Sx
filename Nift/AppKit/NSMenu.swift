import class AppKit.NSMenu
import class AppKit.NSMenuItem
import struct Foundation.UUID

public func NSMenu(
    key: String? = nil,
    title: String? = nil,
    _ children: [Node] = []
) -> Node {
    return Native.Node(
        key: key,
        properties: Component.Properties(title: title),
        Type: Component.self,
        children
    )
}

private struct Component: Native.Renderable {
    struct Properties: Equatable {
        let title: String?
    }

    let menu = AppKit.NSMenu()

    init(properties: Any, children: [Any]) {
        apply(properties as! Properties)

        for child in children {
            if let item = child as? AppKit.NSMenuItem {
                menu.addItem(item)
            }
        }
    }

    func apply(_ properties: Properties) {
        menu.title = properties.title ?? ""
    }

    func update(properties: Any) {
        apply(properties as! Properties)
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

    func update(properties: Any, operations: Operations) {
        update(properties: properties)
        update(operations: operations)
    }

    func insert(mount: Any, index _: Int) {
        if let item = mount as? AppKit.NSMenuItem {
            menu.addItem(item)
        }
    }

    func remove(mount: Any, index _: Int) {
        if let item = mount as? AppKit.NSMenuItem {
            menu.removeItem(item)
        }
    }

    func reorder(mount: Any, from _: Int, to: Int) {
        if let item = mount as? AppKit.NSMenuItem {
            menu.removeItem(item)
            menu.insertItem(item, at: to)
        }
    }

    func replace(old: Any, new: Any, index: Int) {
        if let old = old as? AppKit.NSMenuItem, let new = new as? AppKit.NSMenuItem {
            menu.removeItem(old)
            menu.insertItem(new, at: index)
        }
    }

    func render() -> Any {
        return menu
    }
}
