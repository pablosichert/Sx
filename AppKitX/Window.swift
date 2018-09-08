import class AppKit.NSView
import class AppKit.NSWindow
import struct Foundation.NSRect
import protocol Nift.Native
import protocol Nift.Node
import struct Nift.Operations
import struct Nift.Property

public func Window(
    backingType: NSWindow.BackingStoreType = .buffered,
    contentRect: NSRect = .zero,
    defer defer_: Bool = true,
    key: String? = nil,
    properties: [Property<NSWindow>] = [],
    styleMask: NSWindow.StyleMask = [],
    titlebarAppearsTransparent: Bool = false,
    _ children: [Node] = []
) -> Node {
    return Native.Node(
        key: key,
        properties: Component.Properties(
            backingType: backingType,
            contentRect: contentRect,
            defer_: defer_,
            properties: properties,
            styleMask: styleMask,
            titlebarAppearsTransparent: titlebarAppearsTransparent
        ),
        Type: Component.self,
        children
    )
}

private struct Component: Native.Renderable {
    struct Properties: Equatable {
        let backingType: NSWindow.BackingStoreType
        let contentRect: NSRect
        let defer_: Bool
        let properties: [Property<NSWindow>]
        let styleMask: NSWindow.StyleMask
        let titlebarAppearsTransparent: Bool
    }

    let window: NSWindow

    init(properties: Any, children: [Any]) {
        let properties = properties as! Properties

        window = NSWindow(
            contentRect: properties.contentRect,
            styleMask: properties.styleMask,
            backing: properties.backingType,
            defer: properties.defer_
        )

        apply(properties)

        assert(children.count == 1, "You must pass in exactly one view – NSWindow.contentView expects a single NSView")

        if children.count >= 1 {
            if let view = children[0] as? NSView {
                window.contentView = view
            } else {
                assertionFailure("Child must be an NSView")
            }
        }
    }

    func apply(_ properties: Properties) {
        window.backingType = properties.backingType
        window.contentRect(forFrameRect: properties.contentRect)
        window.styleMask = properties.styleMask
        window.titlebarAppearsTransparent = properties.titlebarAppearsTransparent

        for property in properties.properties {
            property.apply(window)
        }
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

    func render() -> Any {
        return window
    }
}
