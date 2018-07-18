import class AppKit.NSApplication
import protocol AppKit.NSApplicationDelegate
import class AppKit.NSWindow

public class NSApplication: Native {
    struct Properties {
        let delegate: AppKit.NSApplicationDelegate
    }

    class Component: Native.Component {
        var application: AppKit.NSApplication

        required init(properties: Any, children: [Any]) {
            let properties = properties as! Properties
            let application = AppKit.NSApplication.shared

            application.delegate = properties.delegate

            self.application = application

            for child in children {
                if let window = child as? AppKit.NSWindow {
                    window.orderFront(self)
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
