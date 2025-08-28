import SwiftUI

extension NSColor {
    static let writtenText = NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    static let currentLetter = NSColor.white
    static let futureText = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
}

extension Color {
    static let writtenText = Color(nsColor: .writtenText)
    static let currentLetter = Color(nsColor: .currentLetter)
    static let futureText = Color(nsColor: .futureText)
}
