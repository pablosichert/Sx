import class AppKit.NSApplication
import protocol AppKit.NSApplicationDelegate
import class AppKit.NSWindow

public class NSApplication: Native.Base {
    struct Properties {
        let delegate: AppKit.NSApplicationDelegate
    }

    class Component: Native.Renderable {
        var properties: Properties
        var children: [Any]
        var application: AppKit.NSApplication

        required init(properties: Any, children: [Any]) {
            self.properties = properties as! Properties
            self.application = AppKit.NSApplication.shared
            self.application.delegate = self.properties.delegate
            self.children = children

            for child in self.children {
                switch child {
                case is AppKit.NSWindow:
                    (child as! AppKit.NSWindow).orderFront(self)
                default: break
                }
            }
        }

        func render() -> Any {
            return application
        }
    }

    public init(delegate: AppKit.NSApplicationDelegate, _ children: [Node] = []) {
        super.init(create: Component.init, properties: Properties(delegate: delegate), children)
    }
}
