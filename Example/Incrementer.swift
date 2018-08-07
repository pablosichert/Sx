import class AppKit.NSColor
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGRect
import class Nift.Composite
import struct Nift.Handler
import class Nift.Node
import class Nift.NSText
import class Nift.NSView

class Incrementer: Composite {
    struct Properties: Equatable {
        let x: CGFloat
        let y: CGFloat
    }

    struct State: Equatable {
        var count = 0
    }

    class Component: Composite<Properties, State>, Renderable {
        required init(properties: Any, children: [Node]) {
            super.init(properties: properties as! Properties, state: State(), children)
        }

        lazy var increaseHandler = Handler<NSView.Event>({ [unowned self] _ in
            self.increase()
        })

        lazy var decreaseHandler = Handler<NSView.Event>({ [unowned self] _ in
            self.decrease()
        })

        func increase() {
            setState(State(
                count: state.count + 1
            ))
        }

        func decrease() {
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
                        NSText(
                            frame: CGRect(x: CGFloat(i * 20), y: 0, width: 30, height: 20),
                            key: String(i),
                            string: String(i)
                        )
                    )
                }
            }

            return [
                NSView(
                    backgroundColor: NSColor.lightGray.cgColor,
                    key: "view",
                    mouseDown: increaseHandler,
                    rightMouseDown: decreaseHandler,
                    wantsLayer: true, [
                        NSText(
                            frame: CGRect(x: properties.x - width / 2, y: properties.y + height / 20, width: width, height: height),
                            key: "count",
                            string: "Count is " + String(state.count)
                        ),
                    ] + numbers
                ),
            ]
        }
    }

    init(key: String? = nil, x: CGFloat, y: CGFloat) {
        super.init(Component: Component.self, key: key, properties: Properties(x: x, y: y))
    }
}
