import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var showAddSheet    = false
    @State private var showSortMenu    = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView
                    statsRow
                        .padding(.horizontal)
                        .padding(.top, 8)
                    filterBar
                        .padding(.horizontal)
                        .padding(.top, 16)
                    taskList
                }

                // Floating Action Button
                fabButton
                    .padding(.trailing, 24)
                    .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showAddSheet) {
            AddTaskView(viewModel: viewModel)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.appSubtitle)
                Text("My Tasks")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(Color.appTitle)
            }
            Spacer()

            // Sort button
            Menu {
                ForEach(TaskSort.allCases, id: \.self) { sort in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.activeSort = sort
                        }
                    } label: {
                        Label(sort.rawValue, systemImage: sort.systemImage)
                        if viewModel.activeSort == sort {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.appCardBackground)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.appAccent)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }

    // MARK: - Statistics Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                icon: "list.bullet.clipboard",
                label: "Total",
                value: "\(viewModel.items.count)",
                color: Color.appAccent
            )
            statCard(
                icon: "checkmark.circle",
                label: "Done",
                value: "\(viewModel.completedItems.count)",
                color: Color.priorityLow
            )
            statCard(
                icon: "clock.badge.exclamationmark",
                label: "Overdue",
                value: "\(viewModel.overdueCount)",
                color: Color.priorityHigh
            )
            // Completion ring
            progressRing
        }
    }

    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.appTitle)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.appSubtitle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.appCardBackground)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var progressRing: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.appAccentSoft, lineWidth: 4)
                    .frame(width: 36, height: 36)
                Circle()
                    .trim(from: 0, to: viewModel.completionRate)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appAccentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7),
                               value: viewModel.completionRate)
            }
            Text("\(Int(viewModel.completionRate * 100))%")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color.appAccent)
            Text("Rate")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.appSubtitle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.appCardBackground)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: 0) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.activeFilter = filter
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: filter.systemImage)
                            .font(.system(size: 12, weight: .semibold))
                        Text(filter.rawValue)
                            .font(.system(size: 14, weight:
                                viewModel.activeFilter == filter ? .bold : .medium))
                    }
                    .foregroundColor(
                        viewModel.activeFilter == filter
                            ? .white
                            : Color.appSubtitle
                    )
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity)
                    .background(
                        viewModel.activeFilter == filter
                            ? LinearGradient(
                                colors: [Color.appAccent, Color.appAccentSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing)
                            : LinearGradient(
                                colors: [Color.clear, Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing)
                    )
                    .cornerRadius(10)
                }
            }
        }
        .padding(4)
        .background(Color.appCardBackground)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Task List

    private var taskList: some View {
        let listItems = viewModel.filteredItems

        return Group {
            if listItems.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(listItems) { item in
                        NavigationLink(destination:
                            TaskDetailView(item: item, viewModel: viewModel)
                        ) {
                            TaskRowView(
                                item: bindingFor(item),
                                onToggle: { viewModel.toggleCompletion(for: item) },
                                onDelete: { viewModel.deleteItem(item) }
                            )
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(
                            EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                    }
                    .onDelete { offsets in
                        viewModel.deleteItems(at: offsets, from: listItems)
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: "Search tasks..."
                )
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: listItems)
    }

    private func bindingFor(_ item: TodoItem) -> Binding<TodoItem> {
        guard let idx = viewModel.items.firstIndex(where: { $0.id == item.id }) else {
            return .constant(item)
        }
        return $viewModel.items[idx]
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appAccentSoft)
                    .frame(width: 80, height: 80)
                Image(systemName: emptyStateIcon)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(Color.appAccent)
            }

            VStack(spacing: 6) {
                Text(emptyStateTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color.appTitle)
                Text(emptyStateSubtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color.appSubtitle)
                    .multilineTextAlignment(.center)
            }

            if viewModel.activeFilter == .all && viewModel.searchText.isEmpty {
                Button {
                    showAddSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Create Task")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appAccentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)
                    )
                    .cornerRadius(14)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
        .padding(.top, 40)
    }

    private var emptyStateIcon: String {
        if !viewModel.searchText.isEmpty {
            return "magnifyingglass"
        }
        switch viewModel.activeFilter {
        case .all:       return "tray"
        case .pending:   return "checkmark.circle"
        case .completed: return "party.popper"
        }
    }

    private var emptyStateTitle: String {
        if !viewModel.searchText.isEmpty {
            return "No Results"
        }
        switch viewModel.activeFilter {
        case .all:       return "No Tasks Yet"
        case .pending:   return "All Clear!"
        case .completed: return "Nothing Completed"
        }
    }

    private var emptyStateSubtitle: String {
        if !viewModel.searchText.isEmpty {
            return "Try a different search term"
        }
        switch viewModel.activeFilter {
        case .all:       return "Tap the button below to add your first task"
        case .pending:   return "You've completed everything — great job!"
        case .completed: return "Complete tasks to see them here"
        }
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button { showAddSheet = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                Text("Add Task")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.appAccent, Color.appAccentSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
            )
            .cornerRadius(32)
            .shadow(color: Color.appAccent.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }

    // MARK: - Helpers

    private func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }
}
