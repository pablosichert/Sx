import class AppKit.NSView
import class AppKit.NSWindow
import struct Foundation.NSRect

public class NSWindow: Native {
    struct Properties {
        let contentRect: NSRect
        let styleMask: AppKit.NSWindow.StyleMask
        let backing: AppKit.NSWindow.BackingStoreType
        let defer_: Bool
        let titlebarAppearsTransparent: Bool
    }

    class Component: Native.Component {
        var properties: Properties
        var window: AppKit.NSWindow

        required init(properties: Any, children: [Any]) {
            self.properties = properties as! Properties

            window = AppKit.NSWindow(
                contentRect: self.properties.contentRect,
                styleMask: self.properties.styleMask,
                backing: self.properties.backing,
                defer: self.properties.defer_
            )

            window.titlebarAppearsTransparent = self.properties.titlebarAppearsTransparent

            assert(children.count == 1, "You must pass in exactly one view – AppKit.NSWindow.contentView expects a single AppKit.NSView")

            if children.count >= 1 {
                if let view = children[0] as? AppKit.NSView {
                    window.contentView = view
                } else {
                    assertionFailure("Child must be an AppKit.NSView")
                }
            }
        }

        func render() -> Any {
            return window
        }
    }

    public init(contentRect: NSRect, styleMask: AppKit.NSWindow.StyleMask, backing: AppKit.NSWindow.BackingStoreType, defer defer_: Bool, titlebarAppearsTransparent: Bool = false, _ children: [Node] = []) {
        super.init(create: Component.init, properties: Properties(contentRect: contentRect, styleMask: styleMask, backing: backing, defer_: defer_, titlebarAppearsTransparent: titlebarAppearsTransparent), children)
    }
}
