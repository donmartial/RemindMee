//
//  BreakSuggestion.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import Foundation

enum BreakType: String, CaseIterable {
    case microBreak = "Micro Break"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    case movement = "Movement"
    case eyeRest = "Eye Rest"
    case hydration = "Hydration"
    case posture = "Posture Check"
    case custom = "Custom"
    
    var emoji: String {
        switch self {
        case .microBreak: return "⏱️"
        case .shortBreak: return "☕"
        case .longBreak: return "🌅"
        case .movement: return "🚶"
        case .eyeRest: return "👁️"
        case .hydration: return "💧"
        case .posture: return "🪑"
        case .custom: return "⚙️"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .microBreak: return 2 * 60  // 2 minutes
        case .shortBreak: return 5 * 60  // 5 minutes
        case .longBreak: return 15 * 60  // 15 minutes
        case .movement: return 3 * 60    // 3 minutes
        case .eyeRest: return 1 * 60     // 1 minute
        case .hydration: return 1 * 60   // 1 minute
        case .posture: return 2 * 60     // 2 minutes
        case .custom: return 5 * 60      // 5 minutes default
        }
    }
}

struct BreakSuggestion: Identifiable {
    let id = UUID()
    let type: BreakType
    let activity: String
    let description: String
    
    static let suggestions: [BreakType: [BreakSuggestion]] = [
        .microBreak: [
            BreakSuggestion(type: .microBreak, activity: "Deep Breathing", description: "Take 5 deep breaths"),
            BreakSuggestion(type: .microBreak, activity: "Shoulder Rolls", description: "Roll your shoulders back 10 times"),
            BreakSuggestion(type: .microBreak, activity: "Neck Stretch", description: "Gently stretch your neck side to side"),
        ],
        .shortBreak: [
            BreakSuggestion(type: .shortBreak, activity: "Quick Walk", description: "Walk around your space for 5 minutes"),
            BreakSuggestion(type: .shortBreak, activity: "Stretching", description: "Do some light stretches"),
            BreakSuggestion(type: .shortBreak, activity: "Fresh Air", description: "Step outside or open a window"),
        ],
        .longBreak: [
            BreakSuggestion(type: .longBreak, activity: "Go Outside", description: "Take a 15-minute walk outdoors"),
            BreakSuggestion(type: .longBreak, activity: "Healthy Snack", description: "Have a nutritious snack and hydrate"),
            BreakSuggestion(type: .longBreak, activity: "Meditation", description: "Do a 10-15 minute meditation"),
        ],
        .movement: [
            BreakSuggestion(type: .movement, activity: "Jumping Jacks", description: "Do 20 jumping jacks"),
            BreakSuggestion(type: .movement, activity: "Desk Push-ups", description: "Do 10 wall or desk push-ups"),
            BreakSuggestion(type: .movement, activity: "Leg Raises", description: "Do 10 standing leg raises"),
        ],
        .eyeRest: [
            BreakSuggestion(type: .eyeRest, activity: "20-20-20 Rule", description: "Look at something 20 feet away for 20 seconds"),
            BreakSuggestion(type: .eyeRest, activity: "Eye Circles", description: "Close eyes and rotate them in circles"),
            BreakSuggestion(type: .eyeRest, activity: "Palming", description: "Cover eyes with palms for 30 seconds"),
        ],
        .hydration: [
            BreakSuggestion(type: .hydration, activity: "Drink Water", description: "Have a full glass of water"),
            BreakSuggestion(type: .hydration, activity: "Herbal Tea", description: "Make and enjoy some herbal tea"),
            BreakSuggestion(type: .hydration, activity: "Fruit Juice", description: "Have some fresh fruit juice"),
        ],
        .posture: [
            BreakSuggestion(type: .posture, activity: "Chair Adjustment", description: "Adjust your chair and desk height"),
            BreakSuggestion(type: .posture, activity: "Back Arch", description: "Arch your back and stretch backwards"),
            BreakSuggestion(type: .posture, activity: "Spinal Twist", description: "Twist your spine left and right"),
        ],
        .custom: [
            BreakSuggestion(type: .custom, activity: "Personal Activity", description: "Do your favorite break activity"),
        ]
    ]
    
    static func randomSuggestion(for type: BreakType = .shortBreak) -> BreakSuggestion {
        guard let suggestions = suggestions[type], !suggestions.isEmpty else {
            return BreakSuggestion(type: .shortBreak, activity: "Take a Break", description: "Step away from your work")
        }
        return suggestions.randomElement()!
    }
    
    static func getAllSuggestions() -> [BreakSuggestion] {
        return suggestions.values.flatMap { $0 }
    }
}