import class AppKit.NSColor
import class AppKit.NSEvent
import func AppKitX.Text
import func AppKitX.View
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGRect
import class Nift.Composite
import protocol Nift.Initializable
import protocol Nift.Node

public class Incrementer: Composite {
    struct Properties: Equatable {
        let x: CGFloat
        let y: CGFloat
    }

    struct State: Equatable, Initializable {
        var count = 0
    }

    public init(key: String? = nil, x: CGFloat, y: CGFloat) {
        super.init(
            Component.self,
            key: key,
            properties: Properties(x: x, y: y)
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

        func render() -> [Node] {
            let width = CGFloat(100)
            let height = CGFloat(20)

            var numbers: [Node] = []

            if state.count > 0 {
                for i in 1 ... state.count {
                    numbers.append(
                        Text(
                            frame: CGRect(x: CGFloat(i * 20), y: 0, width: 30, height: 20),
                            key: String(i),
                            string: String(i)
                        )
                    )
                }
            }

            return [
                View(
                    backgroundColor: NSColor.lightGray.cgColor,
                    key: "view",
                    mouseDown: increase,
                    rightMouseDown: decrease,
                    wantsLayer: true, [
                        Text(
                            frame: CGRect(
                                x: properties.x - width / 2,
                                y: properties.y + height / 20,
                                width: width,
                                height: height
                            ),
                            key: "count",
                            string: "Count is " + String(state.count)
                        ),
                    ] + numbers
                ),
            ]
        }
    }
}
