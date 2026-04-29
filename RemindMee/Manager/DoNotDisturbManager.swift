//
//  DoNotDisturbManager.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import Combine
import EventKit
import Foundation
import OSLog
import UserNotifications

class DoNotDisturbManager: ObservableObject {
  @Published var respectSystemFocus = true
  @Published var respectCalendarEvents = true
  @Published var isCurrentlyInFocus = false
  @Published var currentCalendarEvent: String?

  private let eventStore = EKEventStore()
  private var focusCheckTimer: Timer?
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "RemindMee", category: "DoNotDisturbManager")

  init() {
    startMonitoring()
    requestCalendarAccess()
  }

  deinit {
    stopMonitoring()
  }

  private func startMonitoring() {
    // Check focus status every 30 seconds
    focusCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
      self?.checkCurrentFocusStatus()
    }

    // Initial check
    checkCurrentFocusStatus()
  }

  private func stopMonitoring() {
    focusCheckTimer?.invalidate()
    focusCheckTimer = nil
  }

  private func requestCalendarAccess() {
    Task {
      do {
        let granted = try await eventStore.requestFullAccessToEvents()
        if !granted {
          logger.info("Calendar access denied")
        }
      } catch {
        logger.error("Calendar access error: \(error.localizedDescription, privacy: .public)")
      }
    }
  }

  private func checkCurrentFocusStatus() {
    Task { @MainActor in
      let wasInFocus = isCurrentlyInFocus

      // Check system focus status
      let systemFocusActive = await checkSystemFocusStatus()

      // Check calendar events
      let (calendarBusy, eventTitle) = checkCalendarStatus()

      isCurrentlyInFocus =
        (respectSystemFocus && systemFocusActive) || (respectCalendarEvents && calendarBusy)
      currentCalendarEvent = eventTitle

      // Log changes
      if wasInFocus != isCurrentlyInFocus {
        logger.info(
          "Focus status changed: \(self.isCurrentlyInFocus ? "Entered" : "Exited", privacy: .public) focus mode"
        )
        if let event = currentCalendarEvent {
          logger.info("Calendar event: \(event, privacy: .public)")
        }
      }
    }
  }

  private func checkSystemFocusStatus() async -> Bool {
    // Check if system focus/Do Not Disturb is active
    // This uses notification authorization status as a proxy
    let settings = await UNUserNotificationCenter.current().notificationSettings()

    // If notifications are temporarily silenced, likely in focus mode
    // Note: This is an approximation - iOS doesn't provide direct focus mode access
    return settings.authorizationStatus == .authorized && settings.alertSetting == .disabled
  }

  private func checkCalendarStatus() -> (Bool, String?) {
    guard respectCalendarEvents,
      EKEventStore.authorizationStatus(for: .event) == .fullAccess
    else {
      return (false, nil)
    }

    let now = Date()
    let oneHourFromNow = now.addingTimeInterval(3600)  // 1 hour buffer

    let predicate = eventStore.predicateForEvents(
      withStart: now.addingTimeInterval(-300),  // 5 minutes ago
      end: oneHourFromNow,
      calendars: nil
    )

    let events = eventStore.events(matching: predicate)

    // Check for current events
    for event in events {
      if event.startDate <= now && event.endDate > now {
        // Currently in an event
        return (true, event.title)
      }
    }

    // Check for upcoming events in the next 10 minutes
    let soonThreshold = now.addingTimeInterval(600)  // 10 minutes
    for event in events {
      if event.startDate > now && event.startDate <= soonThreshold {
        // Event starting soon
        return (true, "Upcoming: \(event.title ?? "Untitled event")")
      }
    }

    return (false, nil)
  }

  func shouldSuppressNotifications() -> Bool {
    return isCurrentlyInFocus
  }

  func shouldSuppressReminders() -> Bool {
    return isCurrentlyInFocus
  }

  func getFocusStatusMessage() -> String? {
    guard isCurrentlyInFocus else { return nil }

    if let event = currentCalendarEvent {
      return event.hasPrefix("Upcoming:") ? event : "In meeting: \(event)"
    }

    if respectSystemFocus {
      return "Focus mode is active"
    }

    return "Do not disturb"
  }

  // Manual override methods
  func temporarilyDisableFocus(for duration: TimeInterval) {
    Task { @MainActor in
      // Temporarily override focus detection
      let wasRespectingSystem = respectSystemFocus
      let wasRespectingCalendar = respectCalendarEvents

      respectSystemFocus = false
      respectCalendarEvents = false

      try? await Task.sleep(for: .seconds(duration))
      respectSystemFocus = wasRespectingSystem
      respectCalendarEvents = wasRespectingCalendar
      checkCurrentFocusStatus()
    }
  }

  func refreshStatus() {
    checkCurrentFocusStatus()
  }
}
