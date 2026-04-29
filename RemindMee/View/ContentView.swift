//
//  ContentView.swift
//  RemindMee
//
//  Created by Vo Minh Don on 29/4/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.system(size: 48))

            Text("RemindMee")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your productivity companion")
                .font(.title2)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "bell.fill", title: "Stand-up Reminders", description: "Customizable break reminders")
                FeatureRow(icon: "list.bullet", title: "Daily Todo List", description: "Manage your tasks with priority sorting")
                FeatureRow(icon: "menubar.rectangle", title: "Menu Bar Access", description: "Quick access from your menu bar")
                FeatureRow(icon: "gearshape.fill", title: "Customizable Settings", description: "Configurable base on your need")
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            
            Text("Look for the clock icon in your menu bar!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(maxWidth: 400, maxHeight: 500)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
