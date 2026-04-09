import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: TodoViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title      = ""
    @State private var note       = ""
    @State private var priority   = TodoItem.Priority.medium
    @State private var hasDueDate = false
    @State private var dueDate    = Calendar.current.date(
                                        byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var titleError = false

    @FocusState private var focusedField: Field?

    enum Field {
        case title, note
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Navigation Bar
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.appSubtitle)
                        .font(.system(size: 16))

                    Spacer()

                    Text("New Task")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.appTitle)

                    Spacer()

                    Button("Add") { submitTask() }
                        .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty
                                         ? Color.appSubtitle : Color.appAccent)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.appCardBackground)
                .overlay(
                    Rectangle()
                        .fill(Color.appBorder)
                        .frame(height: 0.5),
                    alignment: .bottom
                )

                // MARK: Form Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // ── Title ──
                        fieldSection(label: "Task Title", icon: "pencil.line") {
                            TextField("What do you need to do?", text: $title)
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(Color.appTitle)
                                .padding(14)
                                .background(Color.appCardBackground)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(titleError ? Color.priorityHigh : Color.appBorder,
                                                lineWidth: 1.5)
                                )
                                .focused($focusedField, equals: .title)
                                .onChange(of: title) { _ in
                                    if titleError && !title.isEmpty { titleError = false }
                                }
                        }

                        if titleError {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 11))
                                Text("Please enter a task title")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(Color.priorityHigh)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // ── Note ──
                        fieldSection(label: "Note (optional)", icon: "note.text") {
                            ZStack(alignment: .topLeading) {
                                if note.isEmpty {
                                    Text("Add details or context...")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.appSubtitle)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                }
                                TextEditor(text: $note)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.appTitle)
                                    .frame(minHeight: 90)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .focused($focusedField, equals: .note)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .background(Color.appCardBackground)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.appBorder, lineWidth: 1.5)
                            )
                        }

                        // ── Priority ──
                        fieldSection(label: "Priority", icon: "flag.fill") {
                            HStack(spacing: 10) {
                                ForEach(TodoItem.Priority.allCases, id: \.self) { p in
                                    Button {
                                        withAnimation(.spring(response: 0.3,
                                                              dampingFraction: 0.6)) {
                                            priority = p
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: p.systemImage)
                                                .font(.system(size: 14, weight: .semibold))
                                            Text(p.rawValue)
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                        .foregroundColor(
                                            priority == p
                                                ? .white
                                                : Color.forPriority(p)
                                        )
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            priority == p
                                            ? AnyShapeStyle(
                                                LinearGradient(
                                                    colors: [Color.forPriority(p),
                                                             Color.forPriority(p).opacity(0.7)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing))
                                            : AnyShapeStyle(
                                                Color.forPriority(p).opacity(0.1))
                                        )
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    priority == p
                                                        ? Color.clear
                                                        : Color.forPriority(p).opacity(0.3),
                                                    lineWidth: 1.5)
                                        )
                                        .scaleEffect(priority == p ? 1.04 : 1)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        // ── Due Date ──
                        fieldSection(label: "Due Date", icon: "calendar.badge.clock") {
                            VStack(spacing: 12) {
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
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.appCardBackground)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.appBorder, lineWidth: 1)
                                )

                                if hasDueDate {
                                    DatePicker(
                                        "Due",
                                        selection: $dueDate,
                                        in: Date()...,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.graphical)
                                    .tint(Color.appAccent)
                                    .padding(14)
                                    .background(Color.appCardBackground)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.appBorder, lineWidth: 1)
                                    )
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }

                        // ── Submit ──
                        Button(action: submitTask) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                Text("Add Task")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.appAccent, Color.appAccentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.appAccent.opacity(0.3),
                                    radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }

    // MARK: - Reusable Field Wrapper

    @ViewBuilder
    private func fieldSection<Content: View>(
        label: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.appSubtitle)
            content()
        }
    }

    // MARK: - Submit

    private func submitTask() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            withAnimation { titleError = true }
            focusedField = .title
            return
        }
        viewModel.addItem(
            title: trimmed,
            note: note.trimmingCharacters(in: .whitespaces),
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil
        )
        dismiss()
    }
}
