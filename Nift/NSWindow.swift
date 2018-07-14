import class AppKit.NSWindow
import struct Foundation.NSRect

public class NSWindow: Native.Base {
    struct Properties {
        let contentRect: NSRect
        let styleMask: AppKit.NSWindow.StyleMask
        let backing: AppKit.NSWindow.BackingStoreType
        let defer_: Bool
        let titlebarAppearsTransparent: Bool
    }

    class Component: Native.Renderable {
        var properties: Properties
        var window: AppKit.NSWindow

        required init(properties: Any, mounts _: [Any]) {
            self.properties = properties as! Properties

            self.window = AppKit.NSWindow(
                contentRect: self.properties.contentRect,
                styleMask: self.properties.styleMask,
                backing: self.properties.backing,
                defer: self.properties.defer_
            )

            self.window.titlebarAppearsTransparent = self.properties.titlebarAppearsTransparent
        }

        func render() -> Any {
            return window
        }
    }

    public init(contentRect: NSRect, styleMask: AppKit.NSWindow.StyleMask, backing: AppKit.NSWindow.BackingStoreType, defer defer_: Bool, titlebarAppearsTransparent: Bool, _ children: [Node] = []) {
        super.init(create: Component.init, properties: Properties(contentRect: contentRect, styleMask: styleMask, backing: backing, defer_: defer_, titlebarAppearsTransparent: titlebarAppearsTransparent), children)
    }
}
