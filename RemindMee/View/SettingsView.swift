//
//  SettingsView.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @ObservedObject var reminderManager: StandUpReminderManager
    @ObservedObject var doNotDisturbManager: DoNotDisturbManager
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Stand-up Reminder Settings
                    GroupBox {
                        VStack(spacing: 16) {
                            HStack {
                                Label("Stand-up Reminder", systemImage: "figure.stand")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            // Reminder Interval Setting
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Reminder Interval")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("How often to remind you to stand up")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Picker("", selection: Binding(
                                    get: { 
                                        // Ensure we have a valid selection or default to 40 minutes
                                        let current = settingsManager.reminderIntervalInMinutes
                                        let hasValidSelection = settingsManager.availableIntervals.contains { $0.minutes == current }
                                        return hasValidSelection ? current : 40
                                    },
                                    set: { newValue in
                                        settingsManager.reminderIntervalInMinutes = newValue
                                        // Update the reminder manager if it's currently active
                                        if reminderManager.isReminderActive {
                                            reminderManager.updateInterval(settingsManager.reminderInterval)
                                        }
                                    }
                                )) {
                                    ForEach(settingsManager.availableIntervals, id: \.minutes) { interval in
                                        Text(interval.name)
                                            .tag(interval.minutes)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(minWidth: 140)
                            }
                            
                            Divider()
                            
                            // Notifications Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Show Notifications")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Display system notifications for reminders")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $settingsManager.showNotifications)
                                    .toggleStyle(.switch)
                            }
                            
                            // Active reminder info
                            if reminderManager.isReminderActive {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Changes will apply when you restart the reminder")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.top, 8)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(20)
                    }
                    .backgroundStyle(.regularMaterial)
                    
                    // Do Not Disturb Settings
                    GroupBox {
                        VStack(spacing: 16) {
                            HStack {
                                Label("Do Not Disturb", systemImage: "moon.fill")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Respect System Focus")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("Pause reminders during Focus mode")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $doNotDisturbManager.respectSystemFocus)
                                        .toggleStyle(.switch)
                                }
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Respect Calendar Events")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("Pause during meetings and events")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $doNotDisturbManager.respectCalendarEvents)
                                        .toggleStyle(.switch)
                                }
                            }
                            
                            // Current focus status
                            if doNotDisturbManager.isCurrentlyInFocus,
                               let statusMessage = doNotDisturbManager.getFocusStatusMessage() {
                                HStack {
                                    Image(systemName: "moon.fill")
                                        .foregroundColor(.purple)
                                    Text(statusMessage)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.purple.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(20)
                    }
                    .backgroundStyle(.regularMaterial)
                    
                    // Menu Bar Icon Settings
                    GroupBox {
                        VStack(spacing: 16) {
                            HStack {
                                Label("Menu Bar Icon", systemImage: "menubar.rectangle")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                                ForEach(settingsManager.availableIcons, id: \.symbol) { icon in
                                    Button(action: {
                                        settingsManager.selectedMenuBarIcon = icon.symbol
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: icon.symbol)
                                                .font(.title2)
                                                .foregroundColor(settingsManager.selectedMenuBarIcon == icon.symbol ? .white : .primary)
                                            
                                            Text(icon.name)
                                                .font(.caption2)
                                                .foregroundColor(settingsManager.selectedMenuBarIcon == icon.symbol ? .white : .secondary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .frame(width: 80, height: 70)
                                        .background(
                                            settingsManager.selectedMenuBarIcon == icon.symbol ? 
                                            .blue : Color(.controlBackgroundColor)
                                        )
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    settingsManager.selectedMenuBarIcon == icon.symbol ? 
                                                    .blue : Color(.separatorColor), 
                                                    lineWidth: settingsManager.selectedMenuBarIcon == icon.symbol ? 2 : 1
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Icon changes apply immediately")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                        .padding(20)
                    }
                    .backgroundStyle(.regularMaterial)
                    
                    // About Section
                    GroupBox {
                        VStack(spacing: 16) {
                            HStack {
                                Label("About RemindMee", systemImage: "info.circle")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("Version 1.0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.secondary.opacity(0.2))
                                    .cornerRadius(6)
                            }
                            
                            Text("A productivity companion that helps you take regular breaks and manage your daily tasks effectively.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            
                            Divider()
                            
                            Button("Reset to Defaults") {
                                withAnimation {
                                    settingsManager.resetToDefaults()
                                    // Update reminder manager if active
                                    if reminderManager.isReminderActive {
                                        reminderManager.updateInterval(settingsManager.reminderInterval)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .tint(.red)
                        }
                        .padding(20)
                    }
                    .backgroundStyle(.regularMaterial)
                }
                .padding(24)
            }
        }
        .frame(width: 500, height: 700)
        .background(.regularMaterial)
        .onAppear {
            // Set default to 40 minutes if not already set
            if settingsManager.reminderIntervalInMinutes <= 0 {
                settingsManager.reminderIntervalInMinutes = 40
            }
        }
    }
}

#Preview {
    SettingsView(
        settingsManager: SettingsManager(),
        reminderManager: StandUpReminderManager(),
        doNotDisturbManager: DoNotDisturbManager()
    )
}
