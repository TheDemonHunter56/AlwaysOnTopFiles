import Foundation
import CoreGraphics

// puts all the windows into a nice, easy to work with type
struct VisibleWindow: Identifiable, Hashable {

    let id: CGWindowID
    let ownerName: String
    let title: String
    let bounds: CGRect

    // static keyword in a struct assigns the function to the type, not an individual object
    static func == (lhs: VisibleWindow, rhs: VisibleWindow) -> Bool { // Defines the == operator for a VisibleWindow object, Necessary for Hashable
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) { // Satisfies the hashable protocol
        hasher.combine(id)
    }
}