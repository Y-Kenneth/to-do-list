import SwiftUI

struct TaskDetailView: View {
    let item: TodoItem
    @ObservedObject var viewModel: TodoViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode

    @State private var editedTitle     : String
    @State private var editedNote      : String
    @State private var editedPriority  : TodoItem.Priority
    @State private var isCompleted     : Bool
    @State private var hasDueDate      : Bool
    @State private var editedDueDate   : Date
    @State private var isEditing       = false
    @State private var showDeleteAlert = false

    init(item: TodoItem, viewModel: TodoViewModel) {
        self.item      = item
        self.viewModel = viewModel
        _editedTitle    = State(initialValue: item.title)
        _editedNote     = State(initialValue: item.note)
        _editedPriority = State(initialValue: item.priority)
        _isCompleted    = State(initialValue: item.isCompleted)
        _hasDueDate     = State(initialValue: item.dueDate != nil)
        _editedDueDate  = State(initialValue: item.dueDate ?? Date())
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    statusBanner

                    // ── Title Card ──
                    detailCard {
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Title", icon: "pencil.line")
                            if isEditing {
                                TextField("Task title", text: $editedTitle)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.appTitle)
                                    .padding(12)
                                    .background(Color.appAccentSoft)
                                    .cornerRadius(12)
                            } else {
                                Text(editedTitle)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.appTitle)
                                    .strikethrough(isCompleted, color: Color.appSubtitle)
                            }
                        }
                    }

                    // ── Note Card ──
                    detailCard {
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Note", icon: "note.text")
                            if isEditing {
                                TextField("Add a note...", text: $editedNote, axis: .vertical)
                                    .font(.system(size: 15))
                                    .lineLimit(3...6)
                                    .padding(12)
                                    .background(Color.appAccentSoft)
                                    .cornerRadius(12)
                            } else {
                                Text(editedNote.isEmpty ? "No note added." : editedNote)
                                    .font(.system(size: 15))
                                    .foregroundColor(
                                        editedNote.isEmpty ? Color.appSubtitle : Color.appTitle)
                            }
                        }
                    }

                    // ── Priority Card ──
                    detailCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Priority", icon: "flag.fill")
                            if isEditing {
                                HStack(spacing: 10) {
                                    ForEach(TodoItem.Priority.allCases, id: \.self) { p in
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                editedPriority = p
                                            }
                                        } label: {
                                            HStack(spacing: 5) {
                                                Image(systemName: p.systemImage)
                                                    .font(.system(size: 13, weight: .semibold))
                                                Text(p.rawValue)
                                                    .font(.system(size: 12, weight: .semibold))
                                            }
                                            .foregroundColor(
                                                editedPriority == p
                                                    ? .white
                                                    : Color.forPriority(p)
                                            )
                                            .padding(.vertical, 9)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                editedPriority == p
                                                ? AnyShapeStyle(
                                                    LinearGradient(
                                                        colors: [Color.forPriority(p),
                                                                 Color.forPriority(p).opacity(0.7)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing))
                                                : AnyShapeStyle(
                                                    Color.forPriority(p).opacity(0.1))
                                            )
                                            .cornerRadius(10)
                                            .scaleEffect(editedPriority == p ? 1.04 : 1)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: editedPriority.systemImage)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color.forPriority(editedPriority))
                                    Text(editedPriority.rawValue)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.appTitle)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.forPriority(editedPriority).opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }

                    // ── Due Date Card ──
                    detailCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Due Date", icon: "calendar.badge.clock")

                            if isEditing {
                                Toggle(isOn: $hasDueDate.animation(.spring(response: 0.3))) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "alarm")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color.appAccent)
                                        Text("Set Due Date")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color.appTitle)
                                    }
                                }
                                .tint(Color.appAccent)

                                if hasDueDate {
                                    DatePicker(
                                        "Due",
                                        selection: $editedDueDate,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.graphical)
                                    .tint(Color.appAccent)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            } else {
                                if let dueText = dueDateDisplayText {
                                    HStack(spacing: 8) {
                                        Image(systemName: dueDateIcon)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(dueDateColor)
                                        Text(dueText)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.appTitle)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(dueDateColor.opacity(0.1))
                                    .cornerRadius(12)
                                } else {
                                    Text("No due date")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.appSubtitle)
                                }
                            }
                        }
                    }

                    // ── Metadata Card ──
                    detailCard {
                        VStack(spacing: 12) {
                            metadataRow(icon: "calendar", label: "Created",
                                        value: item.createdAt.formatted(
                                            date: .abbreviated, time: .omitted))
                            Divider()
                            metadataRow(icon: "info.circle", label: "Status",
                                        value: isCompleted ? "Completed" : "In Progress")
                            Divider()
                            metadataRow(icon: "tag", label: "ID",
                                        value: String(item.id?.prefix(8) ?? "N/A").uppercased())
                        }
                    }

                    // ── Action Buttons ──
                    VStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                isCompleted.toggle()
                                saveChanges()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: isCompleted
                                      ? "arrow.uturn.backward.circle.fill"
                                      : "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                Text(isCompleted ? "Mark as Pending" : "Mark as Complete")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(isCompleted ? Color.appSubtitle : Color.appAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appCardBackground)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }

                        Button { showDeleteAlert = true } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16))
                                Text("Delete Task")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(Color.priorityHigh)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.priorityHigh.opacity(0.08))
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Task Detail")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar { toolbarItems }
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteItem(item)
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if isEditing {
                Button {
                    saveChanges()
                    withAnimation { isEditing = false }
                } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.appAccent)
                }
            } else {
                Button {
                    withAnimation { isEditing = true }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Edit")
                    }
                    .foregroundColor(Color.appAccent)
                }
            }
        }
        if isEditing {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    editedTitle    = item.title
                    editedNote     = item.note
                    editedPriority = item.priority
                    hasDueDate     = item.dueDate != nil
                    editedDueDate  = item.dueDate ?? Date()
                    withAnimation { isEditing = false }
                } label: {
                    Text("Cancel")
                        .foregroundColor(Color.priorityHigh)
                }
            }
        }
    }

    // MARK: - Helpers

    private func saveChanges() {
        var updated         = item
        updated.title       = editedTitle.trimmingCharacters(in: .whitespaces)
        updated.note        = editedNote.trimmingCharacters(in: .whitespaces)
        updated.priority    = editedPriority
        updated.isCompleted = isCompleted
        updated.dueDate     = hasDueDate ? editedDueDate : nil
        viewModel.updateItem(updated)
    }

    @ViewBuilder
    private func detailCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func sectionLabel(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color.appSubtitle)
    }

    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(Color.appSubtitle)
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.appSubtitle)
            }
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.appTitle)
        }
    }

    // MARK: - Status Banner

    private var statusBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: isCompleted ? "checkmark.seal.fill" : "clock.fill")
                .font(.system(size: 16))
            Text(isCompleted ? "Completed" : "In Progress")
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(isCompleted ? .green : Color.appAccent)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background((isCompleted ? Color.green : Color.appAccent).opacity(0.12))
        .cornerRadius(12)
    }

    // MARK: - Due Date Helpers

    private var dueDateDisplayText: String? {
        guard hasDueDate else { return nil }
        let item = TodoItem(title: "", note: "", priority: .medium, dueDate: editedDueDate)
        return item.formattedDueDate
    }

    private var dueDateColor: Color {
        guard hasDueDate else { return .appSubtitle }
        let item = TodoItem(title: "", note: "", priority: .medium, dueDate: editedDueDate)
        return Color.forDueStatus(item.dueStatus)
    }

    private var dueDateIcon: String {
        guard hasDueDate else { return "calendar" }
        let item = TodoItem(title: "", note: "", priority: .medium, dueDate: editedDueDate)
        switch item.dueStatus {
        case .overdue:  return "exclamationmark.triangle.fill"
        case .dueToday: return "bell.fill"
        case .dueSoon:  return "clock.fill"
        case .upcoming: return "calendar"
        case .noDueDate: return "calendar"
        }
    }
}
