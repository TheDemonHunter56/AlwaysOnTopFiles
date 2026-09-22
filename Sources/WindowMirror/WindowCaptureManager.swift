import Foundation // General ease of features
import CoreGraphics // What windows exist
import CoreMedia //for CMTime
import CoreVideo // Video related types
import ScreenCaptureKit // Captures window

@MainActor // cannot be accessed by other concurrency tasks
final class WindowCaptureManager: ObservableObject { //ObservableObject means that SwiftUI can observe this object for changes
// Final means that other classes can't subclass this class
    let videoOutput = VideoOutput() // Variable to handle the stream

    private var stream: SCStream? // The actual stream from ScreenCaptureKit
    // private so that ContentView can't access the stream directly

    public let mirrorWindowController = MirrorWindowController()
    // The mirroring window

    @Published var windows: [VisibleWindow] = [] 
    // @Published means notify observers when windows changes

    func refreshWindows() {
        // find all the on-screen windows, filter, and convert them into a VisibleWindow
        guard let windowList = CGWindowListCopyWindowInfo(
        // Guard means that the condition must be true before proceeding
            [.optionOnScreenOnly], //.optionAll, .excludeDesktopElements, test them at home
            kCGNullWindowID // Don't restrict query to one window, give info on all windows
        ) as? [[String: Any]]
        else { // runs if as? [[String: Any]] returns nil
            windows = []
            return
        }

        windows = windowList.compactMap { info in
        // compactMap transforms items. If item is nil, it gets discarded.
        //loops through windowList, an array of dictionaries, each dictionary is a window
        // Info is the current window
            guard
                let layer = info[kCGWindowLayer as String] as? Int, 
                layer == 0,
                // Get CoreGraphics layer and only continue if it is 0

                let id = info[kCGWindowNumber as String] as? UInt32,

                let ownerName = info[kCGWindowOwnerName as String] as? String,

                let title = info[kCGWindowName as String] as? String,

                !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,

                let boundsDict = info[kCGWindowBounds as String] as? NSDictionary                
            else {
                return nil
            }

            print(layer, " ", id, " ", ownerName, " ", title, " ")

            let bounds = CGRect(
                x: boundsDict["X"] as? CGFloat ?? 0, // ?? means instead of nil use 0
                y: boundsDict["Y"] as? CGFloat ?? 0,
                width: boundsDict["Width"] as? CGFloat ?? 0,
                height: boundsDict["Height"] as? CGFloat ?? 0
            )

            return VisibleWindow(
                id: id,
                ownerName: ownerName,
                title: title,
                bounds: bounds
            )
        }
    }

    func startCapture(windowID: CGWindowID) async throws { // async means that it can do asynchronous things, throws means it can fail with an error

        if let stream = stream { // if capturing something, stop that first
            try? await stream.stopCapture() // try? means it can throw an error that is nil
        }

        let shareableContent = try await SCShareableContent.current.windows
        // returns an object with info abt what can be captured

        guard let window = shareableContent.first(
            where: { $0.windowID == windowID } // $0 means pass the first paramater of window into it
        ) else {
            print("Couldn't find matching SCWindow")
            return
        } // guard block matches CoreGraphicsID to SCWindow. They're the same number, refer to the same thing, just different types

        mirrorWindowController.selectedWindowBounds = window.frame // bounds passed to mirrorWindowController for initial window size

        print("Capturing:", window.title ?? "")

        let filter = SCContentFilter(
            desktopIndependentWindow: window
        ) // filter object filters what the stream captures

        let configuration = SCStreamConfiguration()
        // can configure width, height, frame rate, pixel format

        configuration.width = Int(window.frame.width)
        configuration.height = Int(window.frame.height)

        configuration.minimumFrameInterval = CMTime(
            value: 1,
            timescale: 60
        )
        // represents 1/60 seconds

        configuration.pixelFormat = kCVPixelFormatType_32BGRA // 32 bits of BGRA

        let stream = SCStream(
            filter: filter,
            configuration: configuration,
            delegate: nil
        )

        try stream.addStreamOutput(
            videoOutput, // connects the stream to a videoOutput object
            type: .screen,
            sampleHandlerQueue: DispatchQueue.main
        )

        try await stream.startCapture() // when capture actually starts, frames start being sent

        self.stream = stream // stores the stream (local variable) in the manager object stream

        mirrorWindowController.show( // hands the output to the floating window
            videoOutput: videoOutput
        )

        print("Capture started")
    }
}