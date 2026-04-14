import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Colors
extension Color {
    static let zinc950 = Color(hex: "09090b")
    static let zinc900 = Color(hex: "18181b")
    static let zinc800 = Color(hex: "27272a")
    static let zinc700 = Color(hex: "3f3f46")
    static let zinc500 = Color(hex: "71717a")
    static let zinc400 = Color(hex: "a1a1aa")
    static let stone50  = Color(hex: "fafaf9")
    static let stone100 = Color(hex: "f5f5f4")
    static let stone200 = Color(hex: "e7e5e4")
    static let stone400 = Color(hex: "a8a29e")
    static let stone500 = Color(hex: "78716c")
    static let stone800 = Color(hex: "292524")
    static let stone900 = Color(hex: "1c1917")
    static let indigo600 = Color(hex: "4f46e5")
    static let indigo400 = Color(hex: "818cf8")
    static let indigo100 = Color(hex: "e0e7ff")
    static let amber400  = Color(hex: "fbbf24")
    static let amber500  = Color(hex: "f59e0b")
    static let amber600  = Color(hex: "d97706")
    static let red500    = Color(hex: "ef4444")
    static let red600    = Color(hex: "dc2626")
}
