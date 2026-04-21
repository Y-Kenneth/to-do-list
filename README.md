# 📝 To-Do List App

A feature-rich iOS To-Do List application built with **SwiftUI**, **Firebase Authentication**, and **Firebase Firestore**, designed as a learning project to explore SwiftUI data flow, user authentication, real-time cloud sync, and modern iOS architecture patterns.

---

## 📱 Screenshots
<p align="center">
  <img src="https://github.com/user-attachments/assets/2cd66314-2878-41fa-8134-38fa9a884952" width="220"/>
  <img src="https://github.com/user-attachments/assets/aebadb45-3362-4de7-8827-511e88053db1" width="220"/>
  <img src="https://github.com/user-attachments/assets/f48edb18-a18a-436e-95e9-26099f565ed1" width="220"/>
</p>

---

## ✨ Features

### 🔐 Authentication
- **Email/password sign up & sign in** powered by Firebase Authentication
- **Form validation** — email format check and 6-character minimum password
- **Password visibility toggle** with eye icon
- **Password strength indicator** with real-time feedback
- **Friendly error messages** mapped from Firebase error codes (weak password, email already exists, network errors, etc.)
- **Auto sign-in on launch** via Firebase auth state listener
- **Logout** with confirmation alert
- **User-scoped data** — each user only sees their own tasks

### 📋 Task Management
- **Add tasks** with a title, optional note, priority level, and due date
- **Delete tasks** via swipe gesture or from the detail view
- **Mark tasks** as complete or pending with a single tap
- **Detail view** for each task with inline editing (edit/save/cancel)
- **Filter tasks** by status — All, Pending, or Done
- **Sort tasks** by date created, due date, priority, or alphabetically
- **Search tasks** with full-text search across titles and notes
- **Swipe actions** — swipe left to toggle done/undo, swipe right to delete

### 📊 Dashboard & UX
- **Contextual greeting** — "Good morning/afternoon/evening" based on time of day
- **User email display** in the header
- **Dashboard stats** — total tasks, completed count, overdue count
- **Animated completion ring** with percentage
- **Smart due dates** — color-coded badges for overdue, due today, due soon, and upcoming tasks
- **Floating Action Button (FAB)** for quick task creation
- **Context-aware empty states** based on filter/search
- **Real-time sync** — tasks persist and sync instantly via Firebase Firestore
- **Dark mode** supported with adaptive colors

---

## 🧠 Concepts Demonstrated

This project was built to practice the following SwiftUI concepts:

| Concept | Description | Used In |
|---|---|---|
| `@State` | Local view state, owned by a single view | `ContentView`, `AddTaskView`, `TaskDetailView`, `LoginView` |
| `@Binding` | Two-way reference passed from parent to child | `TaskRowView` |
| `@ObservableObject` | Shared data model that notifies views on change | `TodoViewModel`, `AuthViewModel` |
| `@Published` | Marks properties that broadcast changes to subscribers | `TodoViewModel.items`, `AuthViewModel.user` |
| `@StateObject` | Creates and owns an `ObservableObject` instance | `to_do_listApp`, `ContentView` |
| `@ObservedObject` | Subscribes to an existing `ObservableObject` | `AddTaskView`, `TaskDetailView`, `LoginView` |
| `@FocusState` | Manages keyboard focus across form fields | `AddTaskView`, `TaskDetailView`, `LoginView` |
| `@Environment` | Accesses environment values like dismiss action | `AddTaskView`, `TaskDetailView` |
| `@DocumentID` | Maps Firestore document IDs to model properties | `TodoItem` |
| `NavigationLink` | Pushes a new view onto the navigation stack | `ContentView` → `TaskDetailView` |
| Conditional root view | Shows `LoginView` or `ContentView` based on auth state | `to_do_listApp` |

---

## 🗂 Project Structure

```
to-do-list/
├── Apps/
│   └── to_do_listApp.swift        # App entry point (@main) + Firebase setup + root auth routing
├── Models/
│   └── TodoItem.swift             # Data model (Identifiable, Codable, Firestore)
├── ViewModels/
│   ├── AuthViewModel.swift        # Firebase Authentication (sign up, sign in, sign out)
│   └── TodoViewModel.swift        # Business logic + Firestore CRUD + filtering/sorting
├── Views/
│   ├── LoginView.swift            # Sign in / sign up form with validation
│   ├── ContentView.swift          # Root view — stats, filters, task list, greeting
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
| Xcode | 14.3.1+ |
| Swift | 5.0+ |
| iOS Deployment Target | 16.4+ |
| macOS | Ventura 13.x or later |

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) | `FirebaseAuth` for email/password auth; `FirebaseFirestore` for real-time data persistence |

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
   - Enable **Authentication → Email/Password** sign-in method
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
to_do_listApp (@main)
  └── AuthViewModel (@StateObject)
        ├── Firebase auth state listener
        ├── @Published user, errorMessage, isLoading
        └── Conditional root view
              ├── LoginView         (when signed out)
              └── ContentView       (when signed in)
                    └── TodoViewModel (@StateObject)
                          ├── Firestore listener scoped to userId (real-time sync)
                          ├── @Published items, searchText, activeFilter, activeSort
                          └── Computed: filteredItems, completionRate, overdueCount
                                ↕  @ObservedObject
                          ├── TaskRowView       ← receives @Binding + callbacks
                          ├── TaskDetailView    ← receives item + viewModel
                          └── AddTaskView       ← receives viewModel
```

---

## 🔥 Learning Journey: Firebase Integration

This project evolved through three stages of persistence:

1. **Local-first** — initial version stored tasks in `UserDefaults` with `Codable` serialization
2. **Cloud migration** — replaced local storage with Firestore, learning document-based NoSQL data modeling
3. **Multi-user with Auth** — added Firebase Authentication so each user has their own task list, scoped via `userId` on every Firestore document

### Key Firebase takeaways
- Firestore's real-time listeners eliminate the need for manual data fetching — the UI updates automatically
- `[weak self]` in listener closures is critical to avoid retain cycles
- Structuring data as flat documents (rather than nested) keeps queries simple and performant
- User-scoped queries (`whereField("userId", isEqualTo: uid)`) enforce data isolation between accounts
- Firebase auth errors need to be mapped to friendly messages — raw error codes aren't user-friendly
- Starting/stopping the Firestore listener on sign-in/sign-out prevents stale data and memory leaks

---

## 🤖 Learning Journey: MCP (Model Context Protocol)

During development, I explored **MCP** — a protocol that connects AI tools like [Claude Code](https://claude.ai/claude-code) to external services:

1. **GitHub MCP Server** — connected Claude Code to GitHub via the `@modelcontextprotocol/server-github` package, enabling AI-assisted repository management directly from the IDE
2. **Firebase MCP Server** — used an MCP server to let Claude Code interact with Firebase Auth and Firestore during development
3. **VS Code integration** — configured MCP servers through `.vscode/mcp.json` for project-level setup
4. **Claude Code CLI** — learned to register MCP servers using `claude mcp add` for CLI-level access

### Key MCP takeaways
- MCP servers act as bridges between AI assistants and external APIs (GitHub, Firebase, databases, etc.)
- VS Code (`.vscode/mcp.json`) and Claude Code CLI (`claude mcp add`) have **separate** configurations — both need to be set up independently
- Personal access tokens should **never** be committed to version control — always add config files containing secrets to `.gitignore`

---

## 📄 License

This project is for educational purposes. Feel free to use it as a reference for learning SwiftUI, Firebase Authentication, Firestore integration, and MCP configuration.
