# 📝 To-Do List App

A simple iOS To-Do List application built with **SwiftUI** as a learning project to explore core SwiftUI data flow concepts.

---

## 📱 Screenshots
<p align="center">
  <img src="https://github.com/user-attachments/assets/2cd66314-2878-41fa-8134-38fa9a884952" width="220"/>
  <img src="https://github.com/user-attachments/assets/aebadb45-3362-4de7-8827-511e88053db1" width="220"/>
  <img src="https://github.com/user-attachments/assets/f48edb18-a18a-436e-95e9-26099f565ed1" width="220"/>
</p>

---

## ✨ Features

- **Add tasks** with a title, optional note, and priority level
- **Delete tasks** via swipe gesture or from the detail view
- **Mark tasks** as complete or pending
- **Detail view** for each task with inline editing
- **Progress tracking** with a live progress bar and completion percentage
- **Persistent storage** — tasks are saved across app launches using `UserDefaults`
- **Dark mode** supported

---

## 🧠 Concepts Demonstrated

This project was built to practice the following SwiftUI concepts:

| Concept | Description | Used In |
|---|---|---|
| `@State` | Local view state, owned by a single view | `ContentView`, `AddTaskView`, `TaskDetailView` |
| `@Binding` | Two-way reference passed from parent to child | `TaskRowView` |
| `@ObservableObject` | Shared data model that notifies views on change | `TodoViewModel` |
| `@Published` | Marks properties that broadcast changes to subscribers | `TodoViewModel.items` |
| `@StateObject` | Creates and owns an `ObservableObject` instance | `ContentView` |
| `@ObservedObject` | Subscribes to an existing `ObservableObject` | `AddTaskView`, `TaskDetailView` |
| `NavigationLink` | Pushes a new view onto the navigation stack | `ContentView` → `TaskDetailView` |

---

## 🗂 Project Structure

```
TodoApp/
├── App/
│   └── TodoAppApp.swift          # App entry point (@main)
├── Models/
│   └── TodoItem.swift            # Data model (Identifiable, Codable)
├── ViewModels/
│   └── TodoViewModel.swift       # Business logic + UserDefaults persistence
├── Views/
│   ├── ContentView.swift         # Root view — task list + progress card
│   ├── TaskRowView.swift         # Individual task row (@Binding)
│   ├── AddTaskView.swift         # Add task sheet
│   └── TaskDetailView.swift      # Task detail + inline editing
└── Utilities/
    └── AppColors.swift           # Color system (hex extension)
```

---

## 🛠 Requirements

| Tool | Version |
|---|---|
| Xcode | 14.3.1 |
| Swift | 5.8 |
| iOS Deployment Target | 16.0+ |
| macOS | Ventura 13.x or later |

---

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/to-do-list.git
   cd to-do-list
   ```

2. **Open in Xcode**
   ```bash
   open to-do-list.xcodeproj
   ```

3. **Run the app**
   - Select a simulator (e.g. iPhone 14) from the device picker
   - Press `Cmd + R` to build and run

> No external dependencies or package setup required.

---

## 📖 Data Flow Overview

```
TodoViewModel (@ObservableObject)
        ↕  @StateObject / @ObservedObject
   ContentView
   ├── TaskRowView       ← receives @Binding (two-way toggle)
   ├── TaskDetailView    ← receives item copy + viewModel reference
   └── AddTaskView       ← receives viewModel reference to call addItem()
```

---

## 📄 License

This project is for educational purposes. Feel free to use it as a reference for learning SwiftUI.
