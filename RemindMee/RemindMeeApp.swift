//
//  RemindMeeApp.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import SwiftUI
import AppKit

@main
struct RemindMeeApp: App {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var todoManager = TodoManager()
    @StateObject private var reminderManager = StandUpReminderManager()
    @StateObject private var doNotDisturbManager = DoNotDisturbManager()
    
    var body: some Scene {
        MenuBarExtra("RemindMee", systemImage: settingsManager.selectedMenuBarIcon) {
            MenuBarView(
                todoManager: todoManager,
                reminderManager: reminderManager,
                settingsManager: settingsManager,
                doNotDisturbManager: doNotDisturbManager
            )
            .onAppear {
                // Configure managers with dependencies when view appears
                reminderManager.configure(with: settingsManager, doNotDisturbManager: doNotDisturbManager)
            }
        }
        .menuBarExtraStyle(.window)

        // Settings Window
        WindowGroup("Settings", id: "settings") {
            SettingsView(
                settingsManager: settingsManager, 
                reminderManager: reminderManager,
                doNotDisturbManager: doNotDisturbManager
            )
            .onAppear {
                // Ensure only one settings window exists
                DispatchQueue.main.async {
                    let settingsWindows = NSApplication.shared.windows.filter { window in
                        window.identifier?.rawValue == "settings" || window.title == "Settings"
                    }
                    
                    // If we have multiple settings windows, close extras
                    if settingsWindows.count > 1 {
                        for (index, window) in settingsWindows.enumerated() {
                            if index > 0 { // Keep first, close others
                                window.close()
                            }
                        }
                    }
                }
            }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 700)
        .keyboardShortcut(",", modifiers: .command) // Cmd+, for settings
        
        // Hidden main window - only shows as a welcome screen if needed
        WindowGroup("RemindMee", id: "main") {
            ContentView()
        }
        .defaultSize(width: 400, height: 500)
        .windowResizability(.contentSize)
    }
}
