//
//  TodoItem.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import Foundation

enum Priority: Int, CaseIterable, Comparable, Codable {
  case low = 1
  case medium = 2
  case high = 3

  var displayName: String {
    switch self {
    case .low: return "Low"
    case .medium: return "Medium"
    case .high: return "High"
    }
  }

  var emoji: String {
    switch self {
    case .low: return "🟢"
    case .medium: return "🟡"
    case .high: return "🔴"
    }
  }

  var color: String {
    switch self {
    case .low: return "green"
    case .medium: return "orange"
    case .high: return "red"
    }
  }

  var sortOrder: Int {
    switch self {
    case .high: return 3
    case .medium: return 2
    case .low: return 1
    }
  }

  static func < (lhs: Priority, rhs: Priority) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

struct TodoItem: Identifiable, Codable {
  let id: UUID
  var title: String
  var priority: Priority
  var isCompleted: Bool
  var createdAt: Date
  var completedAt: Date?
  var dueDate: Date?

  init(title: String, priority: Priority, dueDate: Date? = nil) {
    self.id = UUID()
    self.title = title
    self.priority = priority
    self.isCompleted = false
    self.createdAt = Date()
    self.completedAt = nil
    self.dueDate = dueDate
  }

  var isOverdue: Bool {
    guard let dueDate = dueDate, !isCompleted else { return false }
    return dueDate < Date()
  }

  var isDueToday: Bool {
    guard let dueDate = dueDate else { return false }
    return Calendar.current.isDateInToday(dueDate)
  }

  var dueDateFormatted: String? {
    guard let dueDate = dueDate else { return nil }

    if Calendar.current.isDateInToday(dueDate) {
      return "Today \(Self.timeOnlyFormatter.string(from: dueDate))"
    } else if Calendar.current.isDateInTomorrow(dueDate) {
      return "Tomorrow"
    } else {
      return Self.shortDateFormatter.string(from: dueDate)
    }
  }

  private static let timeOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }()

  private static let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
  }()
}
