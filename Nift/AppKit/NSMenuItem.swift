import class AppKit.NSMenu
import class AppKit.NSMenuItem
import struct Foundation.UUID
import struct ObjectiveC.Selector

public class NSMenuItem: Native {
    static let create = Handler<Native.Init>(Component.init)

    struct Properties: Equatable {
        let action: Selector?
        let keyEquivalent: String?
        let title: String?
    }

    class Component: Native.Component {
        let item: AppKit.NSMenuItem

        required init(properties: Any, children: [Any]) {
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

        func equal(a: Any, b: Any) -> Bool { // swiftlint:disable:this identifier_name
            return a as! Properties == b as! Properties
        }

        func update(properties: Any, operations: [Operation]) {
            apply(properties as! Properties)

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
        title: String? = nil,
        action: Selector? = nil,
        keyEquivalent: String? = nil,
        _ child: Node? = nil
    ) {
        super.init(
            create: NSMenuItem.create,
            properties: Properties(
                action: action,
                keyEquivalent: keyEquivalent,
                title: title
            ),
            child == nil ? [] : [child!]
        )
    }
}
