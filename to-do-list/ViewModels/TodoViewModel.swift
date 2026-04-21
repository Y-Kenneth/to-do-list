import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

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

    deinit {
        listener?.remove()
    }

    // MARK: - Real-time Listener (scoped to current user)

    func startListening() {
        // Remove any previous listener WITHOUT clearing items
        // (clearing causes the UI's List to disappear briefly,
        //  which breaks NavigationLinks mid-navigation)
        listener?.remove()
        listener = nil

        guard let uid = Auth.auth().currentUser?.uid else {
            // Only clear if truly not signed in
            self.items = []
            return
        }

        listener = db.collection("todos")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let newItems = documents.compactMap { doc in
                    try? doc.data(as: TodoItem.self)
                }
                // Only publish update if contents actually changed.
                // This prevents spurious re-renders that can dismiss
                // a pushed detail view (SwiftUI NavigationLink quirk).
                DispatchQueue.main.async {
                    guard self.items != newItems else { return }
                    self.items = newItems
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        self.items = []
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
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Cannot add item: not signed in")
            return
        }

        // Generate a Firestore document reference locally (creates a valid ID without a network call)
        let docRef = db.collection("todos").document()

        var newItem = TodoItem(
            userId: uid,
            title: title,
            note: note,
            priority: priority,
            dueDate: dueDate
        )
        newItem.id = docRef.documentID

        // Optimistic UI update — insert locally so the task appears instantly
        items.insert(newItem, at: 0)

        // Write to Firestore using the same ID; listener will reconcile
        do {
            try docRef.setData(from: newItem)
        } catch {
            // Rollback on error
            items.removeAll { $0.id == newItem.id }
            print("Error adding item: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete

    func deleteItem(_ item: TodoItem) {
        guard let id = item.id else { return }

        // Optimistic UI update — remove locally first for instant feedback
        items.removeAll { $0.id == item.id }

        // Then delete from Firestore
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
        let newValue = !item.isCompleted

        // Optimistic UI update — toggle locally first for instant feedback
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].isCompleted = newValue
        }

        // Then update Firestore; listener will sync the final state
        db.collection("todos").document(id).updateData([
            "isCompleted": newValue
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
