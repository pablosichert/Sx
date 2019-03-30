import class AppKit.NSColor
import class AppKit.NSEvent
import class AppKit.NSText
import class AppKit.NSView
import AppKitX
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGRect
import class Sx.Composite
import protocol Sx.Node

private class View: NSView {
    var mouseDown: (NSEvent) -> Void = { _ in }
    var rightMouseDown: (NSEvent) -> Void = { _ in }

    override func mouseDown(with event: NSEvent) {
        mouseDown(event)
    }

    override func rightMouseDown(with event: NSEvent) {
        rightMouseDown(event)
    }
}

public class Incrementer: Composite {
    struct Properties: Equatable {
        let x: CGFloat
        let y: CGFloat
    }

    struct State: Equatable {
        var count = 0
    }

    public init(key: String? = nil, x: CGFloat, y: CGFloat) {
        super.init(
            Component.self,
            key: key,
            properties: Properties(x: x, y: y),
            state: State()
        )
    }

    class Component: Composite<Properties, State>, Renderable {
        func increase(_: NSEvent) {
            setState(State(
                count: state.count + 1
            ))
        }

        func decrease(_: NSEvent) {
            setState(State(
                count: state.count - 1
            ))
        }

        func render() -> [Node?] {
            let width = CGFloat(100)
            let height = CGFloat(20)

            let numbers = {
                (1 ... self.state.count).map({ i in
                    NSText.Node(
                        key: String(i),
                        \.backgroundColor => nil,
                        \.frame => CGRect(x: CGFloat(i * 20), y: 0, width: 30, height: 20),
                        \.string => String(i)
                    )
                })
            }

            return [
                View.Node(
                    key: "view",
                    \.wantsLayer => true,
                    \.backgroundColor => NSColor.lightGray.cgColor,
                    \.mouseDown => increase,
                    \.rightMouseDown => decrease,
                    children: [
                        NSText.Node(
                            key: "count",
                            \.backgroundColor => nil,
                            \.frame => CGRect(
                                x: properties.x - width / 2,
                                y: properties.y + height / 20,
                                width: width,
                                height: height
                            ),
                            \.string => "Count is " + String(state.count)
                        ),
                    ] + ((state.count > 0) && numbers)
                ),
            ]
        }
    }
}
