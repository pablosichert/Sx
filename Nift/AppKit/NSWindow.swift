import class AppKit.NSView
import class AppKit.NSWindow
import struct Foundation.NSRect
import struct Foundation.UUID

public class NSWindow: Native {
    static let type = UUID()

    struct Properties {
        let backing: AppKit.NSWindow.BackingStoreType
        let contentRect: NSRect
        let defer_: Bool // swiftlint:disable:this identifier_name
        let styleMask: AppKit.NSWindow.StyleMask
        let titlebarAppearsTransparent: Bool
    }

    class Component: Native.Component {
        var window: AppKit.NSWindow

        required init(properties: Any, children: [Any]) {
            let properties = properties as! Properties

            window = AppKit.NSWindow(
                contentRect: properties.contentRect,
                styleMask: properties.styleMask,
                backing: properties.backing,
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
            window.titlebarAppearsTransparent = properties.titlebarAppearsTransparent
        }

        func update(properties: Any, operations: [Operation]) {
            apply(properties as! Properties)

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

    public init(
        backing: AppKit.NSWindow.BackingStoreType,
        contentRect: NSRect,
        defer defer_: Bool, // swiftlint:disable:this identifier_name
        styleMask: AppKit.NSWindow.StyleMask,
        titlebarAppearsTransparent: Bool = false,
        key: String? = nil,
        _ children: [Node] = []
    ) {
        super.init(
            create: Component.init,
            key: key,
            properties: Properties(
                backing: backing,
                contentRect: contentRect,
                defer_: defer_,
                styleMask: styleMask,
                titlebarAppearsTransparent: titlebarAppearsTransparent
            ),
            type: NSWindow.type,
            children
        )
    }
}
