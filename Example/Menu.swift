import class AppKit.NSMenu
import class AppKit.NSMenuItem
import AppKitX
import struct ObjectiveC.Selector
import class Sx.Composite
import protocol Sx.Node

public class Menu: Composite {
    struct Properties: Equatable {
        let quit: Selector?
    }

    struct State: Equatable {}

    init(key: String? = nil, quit: Selector?) {
        super.init(
            Component.self,
            key: key,
            properties: Properties(quit: quit),
            state: State()
        )
    }

    class Component: Composite<Properties, State>, Renderable {
        func render() -> [Node?] {
            return [
                NSMenu.Node(children: [
                    NSMenuItem.Node(children: [
                        NSMenu.Node(children: [
                            NSMenuItem.Node(
                                \.title => "Quit",
                                \.keyEquivalent => "q",
                                \.action => properties.quit
                            ),
                        ]),
                    ]),
                ]),
            ]
        }
    }
}
