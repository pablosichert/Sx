import class AppKit.NSApplication
import struct Nift.Component

let instance = Component<NSApplication>(
    App()
)

let app = instance[0]

app.run()
