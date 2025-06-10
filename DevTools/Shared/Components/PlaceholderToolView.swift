//
//  PlaceholderToolView.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import SwiftUI

/// Reusable placeholder view for tools not yet implemented
struct PlaceholderToolView: View {
    let tool: DevTool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: tool.icon)
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text(tool.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(tool.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text("🚧 Coming Soon")
                .font(.headline)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
                .foregroundColor(.orange)
        }
        .padding()
        .navigationTitle(tool.name)
    }
}

#Preview {
    NavigationStack {
        PlaceholderToolView(tool: ToolRegistry.allTools[1])
    }
} 