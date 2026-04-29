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
    
    init(title: String, priority: Priority) {
        self.id = UUID()
        self.title = title
        self.priority = priority
        self.isCompleted = false
        self.createdAt = Date()
    }
}