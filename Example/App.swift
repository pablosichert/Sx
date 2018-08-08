import let AppKit.NSApp
import class AppKit.NSApplication
import protocol AppKit.NSApplicationDelegate
import class AppKit.NSScreen
import struct CoreGraphics.CGFloat
import struct Foundation.Notification
import struct Foundation.NSRect
import class Nift.Composite
import class Nift.Node
import class Nift.NSApplication
import class Nift.NSWindow
import class ObjectiveC.NSObject

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: AppKit.NSApplication) -> Bool {
        return true
    }
}

public class App: Composite {
    public struct Properties: Equatable {}

    struct State: Equatable {}

    class Component: Composite<Properties, State>, Renderable {
        let width: CGFloat
        let height: CGFloat
        let x: CGFloat
        let y: CGFloat

        required init(properties _: Any, children: [Node]) {
            let frame = NSScreen.main!.visibleFrame

            let factor = CGFloat(0.5)

            let width = CGFloat(factor * frame.width)
            let height = (width / 3) * 2

            let x = CGFloat((frame.width - width) / 2)
            let y = CGFloat((frame.height - height) / 2)

            self.width = width
            self.height = height
            self.x = x
            self.y = y

            super.init(properties: Properties(), state: State(), children)
        }

        func render() -> [Node] {
            return [
                NSApplication(
                    delegate: AppDelegate(),
                    key: "application", [
                        NSWindow(
                            backingType: .buffered,
                            contentRect: NSRect(
                                x: self.x,
                                y: self.y,
                                width: self.width,
                                height: self.height
                            ),
                            styleMask: [.titled, .closable, .resizable],
                            titlebarAppearsTransparent: true,
                            key: "window", [
                                Incrementer(key: "incrementer", x: width / 2, y: height / 2),
                        ]),
                ]),
            ]
        }
    }

    public init() {
        super.init(
            Component: Component.self,
            key: nil,
            properties: Properties()
        )
    }
}
