import class AppKit.NSMenu
import class AppKit.NSMenuItem
import struct Foundation.UUID
import struct ObjectiveC.Selector

public class NSMenuItem: Native {
    struct Properties: Equatable {
        let action: Selector?
        let keyEquivalent: String?
        let title: String?
    }

    class Component: Renderable {
        let item: AppKit.NSMenuItem

        required init(properties: Any, children: [Any]) {
            item = AppKit.NSMenuItem()

            apply(properties)

            if children.count >= 1 {
                if let menu = children[0] as? AppKit.NSMenu {
                    item.submenu = menu
                }
            }
        }

        func apply(_ properties: Any) {
            if let properties = properties as? Properties {
                apply(properties)
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
            apply(properties)
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

    public init(
        action: Selector? = nil,
        key: String? = nil,
        keyEquivalent: String? = nil,
        title: String? = nil,
        _ child: Node? = nil
    ) {
        super.init(
            Component: Component.self,
            key: key,
            properties: Properties(
                action: action,
                keyEquivalent: keyEquivalent,
                title: title
            ),
            child == nil ? [] : [child!]
        )
    }
}
