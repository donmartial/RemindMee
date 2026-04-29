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
    @Published var showCompletedTasks: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let todosKey = "SavedTodos"
    private let showCompletedKey = "ShowCompletedTasks"
    
    init() {
        showCompletedTasks = userDefaults.bool(forKey: showCompletedKey)
        loadTodos()
        // Clean up old todos (older than 7 days) on init
        cleanupOldTodos()
    }

    func addTodo(title: String, priority: Priority, dueDate: Date? = nil) {
        let newTodo = TodoItem(title: title, priority: priority, dueDate: dueDate)
        todos.append(newTodo)
        saveTodos()
    }

    func toggleCompletion(for todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            todos[index].completedAt = todos[index].isCompleted ? Date() : nil
            saveTodos()
        }
    }

    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
        saveTodos()
    }
    
    func editTodo(_ todo: TodoItem, newTitle: String, newPriority: Priority, newDueDate: Date?) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].title = newTitle
            todos[index].priority = newPriority
            todos[index].dueDate = newDueDate
            saveTodos()
        }
    }
    
    func toggleShowCompleted() {
        showCompletedTasks.toggle()
        userDefaults.set(showCompletedTasks, forKey: showCompletedKey)
    }
    
    func markAllAsCompleted() {
        for index in todos.indices {
            if Calendar.current.isDateInToday(todos[index].createdAt) && !todos[index].isCompleted {
                todos[index].isCompleted = true
                todos[index].completedAt = Date()
            }
        }
        saveTodos()
    }
    
    func deleteAllCompleted() {
        todos.removeAll { todo in
            todo.isCompleted && Calendar.current.isDateInToday(todo.createdAt)
        }
        saveTodos()
    }
    
    private func cleanupOldTodos() {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let oldCount = todos.count
        todos.removeAll { todo in
            todo.createdAt < sevenDaysAgo
        }
        
        // Save if we removed any old todos
        if todos.count != oldCount {
            saveTodos()
        }
    }

    var sortedTodos: [TodoItem] {
        let todaysTodos = todos.filter { Calendar.current.isDateInToday($0.createdAt) }
        let filteredTodos: [TodoItem]
        
        if showCompletedTasks {
            filteredTodos = todaysTodos
        } else {
            filteredTodos = todaysTodos.filter { !$0.isCompleted }
        }
        
        return filteredTodos.sorted { first, second in
            // First sort by completion status (incomplete first)
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted
            }
            
            // Then sort by due date (overdue and due today first)
            let firstDueToday = first.dueDate != nil && Calendar.current.isDateInToday(first.dueDate!)
            let secondDueToday = second.dueDate != nil && Calendar.current.isDateInToday(second.dueDate!)
            let firstOverdue = first.dueDate != nil && first.dueDate! < Date()
            let secondOverdue = second.dueDate != nil && second.dueDate! < Date()
            
            if firstOverdue != secondOverdue {
                return firstOverdue
            }
            
            if firstDueToday != secondDueToday {
                return firstDueToday
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
