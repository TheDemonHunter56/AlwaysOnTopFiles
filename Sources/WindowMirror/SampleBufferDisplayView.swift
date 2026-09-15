import SwiftUI
import AVFoundation

struct SampleBufferDisplayView: NSViewRepresentable {
//NSViewRepresentable makes it so that you can use an NSView (appkit) with swiftUI

    let videoOutput: VideoOutput

    func makeNSView(context: Context) -> NSView { //this function call is required by NSViewRepresentable

        let view = NSView() //creates the appkit view

        let layer = AVSampleBufferDisplayLayer() //object to display the video

        layer.videoGravity = .resizeAspect

        view.wantsLayer = true

        layer.frame = view.bounds

        layer.autoresizingMask = [
            .layerWidthSizable,
            .layerHeightSizable
        ]

        view.layer?.addSublayer(layer)

        videoOutput.displayLayer = layer

        return view
    }

    func updateNSView( //another requirement of NSViewRepresentable
        _ nsView: NSView,
        context: Context
    ) {
    }
}