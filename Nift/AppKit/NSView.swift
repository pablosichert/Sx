import class AppKit.NSEvent
import class AppKit.NSText
import class AppKit.NSView
import class CoreGraphics.CGColor
import struct Foundation.UUID

public func NSView(
    backgroundColor: CGColor? = nil,
    key: String? = nil,
    mouseDown: Handler<NSEventClosure> = Handler({ (_: NSEvent) in }),
    rightMouseDown: Handler<NSEventClosure> = Handler({ (_: NSEvent) in }),
    wantsLayer: Bool = false,
    _ children: [Node] = []
) -> Node {
    return Native.create(
        Component: Component.self,
        key: key,
        properties: Component.Properties(
            backgroundColor: backgroundColor,
            mouseDown: mouseDown,
            rightMouseDown: rightMouseDown,
            wantsLayer: wantsLayer
        ),
        children
    )
}

private struct Component: Native.Renderable {
    struct Properties: Equatable {
        let backgroundColor: CGColor?
        let mouseDown: Handler<NSEventClosure>
        let rightMouseDown: Handler<NSEventClosure>
        let wantsLayer: Bool
    }

    class View: AppKit.NSView {
        var mouseDown: Handler<NSEventClosure> = .init({ _ in })
        var rightMouseDown: Handler<NSEventClosure> = .init({ _ in })

        override func mouseDown(with event: NSEvent) {
            mouseDown.call(event)
        }

        override func rightMouseDown(with event: NSEvent) {
            rightMouseDown.call(event)
        }
    }

    let view = View()

    init(properties: Any, children: [Any]) {
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
        view.mouseDown = properties.mouseDown
        view.rightMouseDown = properties.rightMouseDown
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
        if let subview = mount as? AppKit.NSView {
            view.addSubview(subview)
        }
    }

    func remove(mount: Any, index _: Int) {
        if let view = mount as? AppKit.NSView {
            view.removeFromSuperview()
        }
    }

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old: Any, new: Any, index _: Int) {
        if let old = old as? AppKit.NSView, let new = new as? AppKit.NSView {
            view.replaceSubview(old, with: new)
        }
    }

    func render() -> Any {
        return view
    }
}
