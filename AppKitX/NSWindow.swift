import class AppKit.NSView
import class AppKit.NSWindow
import struct Foundation.NSRect
import protocol Sx.Native
import protocol Sx.Node
import struct Sx.Operations
import struct Sx.Properties
import struct Sx.Property

public protocol NSWindowNode {}

public extension NSWindowNode where Self: NSWindow {
    static func Node(
        key: String? = nil,
        _ properties: Property<Self>...,
        children: [Node] = []
    ) -> Node {
        return Native.Node(
            key: key,
            properties: Properties<Self>(properties),
            Type: Component<Self>.self,
            children
        )
    }
}

extension NSWindow: NSWindowNode {}

public extension NSWindow {
    var `defer`: Bool {
        get { return false }
        set {}
    }

    var contentRect: NSRect {
        get { return contentLayoutRect }
        set { setFrame(newValue, display: true) }
    }
}

private struct Component<Window: NSWindow>: Native.Renderable {
    typealias Properties = Sx.Properties<Window>

    let window: Window

    init(properties: Any, children: [Any]) {
        let properties = properties as! Properties

        let contentRect = properties[\.contentRect] ?? .zero
        let styleMask = properties[\.styleMask] ?? []
        let backingType = properties[\.backingType] ?? .buffered
        let `defer` = properties[\.`defer`] ?? true

        window = Window(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: backingType,
            defer: `defer`
        )

        apply((
            next: properties,
            previous: Properties([
                Property(\.contentRect, contentRect),
                Property(\.styleMask, styleMask),
                Property(\.backingType, backingType),
                Property(\.`defer`, `defer`),
            ])
        ))

        assert(children.count == 1, "You must pass in exactly one view – NSWindow.contentView expects a single NSView")

        assert(children[0] is NSView, "Child must be an NSView")

        window.contentView = children[0] as? NSView
    }

    func apply(_ properties: (next: Properties, previous: Properties)) {
        for property in properties.next where !properties.previous.contains(property) {
            property.apply(window)
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
        if let view = mount as? NSView {
            window.contentView = view
        }
    }

    func remove(mount: Any, index _: Int) {
        if let view = mount as? NSView {
            if window.contentView == view {
                window.contentView = nil
            }
        }
    }

    func reorder(mount _: Any, from _: Int, to _: Int) {}

    func replace(old: Any, new: Any, index _: Int) {
        if let old = old as? NSView, let new = new as? NSView {
            if window.contentView == old {
                window.contentView = new
            }
        }
    }

    func render() -> [Any] {
        return [window]
    }
}
