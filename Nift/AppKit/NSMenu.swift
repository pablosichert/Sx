import class AppKit.NSMenu
import class AppKit.NSMenuItem
import struct Foundation.UUID

public func NSMenu(
    key: String? = nil,
    title: String? = nil,
    _ children: [Node] = []
) -> Node {
    return Native.create(
        Component: Component.self,
        key: key,
        properties: Component.Properties(title: title),
        children
    )
}

private struct Component: Native.Renderable {
    struct Properties: Equatable {
        let title: String?
    }

    let menu: AppKit.NSMenu

    init(properties: Any, children: [Any]) {
        menu = AppKit.NSMenu()

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

    func update(operations: [Operation]) {
        for operation in operations {
            switch operation {
            case let .add(mount):
                if let item = mount as? AppKit.NSMenuItem {
                    menu.addItem(item)
                }
            case let .reorder(mount, index):
                if let item = mount as? AppKit.NSMenuItem {
                    menu.removeItem(item)
                    menu.insertItem(item, at: index)
                }
            case let .replace(old, new):
                if let old = old as? AppKit.NSMenuItem {
                    if let new = new as? AppKit.NSMenuItem {
                        let index = menu.index(of: old)

                        menu.removeItem(old)
                        menu.insertItem(new, at: index)
                    }
                }
            case let .remove(mount):
                remove(mount)
            }
        }
    }

    func update(properties: Any, operations: [Operation]) {
        update(properties: properties)
        update(operations: operations)
    }

    func remove(_ mount: Any) {
        if let item = mount as? AppKit.NSMenuItem {
            menu.removeItem(item)
        }
    }

    func render() -> Any {
        return menu
    }
}
