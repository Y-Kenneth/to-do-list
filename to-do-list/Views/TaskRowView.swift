import SwiftUI

struct TaskRowView: View {
    @Binding var item: TodoItem
    var onToggle: () -> Void
    var onDelete: () -> Void

    @State private var isPressed = false

    private let priorityColor: Color

    init(item: Binding<TodoItem>, onToggle: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self._item = item
        self.onToggle = onToggle
        self.onDelete = onDelete
        self.priorityColor = Color.forPriority(item.wrappedValue.priority)
    }

    var body: some View {
        HStack(spacing: 14) {

            // ── Completion Toggle ──
            ZStack {
                Circle()
                    .stroke(item.isCompleted ? Color.appAccent : Color.appBorder,
                            lineWidth: 2)
                    .frame(width: 26, height: 26)

                if item.isCompleted {
                    Circle()
                        .fill(Color.appAccent)
                        .frame(width: 26, height: 26)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .onTapGesture { onToggle() }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isCompleted)

            // ── Content Column ──
            VStack(alignment: .leading, spacing: 4) {

                // Title
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(item.isCompleted ? Color.appSubtitle : Color.appTitle)
                    .strikethrough(item.isCompleted, color: Color.appSubtitle)
                    .lineLimit(1)

                // Subtitle row: note + due date
                HStack(spacing: 8) {
                    if !item.note.isEmpty {
                        Text(item.note)
                            .font(.system(size: 13))
                            .foregroundColor(Color.appSubtitle)
                            .lineLimit(1)
                    }

                    if let dueText = item.formattedDueDate, !item.isCompleted {
                        dueDateBadge(text: dueText, status: item.dueStatus)
                    }
                }
            }

            Spacer(minLength: 4)

            // ── Priority Indicator ──
            priorityBadge
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(priorityAccentBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .scaleEffect(isPressed ? 0.97 : 1)
        .onLongPressGesture(
            minimumDuration: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.15)) { isPressed = pressing }
            },
            perform: {}
        )
        .contentShape(Rectangle())  // makes full row tappable for NavigationLink
        // Swipe actions
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: onToggle) {
                Label(
                    item.isCompleted ? "Undo" : "Done",
                    systemImage: item.isCompleted ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(item.isCompleted ? .orange : .green)
        }
    }

    // MARK: - Sub-views

    private var priorityBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: item.priority.systemImage)
                .font(.system(size: 12, weight: .semibold))
            Text(item.priority.rawValue)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(Color.forPriority(item.priority))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.forPriority(item.priority).opacity(0.12))
        .cornerRadius(8)
    }

    private var priorityAccentBorder: Color {
        switch item.priority {
        case .high: return Color.priorityHigh.opacity(item.isCompleted ? 0 : 0.25)
        default:    return Color.clear
        }
    }

    private func dueDateBadge(text: String, status: TodoItem.DueStatus) -> some View {
        let color = Color.forDueStatus(status)
        let icon: String = {
            switch status {
            case .overdue:  return "exclamationmark.triangle.fill"
            case .dueToday: return "bell.fill"
            case .dueSoon:  return "clock.fill"
            case .upcoming: return "calendar"
            case .noDueDate: return "calendar"
            }
        }()

        return HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.12))
        .cornerRadius(6)
    }
}
