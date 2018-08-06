import class AppKit.NSEvent
import class AppKit.NSText
import class AppKit.NSView
import class CoreGraphics.CGColor
import struct Foundation.UUID

public class NSView: Native {
    public typealias Event = (_ with: NSEvent) -> Void

    static let create = Handler<Native.Init>(Inner.init)

    struct Properties: Equatable {
        let backgroundColor: CGColor?
        let mouseDown: Handler<Event>
        let rightMouseDown: Handler<Event>
        let wantsLayer: Bool
    }

    class Inner: Native.Component {
        class View: AppKit.NSView {
            weak var parent: Inner?

            override func mouseDown(with event: NSEvent) {
                parent?.properties.mouseDown.call(event)
            }

            override func rightMouseDown(with event: NSEvent) {
                parent?.properties.rightMouseDown.call(event)
            }
        }

        var view: View
        var properties: Properties

        required init(properties: Any, children: [Any]) {
            self.properties = properties as! Properties // swiftlint:disable:this force_cast

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

        func update(properties: Any) {
            apply(properties as! Properties)
        }

        func update(operations: [Operation]) {
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

        func update(properties: Any, operations: [Operation]) {
            update(properties: properties)
            update(operations: operations)
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

    public init(
        backgroundColor: CGColor? = nil,
        key: String? = nil,
        mouseDown: Handler<Event> = Handler({ (_: NSEvent) in }),
        rightMouseDown: Handler<Event> = Handler({ (_: NSEvent) in }),
        wantsLayer: Bool = false,
        _ children: [Node] = []
    ) {
        super.init(
            create: NSView.create,
            equal: Equal<Properties>.call,
            key: key,
            properties: Properties(
                backgroundColor: backgroundColor,
                mouseDown: mouseDown,
                rightMouseDown: rightMouseDown,
                wantsLayer: wantsLayer
            ),
            children
        )
    }
}
