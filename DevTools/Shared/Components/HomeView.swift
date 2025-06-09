//
//  HomeView.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import SwiftUI

/// Home page view displaying all available tools in a grid layout
struct HomeView: View {
    @EnvironmentObject private var router: Router
    
    // Group tools by category for better organization
    private var toolsByCategory: [ToolCategory: [DevTool]] {
        Dictionary(grouping: ToolRegistry.allTools) { $0.category }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Developer Tools")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose a tool to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Tools grid by category
                ForEach(ToolCategory.allCases, id: \.self) { category in
                    if let tools = toolsByCategory[category], !tools.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            // Category header
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(.accentColor)
                                Text(category.rawValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Tools grid
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
                                spacing: 16
                            ) {
                                ForEach(tools, id: \.id) { tool in
                                    ToolCard(tool: tool) {
                                        router.navigate(to: tool.route)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
        .navigationTitle("Home")
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(Router())
} 