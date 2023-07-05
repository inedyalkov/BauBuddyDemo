import SwiftUI

struct Task: Codable {
    let task: String
    let title: String
    let description: String
    let colorCode: String
}

class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var searchTask = ""
    
    // Fetches the tasks from the API
    func fetchTasks() {
        guard let url = URL(string: "https://api.baubuddy.de/dev/index.php/v1/tasks/select") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer PLACE_TOKEN_HERE", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("Error fetching tasks:", error)
                return
            }
            
            guard let data = data else {
                print("Error: No data returned")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let tasks = try decoder.decode([Task].self, from: data)
                
                DispatchQueue.main.async {
                    self?.tasks = tasks
                    self?.saveTasksToUserDefaults(tasks)
                }
            } catch {
                print("Error decoding tasks:", error)
            }
        }
        task.resume()
    }
    
    // Filters the tasks with the search bar in TasksView
    var filteredTasks: [Task] {
        if searchTask.isEmpty {
            return tasks
        } else {
            return tasks.filter { task in
                let taskText = task.task.localizedCaseInsensitiveContains(searchTask)
                let titleText = task.title.localizedCaseInsensitiveContains(searchTask)
                let descriptionText = task.description.localizedCaseInsensitiveContains(searchTask)
                return taskText || titleText || descriptionText
            }
        }
    }
    
    // Saves the tasks for offline viewing with User Defaults
    func saveTasksToUserDefaults(_ tasks: [Task]) {
        do {
            let encoder = JSONEncoder()
            let encodedTasks = try encoder.encode(tasks)
            
            UserDefaults.standard.set(encodedTasks, forKey: "tasks")
        } catch {
            print("Error encoding tasks: \(error)")
        }
    }

    
    init() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let tasks = try? JSONDecoder().decode([Task].self, from: data) {
            self.tasks = tasks
        }
    }
}
