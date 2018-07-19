import class AppKit.NSColor
import struct AppKit.NSRect
import class AppKit.NSText
import struct Foundation.UUID

public class NSText: Native {
    static let type = UUID()

    struct Properties {
        let string: String?
        let frame: NSRect?
        let backgroundColor: NSColor?
    }

    class Component: Native.Component {
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

        func update(properties: Any, operations _: [Operation]) {
            apply(properties as! Properties)
        }

        func remove(_: Any) {}

        func render() -> Any {
            return text
        }
    }

    public init(string: String? = nil, frame: NSRect? = nil, backgroundColor: NSColor? = nil) {
        super.init(type: NSText.type, create: Component.init, properties: Properties(string: string, frame: frame, backgroundColor: backgroundColor))
    }
}
