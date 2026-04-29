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
            .font(.system(size: 15, weight: .semibold))
        }
        .buttonStyle(GlassIconButtonStyle(tint: todo.isCompleted ? .green : .gray))

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
            .font(.system(size: 12, weight: .semibold))
        }
        .buttonStyle(GlassIconButtonStyle(tint: .blue))

        Button(action: {
          todoManager.deleteTodo(todo)
        }) {
          Image(systemName: "trash")
            .font(.system(size: 12, weight: .semibold))
        }
        .buttonStyle(GlassIconButtonStyle(tint: .red))
      }
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 8)
    .background(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(backgroundColorForPriority)
            .opacity(todo.isCompleted ? 0.35 : 1.0)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    )
    .shadow(color: .black.opacity(0.06), radius: 4, y: 1)
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
        }
        .buttonStyle(GlassPillButtonStyle(tint: editDueDate == nil ? .orange : .green))

        if editDueDate != nil {
          Button(action: {
            editDueDate = nil
            showingDatePicker = false
          }) {
            Text("✕")
          }
          .buttonStyle(GlassPillButtonStyle(tint: .red))
        }

        Spacer()

        Button(action: {
          isEditing = false
          showingDatePicker = false
        }) {
          Text("Cancel")
        }
        .buttonStyle(GlassPillButtonStyle(tint: .gray))

        Button(action: {
          saveChanges()
        }) {
          Text("Save")
        }
        .buttonStyle(GlassPillButtonStyle(tint: .blue))
        .disabled(editTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(editTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
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
    .background(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    )
    .shadow(color: .black.opacity(0.06), radius: 4, y: 1)
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

private struct GlassPillButtonStyle: ButtonStyle {
  let tint: Color

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.caption)
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .foregroundColor(.white)
      .background(
        Capsule()
          .fill(tint.opacity(configuration.isPressed ? 0.45 : 0.6))
          .overlay(
            Capsule()
              .stroke(Color.white.opacity(0.3), lineWidth: 1)
          )
      )
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
  }
}

private struct GlassIconButtonStyle: ButtonStyle {
  let tint: Color

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(tint.opacity(0.95))
      .padding(5)
      .background(
        Circle()
          .fill(.ultraThinMaterial)
          .overlay(
            Circle()
              .stroke(Color.white.opacity(0.22), lineWidth: 1)
          )
      )
      .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
      .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
  }
}

#Preview {
  TodoRowView(
    todo: TodoItem(title: "Sample Task", priority: .medium),
    todoManager: TodoManager()
  )
}
