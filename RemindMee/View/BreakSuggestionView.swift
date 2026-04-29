//
//  BreakSuggestionView.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import SwiftUI

struct BreakSuggestionView: View {
    let suggestion: BreakSuggestion
    let onDismiss: () -> Void
    let onStartBreak: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(suggestion.type.emoji)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text("Break Time!")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(suggestion.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Suggestion content
            VStack(alignment: .leading, spacing: 8) {
                Text(suggestion.activity)
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text(suggestion.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Recommended duration: \(Int(suggestion.type.duration / 60)) minutes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action buttons
            HStack(spacing: 12) {
                Button("Skip") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Take Break") {
                    onStartBreak()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 8)
        .frame(width: 320)
    }
}

#Preview {
    BreakSuggestionView(
        suggestion: BreakSuggestion.randomSuggestion(for: .shortBreak),
        onDismiss: {},
        onStartBreak: {}
    )
}