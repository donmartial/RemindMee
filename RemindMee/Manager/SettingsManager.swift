//
//  SettingsManager.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import Foundation
import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    @Published var reminderInterval: TimeInterval {
        didSet {
            UserDefaults.standard.set(reminderInterval, forKey: "reminderInterval")
        }
    }
    
    @Published var selectedMenuBarIcon: String {
        didSet {
            UserDefaults.standard.set(selectedMenuBarIcon, forKey: "selectedMenuBarIcon")
        }
    }
    
    @Published var showNotifications: Bool {
        didSet {
            UserDefaults.standard.set(showNotifications, forKey: "showNotifications")
        }
    }
    
    @Published var enableKeyboardShortcuts: Bool {
        didSet {
            UserDefaults.standard.set(enableKeyboardShortcuts, forKey: "enableKeyboardShortcuts")
        }
    }
    
    @Published var enableSmartBreaks: Bool {
        didSet {
            UserDefaults.standard.set(enableSmartBreaks, forKey: "enableSmartBreaks")
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
        ("2 hours", 120)
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
        ("Activity", "figure.walk")
    ]
    
    init() {
        // Load saved settings or use defaults
        self.reminderInterval = TimeInterval(UserDefaults.standard.object(forKey: "reminderInterval") as? Double ?? 40 * 60) // 40 minutes default
        self.selectedMenuBarIcon = UserDefaults.standard.string(forKey: "selectedMenuBarIcon") ?? "clock.fill"
        self.showNotifications = UserDefaults.standard.object(forKey: "showNotifications") as? Bool ?? true
        self.enableKeyboardShortcuts = UserDefaults.standard.object(forKey: "enableKeyboardShortcuts") as? Bool ?? true
        self.enableSmartBreaks = UserDefaults.standard.object(forKey: "enableSmartBreaks") as? Bool ?? true
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
        reminderInterval = 40 * 60 // 40 minutes
        selectedMenuBarIcon = "clock.fill"
        showNotifications = true
        enableKeyboardShortcuts = true
        enableSmartBreaks = true
    }
}