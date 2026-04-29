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
  @State private var isEditing = false
  @State private var editTitle = ""
  @State private var editPriority = Priority.medium
  @State private var editDueDate: Date? = nil
  @State private var showingDatePicker = false

  var body: some View {
    if isEditing {
      editingView
    } else {
      displayView
    }
  }

  private var displayView: some View {
    VStack(spacing: 4) {
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

            if todo.isOverdue {
              Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.caption)
            }
          }
          .font(.system(size: 13))

          // Due date display
          if let dueDateText = todo.dueDateFormatted {
            Text(dueDateText)
              .font(.caption2)
              .foregroundColor(todo.isOverdue ? .red : (todo.isDueToday ? .orange : .secondary))
          }
        }

        Spacer()

        // Edit button
        Button(action: {
          startEditing()
        }) {
          Image(systemName: "pencil")
            .foregroundColor(.blue)
            .font(.caption)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(0.7)

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
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 8)
    .background(backgroundColorForPriority)
    .cornerRadius(6)
  }

  private var editingView: some View {
    VStack(spacing: 8) {
      TextField("New task...", text: $editTitle)
        .textFieldStyle(RoundedBorderTextFieldStyle())

      HStack {
        Picker("", selection: $editPriority) {
          ForEach(Priority.allCases, id: \.self) { priority in
            Text("\(priority.emoji) \(priority.displayName)")
              .tag(priority)
          }
        }
        .pickerStyle(MenuPickerStyle())

        Button(action: {
          showingDatePicker.toggle()
        }) {
          Text(editDueDate == nil ? "Due Date" : "✓ Due")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(editDueDate == nil ? Color.orange : Color.green)
            .foregroundColor(.white)
            .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())

        if editDueDate != nil {
          Button(action: {
            editDueDate = nil
            showingDatePicker = false
          }) {
            Text("✕")
              .font(.caption)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color.red)
              .foregroundColor(.white)
              .cornerRadius(4)
          }
          .buttonStyle(PlainButtonStyle())
        }

        Spacer()

        Button(action: {
          isEditing = false
          showingDatePicker = false
        }) {
          Text("Cancel")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())

        Button(action: {
          saveChanges()
        }) {
          Text("Save")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
              editTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? Color.gray.opacity(0.5) : Color.blue
            )
            .foregroundColor(.white)
            .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(editTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }

      if showingDatePicker {
        DatePicker(
          "Due Date",
          selection: Binding(
            get: { editDueDate ?? Date() },
            set: { editDueDate = $0 }
          ), displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(CompactDatePickerStyle())
      }
    }
    .padding(8)
    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    .cornerRadius(6)
  }

  private func startEditing() {
    editTitle = todo.title
    editPriority = todo.priority
    editDueDate = todo.dueDate
    isEditing = true
  }

  private func saveChanges() {
    todoManager.editTodo(
      todo, newTitle: editTitle, newPriority: editPriority, newDueDate: editDueDate)
    isEditing = false
    showingDatePicker = false
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

    let opacity: Double = todo.isOverdue ? 0.2 : 0.1
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
