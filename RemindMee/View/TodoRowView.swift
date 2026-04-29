//
//  TodoRowView.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    let todoManager: TodoManager

    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                todoManager.toggleCompletion(for: todo)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Priority indicator
            Rectangle()
                .fill(priorityColor)
                .frame(width: 3, height: 20)
                .cornerRadius(1.5)
                .opacity(todo.isCompleted ? 0.3 : 1.0)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(todo.priority.emoji)
                    Text(todo.title)
                        .strikethrough(todo.isCompleted)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    Spacer()
                }
                .font(.system(size: 13))
            }

            Spacer()

            Button(action: {
                todoManager.deleteTodo(todo)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(0.7)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(backgroundColorForPriority)
        .cornerRadius(6)
    }
    
    private var priorityColor: Color {
        switch todo.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    private var backgroundColorForPriority: Color {
        if todo.isCompleted {
            return Color.clear
        }
        
        let opacity: Double = 0.1
        switch todo.priority {
        case .high: return Color.red.opacity(opacity)
        case .medium: return Color.orange.opacity(opacity)
        case .low: return Color.green.opacity(opacity)
        }
    }
}

#Preview {
    TodoRowView(
        todo: TodoItem(title: "Sample Task", priority: .medium),
        todoManager: TodoManager()
    )
}
