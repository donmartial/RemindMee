//
//  MenuBarView.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import SwiftUI

struct MenuBarView: View {
  @ObservedObject var todoManager: TodoManager
  @ObservedObject var reminderManager: StandUpReminderManager
  @ObservedObject var settingsManager: SettingsManager
  @ObservedObject var doNotDisturbManager: DoNotDisturbManager
  @State private var showingAddTodo = false
  @State private var newTodoTitle = ""
  @State private var newTodoPriority = Priority.medium
  @State private var newTodoDueDate: Date? = nil
  @State private var showingDueDatePicker = false

  @Environment(\.openWindow) private var openWindow

  var body: some View {
    VStack(spacing: 10) {
      // Header
      VStack(spacing: 8) {
        HStack {
          VStack(alignment: .leading) {
            Text("RemindMee")
              .font(.headline)
              .fontWeight(.semibold)
            // Task summary
            Text(todoManager.todaysTasksSummary)
              .font(.caption)
              .foregroundColor(.secondary)
          }

          Spacer()

          Button(action: {
            openSettingsWindow()
          }) {
            Image(systemName: "gearshape.fill")
              .font(.system(size: 13, weight: .semibold))
          }
          .buttonStyle(GlassIconButtonStyle(tint: .gray))
          .help("Settings")
          .keyboardShortcut(",", modifiers: .command)

          Button(action: {
            NSApplication.shared.terminate(nil)
          }) {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 13, weight: .semibold))
          }
          .buttonStyle(GlassIconButtonStyle(tint: .red))
          .help("Quit RemindMee")
          .keyboardShortcut("q", modifiers: .command)
        }

        // Stand-up reminder controls
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text("Stand-up Reminder (\(settingsManager.reminderIntervalInMinutes)min)")
              .font(.subheadline)
              .fontWeight(.medium)

            if reminderManager.isReminderActive,
              let nextDate = reminderManager.nextReminderDate
            {
              Text("Next: \(nextDate, style: .time)")
                .font(.caption)
                .foregroundColor(.secondary)
            } else {
              Text("Tap Start to begin reminders")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }

          Spacer()

          Button(action: {
            if reminderManager.isReminderActive {
              reminderManager.stopReminder()
            } else {
              reminderManager.startReminder()
            }
          }) {
            Text(reminderManager.isReminderActive ? "Stop" : "Start")
          }
          .buttonStyle(GlassPillButtonStyle(tint: reminderManager.isReminderActive ? .red : .blue))
        }

        // Do Not Disturb status
        if doNotDisturbManager.isCurrentlyInFocus {
          HStack {
            Image(systemName: "moon.fill")
              .foregroundColor(.purple)
            Text(doNotDisturbManager.getFocusStatusMessage() ?? "Focus mode active")
              .font(.caption)
              .foregroundColor(.secondary)
            Spacer()
          }
        }
      }
      .padding()
      .glassCard()

      // Add new todo section
      VStack(spacing: 8) {
        HStack {
          Text("Tasks")
            .font(.subheadline)
            .fontWeight(.medium)

          if !todoManager.todaysTasks.isEmpty {
            Button(action: {
              todoManager.toggleShowCompleted()
            }) {
              Text(todoManager.showCompletedTasks ? "Hide Done" : "Show Done")
            }
            .buttonStyle(GlassPillButtonStyle(tint: .green))
          }

          Spacer()

          // Bulk actions menu
          if !todoManager.todaysTasks.isEmpty {
            Menu {
              Button("Mark All Done") {
                todoManager.markAllAsCompleted()
              }
              .keyboardShortcut("a", modifiers: [.command, .shift])

              Button("Clear Completed") {
                todoManager.deleteAllCompleted()
              }
              .disabled(todoManager.completedTodayCount == 0)
            } label: {
              Image(systemName: "ellipsis.circle")
                .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(GlassIconButtonStyle(tint: .gray))
            .menuStyle(BorderlessButtonMenuStyle())
          }

          Button(action: {
            showingAddTodo.toggle()
          }) {
            Image(systemName: "plus.circle.fill")
              .font(.system(size: 14, weight: .semibold))
          }
          .buttonStyle(GlassIconButtonStyle(tint: .blue))
          .keyboardShortcut("n", modifiers: .command)
        }

        if showingAddTodo {
          VStack(spacing: 8) {
            TextField("New task...", text: $newTodoTitle)
              .textFieldStyle(RoundedBorderTextFieldStyle())

            HStack {
              Picker("", selection: $newTodoPriority) {
                ForEach(Priority.allCases, id: \.self) { priority in
                  Text("\(priority.emoji) \(priority.displayName)")
                    .tag(priority)
                }
              }
              .pickerStyle(MenuPickerStyle())

              Button(action: {
                showingDueDatePicker.toggle()
              }) {
                Text(newTodoDueDate == nil ? "Due Date" : "✓ Due")
              }
              .buttonStyle(GlassPillButtonStyle(tint: newTodoDueDate == nil ? .orange : .green))

              if newTodoDueDate != nil {
                Button(action: {
                  newTodoDueDate = nil
                  showingDueDatePicker = false
                }) {
                  Text("✕")
                }
                .buttonStyle(GlassPillButtonStyle(tint: .red))
              }

              Spacer()

              Button(action: {
                showingAddTodo = false
                newTodoTitle = ""
                newTodoDueDate = nil
                showingDueDatePicker = false
              }) {
                Text("Cancel")
              }
              .buttonStyle(GlassPillButtonStyle(tint: .gray))

              Button(action: {
                if !newTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                  todoManager.addTodo(
                    title: newTodoTitle, priority: newTodoPriority, dueDate: newTodoDueDate)
                  newTodoTitle = ""
                  newTodoDueDate = nil
                  showingAddTodo = false
                  showingDueDatePicker = false
                }
              }) {
                Text("Add")
              }
              .buttonStyle(GlassPillButtonStyle(tint: .blue))
              .disabled(newTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
              .opacity(
                newTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            }

            if showingDueDatePicker {
              DatePicker(
                "Due Date",
                selection: Binding(
                  get: { newTodoDueDate ?? Date() },
                  set: { newTodoDueDate = $0 }
                ), displayedComponents: [.date, .hourAndMinute]
              )
              .datePickerStyle(CompactDatePickerStyle())
            }
          }
          .padding(8)
          .glassCard(cornerRadius: 8)
        }
      }
      .padding()
      .glassCard()

      // Todo list
      ScrollView {
        LazyVStack(spacing: 4) {
          let sortedTodos = todoManager.sortedTodos

          if sortedTodos.isEmpty {
            VStack(spacing: 8) {
              Image(systemName: "checkmark.circle")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
              Text("No tasks for today!")
                .foregroundColor(.secondary)
            }
            .padding()
          } else {
            ForEach(sortedTodos) { todo in
              TodoRowView(todo: todo, todoManager: todoManager)
            }
          }
        }
        .padding(.horizontal)
        .padding(.vertical)
      }
      .frame(maxHeight: 300)
      .glassCard()
    }
    .padding(10)
    .background(
      LinearGradient(
        colors: [Color.white.opacity(0.2), Color.blue.opacity(0.08), Color.purple.opacity(0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .frame(width: 370)
  }

  private func openSettingsWindow() {
    // First, try to find and focus existing settings window
    let settingsWindows = NSApplication.shared.windows.filter { window in
      // Check both identifier and title to be more robust
      return window.identifier?.rawValue == "settings" || window.title == "Settings"
    }

    if let existingWindow = settingsWindows.first {
      // Focus existing window and bring to front
      existingWindow.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
    } else {
      // Open new window if none exists
      openWindow(id: "settings")
      // Give a small delay to ensure window is created, then focus it
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        if let newWindow = NSApplication.shared.windows.first(where: {
          $0.identifier?.rawValue == "settings" || $0.title == "Settings"
        }) {
          newWindow.makeKeyAndOrderFront(nil)
          NSApp.activate(ignoringOtherApps: true)
        }
      }
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
      .padding(6)
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

extension View {
  fileprivate func glassCard(cornerRadius: CGFloat = 10) -> some View {
    self
      .background(
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .fill(.ultraThinMaterial)
          .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
              .stroke(Color.white.opacity(0.3), lineWidth: 1)
          )
      )
      .shadow(color: Color.black.opacity(0.08), radius: 6, y: 2)
  }
}

#Preview {
  MenuBarView(
    todoManager: TodoManager(),
    reminderManager: StandUpReminderManager(),
    settingsManager: SettingsManager(),
    doNotDisturbManager: DoNotDisturbManager()
  )
}
