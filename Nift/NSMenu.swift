import class AppKit.NSMenu
import class AppKit.NSMenuItem

public class NSMenu: Native {
    struct Properties {
        let title: String?
    }

    class Component: Native.Component {
        let menu: AppKit.NSMenu

        required init(properties: Any, children: [Any]) {
            let properties = properties as! Properties
            let menu = AppKit.NSMenu()

            if let title = properties.title {
                menu.title = title
            }

            for child in children {
                if child is AppKit.NSMenuItem {
                    menu.addItem(child as! AppKit.NSMenuItem)
                }
            }

            self.menu = menu
        }

        func render() -> Any {
            return menu
        }
    }

    public init(title: String? = nil, _ children: [Node] = []) {
        super.init(create: Component.init, properties: Properties(title: title), children)
    }
}
