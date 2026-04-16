# 📝 To-Do List App

A feature-rich iOS To-Do List application built with **SwiftUI** and **Firebase Firestore**, designed as a learning project to explore SwiftUI data flow, real-time cloud sync, and modern iOS architecture patterns.

---

## 📱 Screenshots
<p align="center">
  <img src="https://github.com/user-attachments/assets/2cd66314-2878-41fa-8134-38fa9a884952" width="220"/>
  <img src="https://github.com/user-attachments/assets/aebadb45-3362-4de7-8827-511e88053db1" width="220"/>
  <img src="https://github.com/user-attachments/assets/f48edb18-a18a-436e-95e9-26099f565ed1" width="220"/>
</p>

---

## ✨ Features

- **Add tasks** with a title, optional note, priority level, and due date
- **Delete tasks** via swipe gesture or from the detail view
- **Mark tasks** as complete or pending with a single tap
- **Detail view** for each task with inline editing
- **Filter tasks** by status — All, Pending, or Done
- **Sort tasks** by date created, due date, priority, or alphabetically
- **Search tasks** with full-text search across titles and notes
- **Dashboard stats** — total tasks, completed count, overdue count, and animated completion ring
- **Smart due dates** — color-coded badges for overdue, due today, due soon, and upcoming tasks
- **Real-time sync** — tasks persist and sync instantly via Firebase Firestore
- **Dark mode** supported

---

## 🧠 Concepts Demonstrated

This project was built to practice the following SwiftUI concepts:

| Concept | Description | Used In |
|---|---|---|
| `@State` | Local view state, owned by a single view | `ContentView`, `AddTaskView`, `TaskDetailView` |
| `@Binding` | Two-way reference passed from parent to child | `TaskRowView` |
| `@ObservableObject` | Shared data model that notifies views on change | `TodoViewModel` |
| `@Published` | Marks properties that broadcast changes to subscribers | `TodoViewModel.items`, `searchText`, `activeFilter`, `activeSort` |
| `@StateObject` | Creates and owns an `ObservableObject` instance | `ContentView` |
| `@ObservedObject` | Subscribes to an existing `ObservableObject` | `AddTaskView`, `TaskDetailView` |
| `@FocusState` | Manages keyboard focus across form fields | `AddTaskView`, `TaskDetailView` |
| `@Environment` | Accesses environment values like dismiss action | `AddTaskView`, `TaskDetailView` |
| `@DocumentID` | Maps Firestore document IDs to model properties | `TodoItem` |
| `NavigationLink` | Pushes a new view onto the navigation stack | `ContentView` → `TaskDetailView` |

---

## 🗂 Project Structure

```
to-do-list/
├── Apps/
│   └── to_do_listApp.swift        # App entry point (@main) + Firebase setup
├── Models/
│   └── TodoItem.swift             # Data model (Identifiable, Codable, Firestore)
├── ViewModels/
│   └── TodoViewModel.swift        # Business logic + Firestore CRUD + filtering/sorting
├── Views/
│   ├── ContentView.swift          # Root view — stats, filters, task list
│   ├── TaskRowView.swift          # Individual task row with toggle & swipe actions
│   ├── AddTaskView.swift          # Add task sheet with form validation
│   └── TaskDetailView.swift       # Task detail + inline editing
└── Utilities/
    └── AppColors.swift            # Adaptive color system (light/dark mode)
```

---

## 🛠 Requirements

| Tool | Version |
|---|---|
| Xcode | 15.0+ |
| Swift | 5.0+ |
| iOS Deployment Target | 16.4+ |
| macOS | Ventura 13.x or later |

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) | Cloud Firestore for real-time data persistence |

Managed via **Swift Package Manager** (SPM).

---

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/Y-Kenneth/to-do-list.git
   cd to-do-list
   ```

2. **Firebase setup**
   - Create a project at [Firebase Console](https://console.firebase.google.com)
   - Enable **Cloud Firestore**
   - Download `GoogleService-Info.plist` and place it in the `to-do-list/` directory

3. **Open in Xcode**
   ```bash
   open to-do-list.xcodeproj
   ```

4. **Run the app**
   - Select a simulator (e.g. iPhone 15) from the device picker
   - Press `Cmd + R` to build and run

> Xcode will automatically resolve the Firebase SPM dependency on first open.

---

## 📖 Data Flow Overview

```
TodoViewModel (@ObservableObject)
  ├── Firestore listener (real-time sync)
  ├── @Published items, searchText, activeFilter, activeSort
  └── Computed: filteredItems, completionRate, overdueCount
        ↕  @StateObject / @ObservedObject
   ContentView
   ├── TaskRowView       ← receives @Binding + onToggle/onDelete callbacks
   ├── TaskDetailView    ← receives item + viewModel for edit/delete
   └── AddTaskView       ← receives viewModel to call addItem()
```

---

## 📄 License

This project is for educational purposes. Feel free to use it as a reference for learning SwiftUI and Firebase integration.
