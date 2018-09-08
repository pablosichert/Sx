import class AppKit.NSColor
import struct AppKit.NSRect
import class AppKit.NSText
import protocol Nift.Native
import protocol Nift.Node
import struct Nift.Operations

public func Text(
    backgroundColor: NSColor? = nil,
    frame: NSRect? = nil,
    key: String? = nil,
    string: String? = nil
) -> Node {
    return Native.Node(
        key: key,
        properties: Component.Properties(
            backgroundColor: backgroundColor,
            frame: frame,
            string: string
        ),
        Type: Component.self
    )
}

private struct Component: Native.Renderable {
    struct Properties: Equatable {
        let backgroundColor: NSColor?
        let frame: NSRect?
        let string: String?
    }

    var text = AppKit.NSText()

    init(properties: Any, children _: [Any]) {
        apply(properties as! Properties)
    }

    func apply(_ properties: Properties) {
        text.string = properties.string ?? ""

        if let frame = properties.frame {
            text.frame = frame
        }

        text.backgroundColor = properties.backgroundColor
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

    func insert(mount _: Any, index _: Int) {}

    func remove(mount _: Any, index _: Int) {}

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old _: Any, new _: Any, index _: Int) {}

    func render() -> Any {
        return text
    }
}
