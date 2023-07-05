import SwiftUI

struct TasksView: View {
    @StateObject var viewModel = TasksViewModel()
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            if viewModel.filteredTasks.isEmpty {
                Text("No tasks found")
                    .font(.title)
                    .foregroundColor(.gray)
                // MARK: List of tasks
            } else {
                List(viewModel.filteredTasks, id: \.task) { task in
                    VStack(alignment: .leading) {
                        Color(hex: task.colorCode)
                            .clipShape(Circle())
                            .frame(width: 20, height: 20)
                        Text(task.task)
                            .font(.body)
                            .fontWeight(.bold)
                        Text(task.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(task.description)
                            .font(.body)
                    }
                }
                .navigationTitle("Tasks")
                .listStyle(.plain)
                .refreshable {
                    isRefreshing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        viewModel.fetchTasks()
                        isRefreshing = false
                    }
                }
            }
        }
        .task {
            viewModel.fetchTasks()
        }
        .searchable(text: $viewModel.searchTask, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Tasks")
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}
