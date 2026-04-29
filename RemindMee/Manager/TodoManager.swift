//
//  TodoManager.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import Foundation
import Combine

class TodoManager: ObservableObject {
    @Published var todos: [TodoItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let todosKey = "SavedTodos"
    
    init() {
        loadTodos()
    }

    func addTodo(title: String, priority: Priority) {
        let newTodo = TodoItem(title: title, priority: priority)
        todos.append(newTodo)
        saveTodos()
    }

    func toggleCompletion(for todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            saveTodos()
        }
    }

    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
        saveTodos()
    }

    var sortedTodos: [TodoItem] {
        return todos
            .filter { Calendar.current.isDateInToday($0.createdAt) }
            .sorted { first, second in
                // First sort by completion status (incomplete first)
                if first.isCompleted != second.isCompleted {
                    return !first.isCompleted
                }
                // Then sort by priority (high to low)
                return first.priority.sortOrder > second.priority.sortOrder
            }
    }
    
    var todaysTasks: [TodoItem] {
        return todos.filter { Calendar.current.isDateInToday($0.createdAt) }
    }
    
    var completedTodayCount: Int {
        return todaysTasks.filter { $0.isCompleted }.count
    }
    
    var pendingTodayCount: Int {
        return todaysTasks.filter { !$0.isCompleted }.count
    }
    
    var totalTodayCount: Int {
        return todaysTasks.count
    }
    
    var todaysTasksSummary: String {
        let completed = completedTodayCount
        let total = totalTodayCount
        
        if total == 0 {
            return "No tasks"
        } else if completed == total {
            return "All done! ✅"
        } else {
            return "\(completed)/\(total)"
        }
    }

    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            userDefaults.set(encoded, forKey: todosKey)
        }
    }

    private func loadTodos() {
        if let data = userDefaults.data(forKey: todosKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decoded
        }
    }
}
