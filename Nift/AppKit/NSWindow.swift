import class AppKit.NSView
import class AppKit.NSWindow
import struct Foundation.NSRect
import struct Foundation.UUID

public func NSWindow(
    backingType: AppKit.NSWindow.BackingStoreType = .buffered,
    contentRect: NSRect = .zero,
    defer defer_: Bool = true,
    key: String? = nil,
    properties: [Property<AppKit.NSWindow>] = [],
    styleMask: AppKit.NSWindow.StyleMask = [],
    titlebarAppearsTransparent: Bool = false,
    _ children: [Node] = []
) -> Node {
    return Native.create(
        Component: Component.self,
        key: key,
        properties: Component.Properties(
            backingType: backingType,
            contentRect: contentRect,
            defer_: defer_,
            properties: properties,
            styleMask: styleMask,
            titlebarAppearsTransparent: titlebarAppearsTransparent
        ),
        children
    )
}

private struct Component: Native.Renderable {
    struct Properties: Equatable {
        let backingType: AppKit.NSWindow.BackingStoreType
        let contentRect: NSRect
        let defer_: Bool
        let properties: [Property<AppKit.NSWindow>]
        let styleMask: AppKit.NSWindow.StyleMask
        let titlebarAppearsTransparent: Bool
    }

    let window: AppKit.NSWindow

    init(properties: Any, children: [Any]) {
        let properties = properties as! Properties

        window = AppKit.NSWindow(
            contentRect: properties.contentRect,
            styleMask: properties.styleMask,
            backing: properties.backingType,
            defer: properties.defer_
        )

        apply(properties)

        assert(children.count == 1, "You must pass in exactly one view – AppKit.NSWindow.contentView expects a single AppKit.NSView")

        if children.count >= 1 {
            if let view = children[0] as? AppKit.NSView {
                window.contentView = view
            } else {
                assertionFailure("Child must be an AppKit.NSView")
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

    func update(operations: [Operation]) {
        for operation in operations {
            switch operation {
            case let .add(mount):
                if window.contentView == nil {
                    if let view = mount as? AppKit.NSView {
                        if window.contentView == nil {
                            window.contentView = view
                        }
                    }
                }
            case .reorder:
                break
            case let .replace(old, new):
                if let old = old as? AppKit.NSView {
                    if window.contentView == old {
                        if let new = new as? AppKit.NSView {
                            window.contentView = new
                        }
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
            if window.contentView == view {
                window.contentView = nil
            }
        }
    }

    func render() -> Any {
        return window
    }
}
