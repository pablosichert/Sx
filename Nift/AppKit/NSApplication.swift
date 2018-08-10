import class AppKit.NSApplication
import protocol AppKit.NSApplicationDelegate
import class AppKit.NSWindow

public func NSApplication(
    delegate: AppKit.NSApplicationDelegate,
    key: String? = nil,
    _ children: [Node] = []
) -> Node {
    return Native.create(
        Component: Component.self,
        key: key,
        properties: Component.Properties(delegate: delegate),
        children
    )
}

private struct Component: Native.Renderable {
    struct Properties: Equatable {
        static func == (lhs: Properties, rhs: Properties) -> Bool {
            return lhs.delegate === rhs.delegate
        }

        let delegate: AppKit.NSApplicationDelegate
    }

    var application: AppKit.NSApplication

    init(properties: Any, children: [Any]) {
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

    func update(properties: Any) {
        apply(properties as! Properties)
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
