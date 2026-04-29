//
//  StandUpReminderManager.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import Combine
import Foundation
import OSLog
import UserNotifications

class StandUpReminderManager: ObservableObject {
  @Published var isReminderActive = false
  @Published var nextReminderDate: Date?

  private var timer: Timer?
  private var reminderInterval: TimeInterval = 40 * 60  // 40 minutes in seconds (default)
  private var settingsManager: SettingsManager?
  private var doNotDisturbManager: DoNotDisturbManager?
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "RemindMee", category: "StandUpReminderManager")

  init() {
    requestNotificationPermission()
  }

  func configure(with settingsManager: SettingsManager, doNotDisturbManager: DoNotDisturbManager) {
    self.settingsManager = settingsManager
    self.doNotDisturbManager = doNotDisturbManager
    self.reminderInterval = settingsManager.reminderInterval
  }

  func startReminder() {
    stopReminder()  // Stop any existing timer

    // Update interval from settings if available
    if let settingsManager = settingsManager {
      reminderInterval = settingsManager.reminderInterval
    }

    isReminderActive = true
    nextReminderDate = Date().addingTimeInterval(reminderInterval)

    timer = Timer.scheduledTimer(withTimeInterval: reminderInterval, repeats: true) {
      [weak self] _ in
      self?.checkAndSendStandUpNotification()
      self?.nextReminderDate = Date().addingTimeInterval(self?.reminderInterval ?? 0)
    }

    let minutes = Int(reminderInterval / 60)
    logger.info("Stand-up reminder started every \(minutes, privacy: .public) minutes")
  }

  func updateInterval(_ newInterval: TimeInterval) {
    reminderInterval = newInterval
    if isReminderActive {
      // Restart the timer with new interval
      startReminder()
    }
  }

  func stopReminder() {
    timer?.invalidate()
    timer = nil
    isReminderActive = false
    nextReminderDate = nil

    logger.info("Stand-up reminder stopped")
  }

  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      granted, error in
      if granted {
        self.logger.info("Notification permission granted")
      } else if let error = error {
        self.logger.error(
          "Notification permission error: \(error.localizedDescription, privacy: .public)")
      }
    }
  }

  private func sendStandUpNotification() {
    // Check if notifications are enabled in settings
    guard settingsManager?.showNotifications != false else {
      logger.info("Notifications disabled in settings")
      return
    }

    let content = UNMutableNotificationContent()

    // Use smart break suggestions if enabled
    if settingsManager?.enableSmartBreaks == true {
      let suggestion = BreakSuggestion.randomSuggestion(for: .shortBreak)
      content.title = "⏰ Break Time!"
      content.body = "\(suggestion.activity) - \(suggestion.description)"
    } else {
      content.title = "⏰ Stand Up Time!"
      let minutes = Int(reminderInterval / 60)
      content.body = "You've been working for \(minutes) minutes. Time to take a break and stretch!"
    }
    content.sound = .default

    let request = UNNotificationRequest(
      identifier: "standUpReminder",
      content: content,
      trigger: nil  // Send immediately
    )

    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        self.logger.error(
          "Error sending notification: \(error.localizedDescription, privacy: .public)")
      }
    }
  }

  private func checkAndSendStandUpNotification() {
    // Check if we should suppress notifications due to DND/Focus
    if let dndManager = doNotDisturbManager, dndManager.shouldSuppressReminders() {
      logger.info("Stand-up reminder suppressed due to focus mode")
      return
    }

    sendStandUpNotification()
  }
}
