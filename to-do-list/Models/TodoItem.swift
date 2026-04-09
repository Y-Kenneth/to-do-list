import Foundation

// Identifiable    → lets ForEach/List track each item uniquely
// Codable         → lets us encode/decode for UserDefaults persistence
struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var note: String
    var priority: Priority
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var dueDate: Date? = nil

    enum Priority: String, Codable, CaseIterable, Comparable {
        case low    = "Low"
        case medium = "Medium"
        case high   = "High"

        var emoji: String {
            switch self {
            case .low:    return "🌿"
            case .medium: return "⚡️"
            case .high:   return "🔥"
            }
        }

        var systemImage: String {
            switch self {
            case .low:    return "arrow.down.circle.fill"
            case .medium: return "minus.circle.fill"
            case .high:   return "exclamationmark.circle.fill"
            }
        }

        var color: String {
            switch self {
            case .low:    return "#34C759"   // Apple green
            case .medium: return "#FF9F0A"   // Apple orange
            case .high:   return "#FF453A"   // Apple red
            }
        }

        // Comparable conformance for sorting
        private var sortOrder: Int {
            switch self {
            case .high:   return 0
            case .medium: return 1
            case .low:    return 2
            }
        }

        static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.sortOrder < rhs.sortOrder
        }
    }

    // MARK: - Due Date Helpers

    enum DueStatus {
        case overdue
        case dueToday
        case dueSoon   // within 2 days
        case upcoming
        case noDueDate
    }

    var dueStatus: DueStatus {
        guard let dueDate = dueDate else { return .noDueDate }
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfDue = calendar.startOfDay(for: dueDate)

        if startOfDue < startOfToday {
            return .overdue
        } else if calendar.isDateInToday(dueDate) {
            return .dueToday
        } else if let twoDaysLater = calendar.date(byAdding: .day, value: 2, to: startOfToday),
                  startOfDue <= twoDaysLater {
            return .dueSoon
        } else {
            return .upcoming
        }
    }

    var formattedDueDate: String? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        
        if calendar.isDateInToday(dueDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(dueDate) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(dueDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: dueDate)
        }
    }
}
