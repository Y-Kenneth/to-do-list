import Foundation
import SwiftUI
import FirebaseFirestore

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

    @Published var items: [TodoItem] = []

    @Published var searchText: String = ""
    @Published var activeFilter: TaskFilter = .all
    @Published var activeSort: TaskSort = .dateCreated

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {}

    // MARK: - Real-time Listener

    func startListening() {
        listener = db.collection("todos")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.items = documents.compactMap { doc in
                    try? doc.data(as: TodoItem.self)
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
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
        do {
            try db.collection("todos").addDocument(from: newItem)
        } catch {
            print("Error adding item: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete

    func deleteItem(_ item: TodoItem) {
        guard let id = item.id else { return }
        db.collection("todos").document(id).delete { error in
            if let error = error {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
    }

    func deleteItems(at offsets: IndexSet, from list: [TodoItem]) {
        for index in offsets {
            let itemToDelete = list[index]
            deleteItem(itemToDelete)
        }
    }

    // MARK: - Toggle Completion

    func toggleCompletion(for item: TodoItem) {
        guard let id = item.id else { return }
        db.collection("todos").document(id).updateData([
            "isCompleted": !item.isCompleted
        ]) { error in
            if let error = error {
                print("Error toggling completion: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Update

    func updateItem(_ updated: TodoItem) {
        guard let id = updated.id else { return }
        do {
            try db.collection("todos").document(id).setData(from: updated)
        } catch {
            print("Error updating item: \(error.localizedDescription)")
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
}
