//
//  ToolCard.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import SwiftUI

/// Card component for displaying tools in the home page grid
struct ToolCard: View {
    let tool: DevTool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: tool.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .opacity(isHovered ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(tool.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 0)
                
                // Category badge
                HStack {
                    Image(systemName: tool.category.icon)
                        .font(.system(size: 10))
                    Text(tool.category.rawValue)
                        .font(.caption2)
                }
                .foregroundColor(.secondary.opacity(0.8))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isHovered ? Color.accentColor.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .frame(width: 200, height: 80)
    }
}

#Preview {
    HStack {
        ToolCard(
            tool: ToolRegistry.allTools[0],
            action: { print("Tool tapped") }
        )
        
        ToolCard(
            tool: ToolRegistry.allTools[1],
            action: { print("Tool tapped") }
        )
    }
    .padding()
} 
