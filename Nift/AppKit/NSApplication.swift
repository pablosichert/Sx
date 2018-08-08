import class AppKit.NSApplication
import protocol AppKit.NSApplicationDelegate
import class AppKit.NSWindow

public class NSApplication: Native {
    struct Properties: Equatable {
        static func == (lhs: Properties, rhs: Properties) -> Bool {
            return lhs.delegate === rhs.delegate
        }

        let delegate: AppKit.NSApplicationDelegate
    }

    class Component: Renderable {
        var application: AppKit.NSApplication

        required init(properties: Any, children: [Any]) {
            application = AppKit.NSApplication.shared

            apply(properties)

            for child in children {
                if let window = child as? AppKit.NSWindow {
                    window.orderFront(self)
                }
            }
        }

        func apply(_ properties: Any) {
            if let properties = properties as? Properties {
                apply(properties)
            }
        }

        func apply(_ properties: Properties) {
            application.delegate = properties.delegate
        }

        func update(properties: Any) {
            apply(properties)
        }

        func update(operations: [Operation]) {
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

        func update(properties: Any, operations: [Operation]) {
            update(properties: properties)
            update(operations: operations)
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
            Component: Component.self,
            key: key,
            properties: Properties(delegate: delegate),
            children
        )
    }
}
