import SwiftUI

struct TasksView: View {
    @ObservedObject var viewModel = TaskViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.tasks, id: \.task) { task in
                VStack(alignment: .leading) {
                    Color(hex: task.colorCode)
                        .clipShape(Circle())
                        .frame(width: 15, height: 15)
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
            // TO-DO: Make the data refresh
            .refreshable {
                
            }
            .listStyle(.plain)
            .onAppear {
                viewModel.fetchTasks()
            }
            .navigationTitle("Tasks")
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}
