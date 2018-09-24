import class AppKit.NSApplication
import struct Sx.Mount

let instance = Mount<NSApplication>(
    App()
)

let app = instance[0]

app.run()
