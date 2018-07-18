import class AppKit.NSColor
import struct AppKit.NSRect
import class AppKit.NSText

public class NSText: Native {
    struct Properties {
        let string: String?
        let frame: NSRect?
        let backgroundColor: NSColor?
    }

    class Component: Native.Component {
        var text: AppKit.NSText

        required init(properties: Any, children _: [Any]) {
            let properties = properties as! Properties
            let text = AppKit.NSText()

            if let string = properties.string {
                text.string = string
            }

            if let frame = properties.frame {
                text.frame = frame
            }

            if let backgroundColor = properties.backgroundColor {
                text.backgroundColor = backgroundColor
            }

            self.text = text
        }

        func render() -> Any {
            return text
        }
    }

    public init(string: String? = nil, frame: NSRect? = nil, backgroundColor: NSColor? = nil) {
        super.init(create: Component.init, properties: Properties(string: string, frame: frame, backgroundColor: backgroundColor))
    }
}
