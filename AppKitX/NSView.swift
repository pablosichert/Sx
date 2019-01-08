import class AppKit.NSEvent
import class AppKit.NSResponder
import class AppKit.NSText
import class AppKit.NSView
import class CoreGraphics.CGColor
import protocol Sx.Native
import protocol Sx.Node
import struct Sx.Operations
import struct Sx.Properties
import struct Sx.Property

public extension NSView {
    var backgroundColor: CGColor? {
        get { return layer?.backgroundColor }
        set { layer?.backgroundColor = newValue }
    }

    static func Node<View: NSView>(
        key: String,
        _ properties: Property<View>...,
        children: [Node] = []
    ) -> Node {
        return Native.Node(
            key: key,
            properties: Properties<View>(properties),
            Type: Component<View>.self,
            children
        )
    }
}

private struct Component<View: NSView>: Native.Renderable {
    typealias Properties = Sx.Properties<View>

    let view = View()

    init(properties: Any, children: [Any]) {
        apply((next: properties as! Properties, previous: Properties()))

        for child in children {
            if let subview = child as? NSView {
                view.addSubview(subview)
            }
        }
    }

    func apply(_ properties: (next: Properties, previous: Properties)) {
        for property in properties.next where !properties.previous.contains(property) {
            property.apply(view)
        }
    }

    func update(properties: (next: Any, previous: Any)) {
        apply((
            next: properties.next as! Properties,
            previous: properties.previous as! Properties
        ))
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

    func update(properties: (next: Any, previous: Any), operations: Operations) {
        update(properties: properties)
        update(operations: operations)
    }

    func insert(mount: Any, index _: Int) {
        if let subview = mount as? NSView {
            view.addSubview(subview)
        }
    }

    func remove(mount: Any, index _: Int) {
        if let view = mount as? NSView {
            view.removeFromSuperview()
        }
    }

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old: Any, new: Any, index _: Int) {
        if let old = old as? NSView, let new = new as? NSView {
            view.replaceSubview(old, with: new)
        }
    }

    func render() -> [Any] {
        return [view]
    }
}
