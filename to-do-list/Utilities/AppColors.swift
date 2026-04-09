import SwiftUI

// All colors defined in code — no Assets.xcassets setup needed.
// Supports automatic Dark Mode via adaptive UIColor providers.

extension Color {
    // MARK: - Backgrounds
    static let appBackground = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.07, green: 0.07, blue: 0.10, alpha: 1)   // ~#121219
                : UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1)   // #F5F5F0
        }
    )

    static let appCardBackground = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.12, blue: 0.16, alpha: 1)   // ~#1E1E28
                : UIColor.white
        }
    )

    // MARK: - Text
    static let appTitle = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
                : UIColor(red: 0.10, green: 0.10, blue: 0.18, alpha: 1)
        }
    )

    static let appSubtitle = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.60, green: 0.60, blue: 0.67, alpha: 1)
                : UIColor(red: 0.54, green: 0.54, blue: 0.60, alpha: 1)
        }
    )

    // MARK: - Accent
    static let appAccent          = Color(hex: "#6C63FF")
    static let appAccentSecondary = Color(hex: "#FF6584")

    static let appAccentSoft = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.25, green: 0.23, blue: 0.45, alpha: 1)
                : UIColor(red: 0.93, green: 0.93, blue: 1.00, alpha: 1)
        }
    )

    // MARK: - Borders & Separators
    static let appBorder = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.22, green: 0.22, blue: 0.28, alpha: 1)
                : UIColor(red: 0.88, green: 0.88, blue: 0.93, alpha: 1)
        }
    )

    // MARK: - Priority Colors
    static let priorityLow    = Color(hex: "#34C759")
    static let priorityMedium = Color(hex: "#FF9F0A")
    static let priorityHigh   = Color(hex: "#FF453A")

    // MARK: - Due Date Colors
    static let dueOverdue  = Color(hex: "#FF453A")
    static let dueToday    = Color(hex: "#FF9F0A")
    static let dueSoon     = Color(hex: "#FFD60A")
    static let dueUpcoming = Color(hex: "#34C759")
}

// MARK: - Priority Color Helper
extension Color {
    static func forPriority(_ priority: TodoItem.Priority) -> Color {
        switch priority {
            case .low:    return .priorityLow
            case .medium: return .priorityMedium
            case .high:   return .priorityHigh
        }
    }

    static func forDueStatus(_ status: TodoItem.DueStatus) -> Color {
        switch status {
            case .overdue:   return .dueOverdue
            case .dueToday:  return .dueToday
            case .dueSoon:   return .dueSoon
            case .upcoming:  return .dueUpcoming
            case .noDueDate: return .appSubtitle
        }
    }
}

// MARK: - Hex Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
