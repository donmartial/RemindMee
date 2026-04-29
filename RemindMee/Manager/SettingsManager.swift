//
//  SettingsManager.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import Combine
import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
  private let userDefaults = UserDefaults.standard

  @Published var reminderInterval: TimeInterval {
    didSet {
      userDefaults.set(reminderInterval, forKey: AppStorageKeys.reminderInterval)
    }
  }

  @Published var selectedMenuBarIcon: String {
    didSet {
      userDefaults.set(selectedMenuBarIcon, forKey: AppStorageKeys.selectedMenuBarIcon)
    }
  }

  @Published var showNotifications: Bool {
    didSet {
      userDefaults.set(showNotifications, forKey: AppStorageKeys.showNotifications)
    }
  }

  @Published var enableKeyboardShortcuts: Bool {
    didSet {
      userDefaults.set(enableKeyboardShortcuts, forKey: AppStorageKeys.enableKeyboardShortcuts)
    }
  }

  @Published var enableSmartBreaks: Bool {
    didSet {
      userDefaults.set(enableSmartBreaks, forKey: AppStorageKeys.enableSmartBreaks)
    }
  }

  // Available reminder intervals (in minutes)
  let availableIntervals: [(name: String, minutes: Int)] = [
    ("15 minutes", 15),
    ("20 minutes", 20),
    ("30 minutes", 30),
    ("40 minutes", 40),
    ("45 minutes", 45),
    ("60 minutes", 60),
    ("90 minutes", 90),
    ("2 hours", 120),
  ]

  // Available menu bar icons
  let availableIcons: [(name: String, symbol: String)] = [
    ("Clock", "clock.fill"),
    ("Timer", "timer"),
    ("Bell", "bell.fill"),
    ("Alarm", "alarm.fill"),
    ("Hourglass", "hourglass"),
    ("Stopwatch", "stopwatch.fill"),
    ("Person Standing", "figure.stand"),
    ("Activity", "figure.walk"),
  ]

  init() {
    // Load saved settings or use defaults
    self.reminderInterval = TimeInterval(
      userDefaults.object(forKey: AppStorageKeys.reminderInterval) as? Double ?? 40 * 60)  // 40 minutes default
    self.selectedMenuBarIcon =
      userDefaults.string(forKey: AppStorageKeys.selectedMenuBarIcon) ?? "clock.fill"
    self.showNotifications =
      userDefaults.object(forKey: AppStorageKeys.showNotifications) as? Bool ?? true
    self.enableKeyboardShortcuts =
      userDefaults.object(forKey: AppStorageKeys.enableKeyboardShortcuts) as? Bool ?? true
    self.enableSmartBreaks =
      userDefaults.object(forKey: AppStorageKeys.enableSmartBreaks) as? Bool ?? true
  }

  var reminderIntervalInMinutes: Int {
    get {
      return Int(reminderInterval / 60)
    }
    set {
      reminderInterval = TimeInterval(newValue * 60)
    }
  }

  func setReminderInterval(minutes: Int) {
    reminderInterval = TimeInterval(minutes * 60)
  }

  func resetToDefaults() {
    reminderInterval = 40 * 60  // 40 minutes
    selectedMenuBarIcon = "clock.fill"
    showNotifications = true
    enableKeyboardShortcuts = true
    enableSmartBreaks = true
  }
}
