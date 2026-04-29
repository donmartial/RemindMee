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

                Picker(
                  "",
                  selection: Binding(
                    get: {
                      // Ensure we have a valid selection or default to 40 minutes
                      let current = settingsManager.reminderIntervalInMinutes
                      let hasValidSelection = settingsManager.availableIntervals.contains {
                        $0.minutes == current
                      }
                      return hasValidSelection ? current : 40
                    },
                    set: { newValue in
                      settingsManager.reminderIntervalInMinutes = newValue
                      // Update the reminder manager if it's currently active
                      if reminderManager.isReminderActive {
                        reminderManager.updateInterval(settingsManager.reminderInterval)
                      }
                    }
                  )
                ) {
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
                .glassInfoPill(tint: .blue)
              }
            }
            .padding(20)
          }
          .groupBoxStyle(GlassGroupBoxStyle())

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
                let statusMessage = doNotDisturbManager.getFocusStatusMessage()
              {
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
                .glassInfoPill(tint: .purple)
              }
            }
            .padding(20)
          }
          .groupBoxStyle(GlassGroupBoxStyle())

          // Menu Bar Icon Settings
          GroupBox {
            VStack(spacing: 16) {
              HStack {
                Label("Menu Bar Icon", systemImage: "menubar.rectangle")
                  .font(.headline)
                  .foregroundColor(.primary)
                Spacer()
              }

              LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12
              ) {
                ForEach(settingsManager.availableIcons, id: \.symbol) { icon in
                  Button(action: {
                    settingsManager.selectedMenuBarIcon = icon.symbol
                  }) {
                    VStack(spacing: 6) {
                      Image(systemName: icon.symbol)
                        .font(.title2)
                        .foregroundColor(
                          settingsManager.selectedMenuBarIcon == icon.symbol ? .white : .primary)

                      Text(icon.name)
                        .font(.caption2)
                        .foregroundColor(
                          settingsManager.selectedMenuBarIcon == icon.symbol ? .white : .secondary
                        )
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    }
                    .frame(width: 80, height: 70)
                    .background(
                      RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                          RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                              settingsManager.selectedMenuBarIcon == icon.symbol
                                ? Color.blue.opacity(0.55) : Color.white.opacity(0.05))
                        )
                    )
                    .overlay(
                      RoundedRectangle(cornerRadius: 12)
                        .stroke(
                          settingsManager.selectedMenuBarIcon == icon.symbol
                            ? .blue.opacity(0.95) : Color.white.opacity(0.25),
                          lineWidth: settingsManager.selectedMenuBarIcon == icon.symbol ? 2 : 1
                        )
                    )
                  }
                  .buttonStyle(.plain)
                  .shadow(color: .black.opacity(0.06), radius: 4, y: 1)
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
          .groupBoxStyle(GlassGroupBoxStyle())

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
                  .glassInfoPill(tint: .gray)
              }

              Text(
                "A productivity companion that helps you take regular breaks and manage your daily tasks effectively."
              )
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
              .buttonStyle(GlassPillButtonStyle(tint: .red))
            }
            .padding(20)
          }
          .groupBoxStyle(GlassGroupBoxStyle())
        }
        .padding(24)
      }
    }
    .frame(width: 500, height: 700)
    .background(
      LinearGradient(
        colors: [Color.white.opacity(0.18), Color.blue.opacity(0.08), Color.purple.opacity(0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .onAppear {
      // Set default to 40 minutes if not already set
      if settingsManager.reminderIntervalInMinutes <= 0 {
        settingsManager.reminderIntervalInMinutes = 40
      }
    }
  }
}

private struct GlassGroupBoxStyle: GroupBoxStyle {
  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      configuration.content
    }
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color.white.opacity(0.28), lineWidth: 1)
        )
    )
    .shadow(color: .black.opacity(0.08), radius: 7, y: 2)
  }
}

private struct GlassPillButtonStyle: ButtonStyle {
  let tint: Color

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.caption.weight(.semibold))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .foregroundColor(.white)
      .background(
        Capsule()
          .fill(tint.opacity(configuration.isPressed ? 0.45 : 0.62))
          .overlay(
            Capsule()
              .stroke(Color.white.opacity(0.3), lineWidth: 1)
          )
      )
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
  }
}

extension View {
  fileprivate func glassInfoPill(tint: Color) -> some View {
    self
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(.ultraThinMaterial)
          .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
              .fill(tint.opacity(0.12))
          )
          .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
              .stroke(Color.white.opacity(0.22), lineWidth: 1)
          )
      )
  }
}

#Preview {
  SettingsView(
    settingsManager: SettingsManager(),
    reminderManager: StandUpReminderManager(),
    doNotDisturbManager: DoNotDisturbManager()
  )
}
