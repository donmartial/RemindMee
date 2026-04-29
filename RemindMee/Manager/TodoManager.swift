//
//  TodoManager.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import Combine
import Foundation
import OSLog

class TodoManager: ObservableObject {
  @Published var todos: [TodoItem] = []
  @Published var showCompletedTasks: Bool = false

  private let userDefaults = UserDefaults.standard
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "RemindMee", category: "TodoManager")

  init() {
    showCompletedTasks = userDefaults.bool(forKey: AppStorageKeys.showCompletedTasks)
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
    userDefaults.set(showCompletedTasks, forKey: AppStorageKeys.showCompletedTasks)
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
      let now = Date()
      let firstDueToday = first.dueDate.map { Calendar.current.isDateInToday($0) } ?? false
      let secondDueToday = second.dueDate.map { Calendar.current.isDateInToday($0) } ?? false
      let firstOverdue = first.dueDate.map { $0 < now } ?? false
      let secondOverdue = second.dueDate.map { $0 < now } ?? false

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
    do {
      let encoded = try JSONEncoder().encode(todos)
      userDefaults.set(encoded, forKey: AppStorageKeys.savedTodos)
    } catch {
      logger.error("Failed to encode todos: \(error.localizedDescription, privacy: .public)")
    }
  }

  private func loadTodos() {
    guard let data = userDefaults.data(forKey: AppStorageKeys.savedTodos) else {
      return
    }

    do {
      todos = try JSONDecoder().decode([TodoItem].self, from: data)
    } catch {
      logger.error("Failed to decode todos: \(error.localizedDescription, privacy: .public)")
      todos = []
    }
  }
}
