import SwiftUI
import AppKit // provides NSWindow

@MainActor // UI operations should be main actor
final class MirrorWindowController {

    private var window: NSWindow? // The window that is shown. Optional because at object creation may not be a window yet
    public var selectedWindowBounds: CGRect = CGRect(
        x: 100,
        y: 200,
        width: 800,
        height: 600
    ) // reassigned from defafults in the windowCaptureManager

    func show(videoOutput: VideoOutput) { // call this function to create the mirror window, passing in a videoOutput to display

        if window == nil { // stops mirror windows from being created endlessly

            let rootView = SampleBufferDisplayView(
                videoOutput: videoOutput //wraps the videoOutput object into a SampleBufferDisplayView
            )

            let hostingView = NSHostingView(
                rootView: rootView // wraps a SampleBufferDisplayView in an NSHostingView, which can be displayed on a windoow
            )
            print(selectedWindowBounds)
            let window = NSWindow(
                contentRect: NSRect(
                    x: selectedWindowBounds.origin.x,
                    y: selectedWindowBounds.origin.y,
                    width: selectedWindowBounds.width,
                    height: selectedWindowBounds.height
                ),
                styleMask: [ //controls the window's behavior
                    .titled,
                    .closable,
                    .resizable,
                    .miniaturizable
                ],
                backing: .buffered,
                defer: false // create the window immediately rather than waiting
            )

            window.contentView = hostingView

            //
            // Floating PiP behavior
            //

            window.level = .floating
            window.backgroundColor = .black

            window.isOpaque = true

            window.hasShadow = true

            window.setFrameAutosaveName("Mirror")

            window.collectionBehavior = [
                .fullScreenAuxiliary
            ]

            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true

            window.isReleasedWhenClosed = false // Don't destroy the window object when user closes it so that window goes back to being nil instead of destroyed

            self.window = window
        }

        window?.makeKeyAndOrderFront(nil) // Makes the window 'key' - gives it keyboard focus and brings it to the front
    }
}