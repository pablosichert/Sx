import class AppKit.NSApplication

public class NSApplication: Native.Base {
    struct Properties {}

    class Component: Native.Renderable {
        var properties: Properties
        var application: AppKit.NSApplication

        required init(properties: Any, children _: [Node]) {
            self.properties = properties as! Properties
            self.application = AppKit.NSApplication.shared
        }

        func render(_: [Any]) -> Any {
            return application
        }
    }

    public init(_ children: [Node] = []) {
        super.init(create: Component.init, properties: Properties(), children)
    }
}
