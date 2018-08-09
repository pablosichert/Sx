import class AppKit.NSColor
import struct AppKit.NSRect
import class AppKit.NSText
import struct Foundation.UUID

public func NSText(
    backgroundColor: NSColor? = nil,
    frame: NSRect? = nil,
    key: String? = nil,
    string: String? = nil
) -> Node {
    return Native.create(
        Component: Component.self,
        key: key,
        properties: Component.Properties(
            backgroundColor: backgroundColor,
            frame: frame,
            string: string
        )
    )
}

private class Component: Native.Renderable {
    struct Properties: Equatable {
        let backgroundColor: NSColor?
        let frame: NSRect?
        let string: String?
    }

    var text: AppKit.NSText

    required init(properties: Any, children _: [Any]) {
        text = AppKit.NSText()

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

    func update(operations _: [Operation]) {}

    func update(properties: Any, operations: [Operation]) {
        update(properties: properties)
        update(operations: operations)
    }

    func remove(_: Any) {}

    func render() -> Any {
        return text
    }
}
