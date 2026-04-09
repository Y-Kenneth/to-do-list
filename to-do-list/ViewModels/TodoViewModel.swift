import Foundation
import SwiftUI

// MARK: - Filter Enum

enum TaskFilter: String, CaseIterable {
    case all        = "All"
    case pending    = "Pending"
    case completed  = "Done"

    var systemImage: String {
        switch self {
        case .all:       return "tray.full.fill"
        case .pending:   return "clock.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Sort Enum

enum TaskSort: String, CaseIterable {
    case dateCreated = "Date Created"
    case dueDate     = "Due Date"
    case priority    = "Priority"
    case alphabetical = "A → Z"

    var systemImage: String {
        switch self {
        case .dateCreated:  return "calendar"
        case .dueDate:      return "calendar.badge.clock"
        case .priority:     return "flag.fill"
        case .alphabetical: return "textformat.abc"
        }
    }
}

// @ObservableObject allows SwiftUI views to subscribe to this class.
// Any @Published property change automatically triggers a view re-render.
class TodoViewModel: ObservableObject {

    @Published var items: [TodoItem] = [] {
        didSet { save() }
    }

    @Published var searchText: String = ""
    @Published var activeFilter: TaskFilter = .all
    @Published var activeSort: TaskSort = .dateCreated

    private let storageKey = "todo_items_v2"

    init() {
        load()
    }

    // MARK: - Filtered & Sorted Items

    var filteredItems: [TodoItem] {
        var result = items

        // 1. Apply filter
        switch activeFilter {
        case .all:       break
        case .pending:   result = result.filter { !$0.isCompleted }
        case .completed: result = result.filter {  $0.isCompleted }
        }

        // 2. Apply search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.note.lowercased().contains(query)
            }
        }

        // 3. Apply sort
        switch activeSort {
        case .dateCreated:
            result.sort { $0.createdAt > $1.createdAt }
        case .dueDate:
            result.sort { item1, item2 in
                switch (item1.dueDate, item2.dueDate) {
                case (nil, nil):   return item1.createdAt > item2.createdAt
                case (nil, _):     return false
                case (_, nil):     return true
                case let (d1?, d2?): return d1 < d2
                }
            }
        case .priority:
            result.sort { $0.priority < $1.priority }
        case .alphabetical:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return result
    }

    // MARK: - Add

    func addItem(title: String, note: String, priority: TodoItem.Priority, dueDate: Date? = nil) {
        let newItem = TodoItem(title: title, note: note, priority: priority, dueDate: dueDate)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            items.insert(newItem, at: 0)
        }
    }

    // MARK: - Delete

    func deleteItem(_ item: TodoItem) {
        withAnimation(.easeInOut(duration: 0.3)) {
            items.removeAll { $0.id == item.id }
        }
    }

    func deleteItems(at offsets: IndexSet, from list: [TodoItem]) {
        for index in offsets {
            let itemToDelete = list[index]
            items.removeAll { $0.id == itemToDelete.id }
        }
    }

    // MARK: - Toggle Completion

    func toggleCompletion(for item: TodoItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                items[idx].isCompleted.toggle()
            }
        }
    }

    // MARK: - Update

    func updateItem(_ updated: TodoItem) {
        if let idx = items.firstIndex(where: { $0.id == updated.id }) {
            withAnimation {
                items[idx] = updated
            }
        }
    }

    // MARK: - Move / Reorder

    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Computed Helpers

    var pendingItems: [TodoItem]   { items.filter { !$0.isCompleted } }
    var completedItems: [TodoItem] { items.filter {  $0.isCompleted } }

    var completionRate: Double {
        guard !items.isEmpty else { return 0 }
        return Double(completedItems.count) / Double(items.count)
    }

    var overdueCount: Int {
        pendingItems.filter { $0.dueStatus == .overdue }.count
    }

    var dueTodayCount: Int {
        pendingItems.filter { $0.dueStatus == .dueToday }.count
    }

    // MARK: - Persistence

    private func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        // Try v2 key first, then migrate from v1
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            items = decoded
        } else if let data = UserDefaults.standard.data(forKey: "todo_items_v1"),
                  let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            items = decoded
            save() // re-save under new key
        }
    }
}
