import SwiftUI

// The UI
struct ContentView: View {

    // Stores the WindowCaptureManager object.
    // @StateObject tells SwiftUI that this View owns the object
    // and should keep it alive while the View exists.
    @StateObject private var manager = WindowCaptureManager()

    // Stores whichever window the user has currently selected.
    // It starts as nil because no window is selected initially.
    @State private var selectedWindow: VisibleWindow?

    var body: some View {

        VStack(spacing: 0) {

            HStack {

                Text("\(manager.windows.count) windows")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 11))

                Spacer()

                Button {
                    manager.refreshWindows()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .font(.system(size: 11))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)

            Divider()

            ScrollView {
                VStack(spacing: 2) {

                    ForEach(manager.windows) { window in

                        Button {

                            // Select this window.
                            selectedWindow = window

                            // Give the mirror window controller
                            // the bounds of the selected window.
                            manager.mirrorWindowController.selectedWindowBounds = window.bounds

                        } label: {

                            VStack(alignment: .leading, spacing: 2) {

                                // Name of the application that owns the window.
                                Text(window.ownerName)
                                    .font(.system(size: 13, weight: .medium))
                                    .lineLimit(1)

                                // Title of the window.
                                Text(window.title)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)

                            // Highlight the currently selected window.
                            .background(
                                selectedWindow == window
                                    ? Color.accentColor.opacity(0.15)
                                    : Color.clear
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
            }

            Divider()

            VStack(spacing: 5) {

                Button("Mirror Window") {

                    // This can only be reached when a window
                    // has been selected because the button is
                    // disabled otherwise.
                    if let window = selectedWindow {

                        Task {
                            do {

                                try await manager.startCapture(
                                    windowID: window.id
                                )

                            } catch {

                                print(error)

                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                // Disable the button when no window is selected.
                //
                // selectedWindow == nil:
                //      Button is disabled and appears grey.
                //
                // selectedWindow != nil:
                //      Button is enabled and appears blue.
                .disabled(selectedWindow == nil)
            }
            .padding(.vertical, 7)
        }

        // Compact initial window size.
        .frame(
            minWidth: 150,
            idealWidth: 180,
            minHeight: 250,
            idealHeight: 350
        )

        .onAppear {

            // Populate the window list when the UI first appears.
            manager.refreshWindows()

        }
    }
}