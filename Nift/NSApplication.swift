import class AppKit.NSApplication
import protocol AppKit.NSApplicationDelegate
import class AppKit.NSWindow
import struct Foundation.UUID

public class NSApplication: Native {
    static let type = UUID()

    struct Properties {
        let delegate: AppKit.NSApplicationDelegate
    }

    class Component: Native.Component {
        var application: AppKit.NSApplication

        required init(properties: Any, children: [Any]) {
            application = AppKit.NSApplication.shared

            apply(properties as! Properties)

            for child in children {
                if let window = child as? AppKit.NSWindow {
                    window.orderFront(self)
                }
            }
        }

        func apply(_ properties: Properties) {
            application.delegate = properties.delegate
        }

        func update(properties _: Any, operations: [Operation]) {
            for operation in operations {
                switch operation {
                case let .add(mount):
                    if let window = mount as? AppKit.NSWindow {
                        window.orderFront(self)
                    }
                case .reorder:
                    break
                case .replace:
                    break
                case .remove:
                    break
                }
            }
        }

        func remove(_: Any) {}

        func render() -> Any {
            return application
        }
    }

    public init(
        delegate: AppKit.NSApplicationDelegate,
        key: String? = nil,
        _ children: [Node] = []
    ) {
        super.init(
            create: Component.init,
            key: key,
            properties: Properties(delegate: delegate),
            type: NSApplication.type,
            children
        )
    }
}
