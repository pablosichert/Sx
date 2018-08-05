import class AppKit.NSColor
import struct AppKit.NSRect
import class AppKit.NSText
import struct Foundation.UUID

public class NSText: Native {
    static let type = UUID()

    struct Properties: Equatable {
        let backgroundColor: NSColor?
        let frame: NSRect?
        let string: String?
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

        func equal(a: Any, b: Any) -> Bool { // swiftlint:disable:this identifier_name
            return a as! Properties == b as! Properties
        }

        func update(properties: Any, operations _: [Operation]) {
            apply(properties as! Properties)
        }

        func remove(_: Any) {}

        func render() -> Any {
            return text
        }
    }

    public init(
        backgroundColor: NSColor? = nil,
        frame: NSRect? = nil,
        key: String? = nil,
        string: String? = nil
    ) {
        super.init(
            create: Component.init,
            key: key,
            properties: Properties(
                backgroundColor: backgroundColor,
                frame: frame,
                string: string
            ),
            type: NSText.type
        )
    }
}
