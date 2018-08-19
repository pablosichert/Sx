import class AppKit.NSMenu
import class AppKit.NSMenuItem
import struct Foundation.UUID
import struct ObjectiveC.Selector

public func NSMenuItem(
    action: Selector? = nil,
    key: String? = nil,
    keyEquivalent: String? = nil,
    title: String? = nil,
    _ child: Node? = nil
) -> Node {
    return Native.create(
        Component: Component.self,
        key: key,
        properties: Component.Properties(
            action: action,
            keyEquivalent: keyEquivalent,
            title: title
        ),
        child == nil ? [] : [child!]
    )
}

private struct Component: Native.Renderable {
    struct Properties: Equatable {
        let action: Selector?
        let keyEquivalent: String?
        let title: String?
    }

    let item = AppKit.NSMenuItem()

    init(properties: Any, children: [Any]) {
        apply(properties as! Properties)

        if children.count >= 1 {
            if let menu = children[0] as? AppKit.NSMenu {
                item.submenu = menu
            }
        }
    }

    func apply(_ properties: Properties) {
        item.title = properties.title ?? ""

        if let action = properties.action {
            item.action = action
        }

        if let keyEquivalent = properties.keyEquivalent {
            item.keyEquivalent = keyEquivalent
        }
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
        if let menu = mount as? AppKit.NSMenu {
            item.submenu = menu
        }
    }

    func remove(mount: Any, index _: Int) {
        if let menu = mount as? AppKit.NSMenu {
            if item.submenu == menu {
                item.submenu = nil
            }
        }
    }

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old: Any, new: Any, index _: Int) {
        if let old = old as? AppKit.NSMenu, let new = new as? AppKit.NSMenu {
            if item.submenu == old {
                item.submenu = new
            }
        }
    }

    func render() -> Any {
        return item
    }
}
