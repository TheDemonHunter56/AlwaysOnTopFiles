import SwiftUI
import AppKit

@MainActor // UI operations should be main actor
final class MirrorWindowController {

    private var window: NSWindow? // The window that is shown. Optional because at creation may not be a window yet

    func show(videoOutput: VideoOutput) { // call this function to show the mirror window, passing in a videoOutput to display

        if window == nil { // stops mirror windows from being created endlessly

            let rootView = SampleBufferDisplayView(
                videoOutput: videoOutput //wraps the videoOutput object into a SampleBufferDisplayView
            )

            let hostingView = NSHostingView(
                rootView: rootView // wraps a SampleBufferDisplayView in an NSHostingView, which can be displayed on a windoow
            )

            let window = NSWindow(
                contentRect: NSRect(
                    x: 200,
                    y: 200,
                    width: 800,
                    height: 600
                ),
                styleMask: [
                    .titled,
                    .closable,
                    .resizable,
                    .miniaturizable
                ],
                backing: .buffered,
                defer: false
            )

            window.contentView = hostingView

            //
            // Floating PiP behavior
            //

            window.level = .floating
            window.backgroundColor = .black

            window.isOpaque = true

            window.hasShadow = true

            window.center()

            window.setFrameAutosaveName("Mirror")

            window.collectionBehavior = [
                .canJoinAllSpaces,
                .fullScreenAuxiliary
            ]

            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true

            window.isReleasedWhenClosed = false

            self.window = window
        }

        window?.makeKeyAndOrderFront(nil)
    }

}