import class AppKit.NSApplication
import protocol AppKit.NSApplicationDelegate
import class AppKit.NSWindow

public func NSApplication(
    delegate: AppKit.NSApplicationDelegate,
    key: String? = nil,
    _ children: [Node] = []
) -> Node {
    return Native.Node(
        key: key,
        properties: Component.Properties(delegate: delegate),
        Type: Component.self,
        children
    )
}

private struct Component: Native.Renderable {
    struct Properties: Equatable {
        static func == (lhs: Properties, rhs: Properties) -> Bool {
            return lhs.delegate === rhs.delegate
        }

        weak var delegate: AppKit.NSApplicationDelegate?
    }

    var application = AppKit.NSApplication.shared

    init(properties: Any, children: [Any]) {
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

    func update(operations: Operations) {
        for replace in operations.replaces {
            self.replace(old: replace.old, new: replace.new, index: replace.index)
        }

        for remove in operations.removes {
            self.remove(mount: remove.mount, index: remove.index)
        }

        for reorder in operations.reorders {
            self.reorder(mount: reorder.mount, from: reorder.from, to: reorder.to)
        }

        for insert in operations.inserts {
            self.insert(mount: insert.mount, index: insert.index)
        }
    }

    func update(properties: Any, operations: Operations) {
        update(properties: properties)
        update(operations: operations)
    }

    func insert(mount: Any, index _: Int) {
        if let window = mount as? AppKit.NSWindow {
            window.orderFront(self)
        }
    }

    func remove(mount _: Any, index _: Int) {}

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old: Any, new: Any, index: Int) {
        remove(mount: old, index: index)
        insert(mount: new, index: index)
    }

    func render() -> Any {
        return application
    }
}
