import class AppKit.NSEvent
import class AppKit.NSText
import class AppKit.NSView
import class CoreGraphics.CGColor
import struct Foundation.UUID

public class NSView: Native {
    static let type = UUID()

    struct Properties {
        let wantsLayer: Bool
        let backgroundColor: CGColor?
        let mouseDown: (_ with: NSEvent) -> Void
    }

    class Inner: Native.Component {
        class View: AppKit.NSView {
            var parent: Inner?

            override func mouseDown(with event: NSEvent) {
                parent?.properties.mouseDown(event)
            }
        }

        var view: View
        var properties: Properties

        required init(properties: Any, children: [Any]) {
            self.properties = properties as! Properties

            view = View()
            view.parent = self

            apply(self.properties)

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

        func update(properties: Any, operations: [Operation]) {
            apply(properties as! Properties)

            for operation in operations {
                switch operation {
                case let .add(mount):
                    if let subview = mount as? AppKit.NSView {
                        view.addSubview(subview)
                    }
                case .reorder:
                    break
                case let .replace(old, new):
                    if let old = old as? AppKit.NSView {
                        if let new = new as? AppKit.NSView {
                            old.removeFromSuperview()
                            view.addSubview(new)
                        }
                    }
                case let .remove(mount):
                    remove(mount)
                }
            }
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

    public init(wantsLayer: Bool = false, backgroundColor: CGColor? = nil, mouseDown: @escaping (_ with: NSEvent) -> Void = { (_: NSEvent) in }, key: String? = nil, _ children: [Node] = []) {
        super.init(type: NSView.type, create: Inner.init, properties: Properties(wantsLayer: wantsLayer, backgroundColor: backgroundColor, mouseDown: mouseDown), key: key, children)
    }
}
