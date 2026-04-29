//
//  FocusSessionManager.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import Foundation
import UserNotifications
import Combine

class FocusSessionManager: ObservableObject {
    @Published var isSessionActive = false
    @Published var currentSessionDuration: TimeInterval = 25 * 60 // 25 minutes default (Pomodoro)
    @Published var elapsedTime: TimeInterval = 0
    @Published var remainingTime: TimeInterval = 0
    @Published var sessionCount = 0
    @Published var currentBreakSuggestion: BreakSuggestion?
    @Published var showingBreakSuggestion = false
    
    private var timer: Timer?
    private var settingsManager: SettingsManager?
    
    // Available session durations (in minutes)
    let availableSessionDurations: [(name: String, minutes: Int)] = [
        ("15 minutes", 15),
        ("20 minutes", 20),
        ("25 minutes (Pomodoro)", 25),
        ("30 minutes", 30),
        ("45 minutes", 45),
        ("60 minutes", 60),
        ("90 minutes", 90)
    ]
    
    init() {
        remainingTime = currentSessionDuration
    }
    
    func configure(with settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }
    
    func startFocusSession(duration: TimeInterval? = nil) {
        if let duration = duration {
            currentSessionDuration = duration
        }
        
        stopFocusSession() // Stop any existing session
        
        isSessionActive = true
        elapsedTime = 0
        remainingTime = currentSessionDuration
        showingBreakSuggestion = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        let minutes = Int(currentSessionDuration / 60)
        print("Focus session started - \(minutes) minutes")
        
        sendFocusStartNotification()
    }
    
    func stopFocusSession() {
        timer?.invalidate()
        timer = nil
        isSessionActive = false
        elapsedTime = 0
        remainingTime = currentSessionDuration
        showingBreakSuggestion = false
        
        print("Focus session stopped")
    }
    
    func pauseFocusSession() {
        timer?.invalidate()
        timer = nil
        // Keep isSessionActive true so UI shows paused state
    }
    
    func resumeFocusSession() {
        guard isSessionActive && timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        elapsedTime += 1
        remainingTime = max(0, currentSessionDuration - elapsedTime)
        
        if remainingTime <= 0 {
            completeFocusSession()
        }
    }
    
    private func completeFocusSession() {
        timer?.invalidate()
        timer = nil
        isSessionActive = false
        sessionCount += 1
        
        // Generate break suggestion
        let breakType: BreakType = sessionCount % 4 == 0 ? .longBreak : .shortBreak
        currentBreakSuggestion = BreakSuggestion.randomSuggestion(for: breakType)
        showingBreakSuggestion = true
        
        sendFocusCompleteNotification()
        
        print("Focus session completed! Session count: \(sessionCount)")
    }
    
    var sessionDurationInMinutes: Int {
        get {
            return Int(currentSessionDuration / 60)
        }
        set {
            currentSessionDuration = TimeInterval(newValue * 60)
            if !isSessionActive {
                remainingTime = currentSessionDuration
            }
        }
    }
    
    var progressPercentage: Double {
        guard currentSessionDuration > 0 else { return 0 }
        return elapsedTime / currentSessionDuration
    }
    
    var formattedRemainingTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var isPaused: Bool {
        return isSessionActive && timer == nil
    }
    
    private func sendFocusStartNotification() {
        guard settingsManager?.showNotifications == true else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Focus Session Started"
        content.body = "Focus mode is active. Distractions are minimized."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "focusStart",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func sendFocusCompleteNotification() {
        guard settingsManager?.showNotifications == true else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "✅ Focus Session Complete!"
        
        if let suggestion = currentBreakSuggestion {
            content.body = "Great work! Time for a break: \(suggestion.activity)"
        } else {
            content.body = "Great work! Time to take a well-deserved break."
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "focusComplete",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func dismissBreakSuggestion() {
        showingBreakSuggestion = false
        currentBreakSuggestion = nil
    }
}