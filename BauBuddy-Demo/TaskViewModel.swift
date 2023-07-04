import SwiftUI

// Converts HEX to Color
extension Color: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(hex: value)
    }
}
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Task: Codable {
    let task: String
    let title: String
    let description: String
    let colorCode: String
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    // Fetches the tasks from the API
    func fetchTasks() {
        guard let url = URL(string: "https://api.baubuddy.de/dev/index.php/v1/tasks/select") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer TOKEN_HERE", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
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
                print("Error decoding tasks: \(error)")
            }
        }
        
        task.resume()
    }
    
    // Saves the tasks for offline viewing
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
