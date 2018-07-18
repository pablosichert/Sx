import class AppKit.NSMenu
import class AppKit.NSMenuItem
import struct ObjectiveC.Selector

public class NSMenuItem: Native {
    struct Properties {
        let title: String?
        let action: Selector?
        let keyEquivalent: String?
    }

    class Component: Native.Component {
        let item: AppKit.NSMenuItem

        required init(properties: Any, children: [Any]) {
            let properties = properties as! Properties
            let item = AppKit.NSMenuItem()

            if let title = properties.title {
                item.title = title
            }

            if let action = properties.action {
                item.action = action
            }

            if let keyEquivalent = properties.keyEquivalent {
                item.keyEquivalent = keyEquivalent
            }

            if children.count >= 1 {
                if let menu = children[0] as? AppKit.NSMenu {
                    item.submenu = menu
                }
            }

            self.item = item
        }

        func render() -> Any {
            return item
        }
    }

    public init(title: String? = nil, action: Selector? = nil, keyEquivalent: String? = nil, _ children: [Node] = []) {
        super.init(create: Component.init, properties: Properties(title: title, action: action, keyEquivalent: keyEquivalent), children)
    }
}
