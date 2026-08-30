import Foundation
import ScreenCaptureKit
import AVFoundation

final class VideoOutput: NSObject, SCStreamOutput {
    // ScreenCaptureKit uses Obj-C and NSObject makes it so that VideoObject
    // adheres to the Obj-C requirements. SCStreamOutput makes it so that VideoObject
    // can recieve output from a SCStream

    weak var displayLayer: AVSampleBufferDisplayLayer? // AVSampleBufferDisplayLayer is a class that displays media 
    // weak means that displayLayer is a reference
    // is an optional because at creation, VideoOutput won't have anything to display yet

    func stream( // this gets called by ScreenCaptureKit when a new frame arrives
        _ stream: SCStream, // the stream object
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer, // CMSampleBuffer is a container holding media and associated info
        of outputType: SCStreamOutputType // the type of the stream
    ) {

        guard outputType == .screen else { // if this isn't a screen sample stop processing it
            return
        }

        displayLayer?.enqueue(sampleBuffer) // put the video sample into the display layer's queue
        // ? means only do this if displayLayer exists
    }
}