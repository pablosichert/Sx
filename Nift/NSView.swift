import class AppKit.NSText
import class AppKit.NSView
import class CoreGraphics.CGColor

public class NSView: Native {
    struct Properties {
        let backgroundColor: CGColor?
    }

    class Component: Native.Component {
        var view: AppKit.NSView

        required init(properties: Any, children: [Any]) {
            let properties = properties as! Properties
            let view = AppKit.NSView()

            view.wantsLayer = true

            if let backgroundColor = properties.backgroundColor {
                view.layer?.backgroundColor = backgroundColor
            }

            for child in children {
                if let subview = child as? AppKit.NSView {
                    view.addSubview(subview)
                }
            }

            self.view = view
        }

        func render() -> Any {
            return view
        }
    }

    public init(backgroundColor: CGColor? = nil, _ children: [Node] = []) {
        super.init(create: Component.init, properties: Properties(backgroundColor: backgroundColor), children)
    }
}
