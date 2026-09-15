import SwiftUI

// The UI
struct ContentView: View {

    // Ask about the difference between a State and a StateObject
    @StateObject private var manager = WindowCaptureManager()
    @State private var selectedWindow: VisibleWindow?

    var body: some View { // Body conforms to view, but is a ridiculously complicated view, so 'some' keyword abstracts that type

        NavigationSplitView { 
        //Creates a split interface, sidebar and main window (main window called Detail)
        // These brackets define the sidebar

            VStack { //Makes a vertical stack of elements

                HStack { //Makes a Horizontal stack of elements

                    Button("Refresh") { //Makes a button. Arg is text on the button
                        manager.refreshWindows() //What the button does
                    }

                    Spacer() //creates FLEXIBLE empty space

                    Text("\(manager.windows.count) windows") // Text shown
                        .foregroundStyle(.secondary) // Modifier of the text

                } //Overall, button on the left and text on the right. Spacer takes up empty space
                .padding() //Adds padding to the HStack, can have 2 args for how much vertical or horizontal

                List(manager.windows) { window in
                // Makes a list from the list given (manager.windows)
                    Button { 
                    //Button("text"), is just that button. 
                    //Button {} label: {} makes the entire row into a button

                        selectedWindow = window //Assigns a value to selectedWindow, swift notices

                    } label: {
                        //ask about this part
                        VStack(alignment: .leading, spacing: 4) {
                        
                            Text(window.ownerName)
                                .font(.headline)

                            Text(window.title)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                    }
                    .buttonStyle(.plain)

                }

            }
            .navigationTitle("Windows")

        } detail: {
            //These brackets define the main window

            if let window = selectedWindow { //Happens when swift notices that selectedWindow changes value from nil to VisibleWindow 
               VStack(spacing: 20) {

                    Text(window.ownerName)
                        .font(.largeTitle)

                    Text(window.title)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Button("Mirror Window") {

                        manager.mirrorWindowController.selectedWindowBounds = window.bounds // passes bounds to the mirror window controller

                        Task {
                            do {

                                try await manager.startCapture(
                                    windowID: window.windowID
                                )

                            } catch {

                                print(error)

                            }

                        }

                    }
                    .buttonStyle(.borderedProminent)

                    Divider()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

            } else {

                VStack(spacing: 20) {

                    Image(systemName: "macwindow")
                        .font(.system(size: 64))
                        .foregroundStyle(.secondary)

                    Text("No Window Selected")
                        .font(.title)

                    Text("Select a window from the list.")
                        .foregroundStyle(.secondary)

                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

            }

        }
        .frame( //Starting size of the detail
            minWidth: 900,
            minHeight: 700
        )
        .onAppear { //Take an action before detail appears

            manager.refreshWindows()

        }
    }
}