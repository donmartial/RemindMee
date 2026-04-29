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
        VStack(spacing: 0) {
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
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Settings")
                    .keyboardShortcut(",", modifiers: .command)

                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                           let nextDate = reminderManager.nextReminderDate {
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
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(reminderManager.isReminderActive ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

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
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(3)
                        }
                        .buttonStyle(PlainButtonStyle())
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
                                .foregroundColor(.secondary)
                        }
                        .menuStyle(BorderlessButtonMenuStyle())
                    }

                    Button(action: {
                        showingAddTodo.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(newTodoDueDate == nil ? Color.orange : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())

                            if newTodoDueDate != nil {
                                Button(action: {
                                    newTodoDueDate = nil
                                    showingDueDatePicker = false
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
                                showingAddTodo = false
                                newTodoTitle = ""
                                newTodoDueDate = nil
                                showingDueDatePicker = false
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
                                if !newTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    todoManager.addTodo(title: newTodoTitle, priority: newTodoPriority, dueDate: newTodoDueDate)
                                    newTodoTitle = ""
                                    newTodoDueDate = nil
                                    showingAddTodo = false
                                    showingDueDatePicker = false
                                }
                            }) {
                                Text("Add")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(newTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(newTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        
                        if showingDueDatePicker {
                            DatePicker("Due Date", selection: Binding(
                                get: { newTodoDueDate ?? Date() },
                                set: { newTodoDueDate = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                        }
                    }
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .cornerRadius(6)
                }
            }
            .padding()

            Divider()

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
        }
        .frame(width: 350)
    }

    private func openSettingsWindow() {
        // First, try to find and focus existing settings window
        let settingsWindows = NSApplication.shared.windows.filter { window in
            // Check both identifier and title to be more robust
            return window.identifier?.rawValue == "settings" || 
                   window.title == "Settings"
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

#Preview {
    MenuBarView(
        todoManager: TodoManager(),
        reminderManager: StandUpReminderManager(),
        settingsManager: SettingsManager(),
        doNotDisturbManager: DoNotDisturbManager()
    )
}
