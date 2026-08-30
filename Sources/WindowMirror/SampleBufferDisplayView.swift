import SwiftUI
import AVFoundation

struct SampleBufferDisplayView: NSViewRepresentable {

    let videoOutput: VideoOutput

    func makeNSView(context: Context) -> NSView {

        let view = NSView()

        let layer = AVSampleBufferDisplayLayer()

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

    func updateNSView(
        _ nsView: NSView,
        context: Context
    ) {
    }
}