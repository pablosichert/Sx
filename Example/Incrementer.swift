import class AppKit.NSColor
import class AppKit.NSEvent
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGRect
import struct Nift.Composite
import struct Nift.Handler
import struct Nift.Node
import func Nift.NSText
import func Nift.NSView

typealias Event = (_ with: NSEvent) -> Void

public func Incrementer(key: String? = nil, x: CGFloat, y: CGFloat) -> Node {
    return Composite.create(
        Component: Component.self,
        key: key,
        properties: Component.Properties(x: x, y: y)
    )
}

private class Component: Composite.Component<Component.Properties, Component.State>, Composite.Renderable {
    struct Properties: Equatable {
        let x: CGFloat
        let y: CGFloat
    }

    struct State: Equatable {
        var count = 0
    }

    required init(properties: Any, children: [Node]) {
        super.init(properties: properties as! Properties, state: State(), children)
    }

    lazy var increaseHandler = Handler<Event>({ [unowned self] _ in
        self.increase()
    })

    lazy var decreaseHandler = Handler<Event>({ [unowned self] _ in
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
