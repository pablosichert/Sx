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

    let item: AppKit.NSMenuItem

    init(properties: Any, children: [Any]) {
        item = AppKit.NSMenuItem()

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

    func update(operations: [Operation]) {
        for operation in operations {
            switch operation {
            case let .add(mount):
                if let menu = mount as? AppKit.NSMenu {
                    item.submenu = menu
                }
            case .reorder:
                break
            case let .replace(old, new):
                if let old = old as? AppKit.NSMenu {
                    if item.submenu == old {
                        if let new = new as? AppKit.NSMenu {
                            item.submenu = new
                        }
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
        if let menu = mount as? AppKit.NSMenu {
            if item.submenu == menu {
                item.submenu = nil
            }
        }
    }

    func render() -> Any {
        return item
    }
}
