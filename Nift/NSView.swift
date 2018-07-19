import class AppKit.NSText
import class AppKit.NSView
import class CoreGraphics.CGColor
import struct Foundation.UUID

public class NSView: Native {
    static let type = UUID()

    struct Properties {
        let wantsLayer: Bool
        let backgroundColor: CGColor?
    }

    class Component: Native.Component {
        var view: AppKit.NSView

        required init(properties: Any, children: [Any]) {
            view = AppKit.NSView()

            apply(properties as! Properties)

            for child in children {
                if let subview = child as? AppKit.NSView {
                    view.addSubview(subview)
                }
            }
        }

        func apply(_ properties: Properties) {
            view.wantsLayer = properties.wantsLayer

            view.layer?.backgroundColor = properties.backgroundColor
        }

        func update(properties _: Any, operations _: [Operation]) {
        }

        func remove(_ mount: Any) {
            if let view = mount as? AppKit.NSView {
                view.removeFromSuperview()
            }
        }

        func render() -> Any {
            return view
        }
    }

    public init(wantsLayer: Bool = false, backgroundColor: CGColor? = nil, _ children: [Node] = []) {
        super.init(type: NSView.type, create: Component.init, properties: Properties(wantsLayer: wantsLayer, backgroundColor: backgroundColor), children)
    }
}
