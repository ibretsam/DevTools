//
//  RootNavigationView.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import SwiftUI

/// Root navigation view implementing the NavigationSplitView pattern for macOS
/// Enhanced to support the simplified tool development framework
struct RootNavigationView: View {
    @StateObject private var router = Router()
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView()
        } detail: {
            destinationView(for: router.selectedSidebarRoute)
        }
        .environmentObject(router)
        .navigationSplitViewStyle(BalancedNavigationSplitViewStyle())
        .onAppear {
            // Initialize tool registry
            ToolRegistry.initialize()
            
            // Restore last selected route
            let lastRoute = PersistenceService.shared.getLastSelectedRoute()
            router.selectedSidebarRoute = lastRoute
        }
    }
    
    /// Return the appropriate view for the selected route
    /// Enhanced to support both legacy tools and new ToolProvider tools
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .home:
            HomeView()
            
        // Legacy tool routes (maintained for backward compatibility)
        case .dateConverter:
            DateConverterView()
            
        case .jsonFormatter:
            if let tool = ToolRegistry.tool(for: .jsonFormatter) {
                PlaceholderToolView(tool: tool)
            } else {
                ErrorView(message: "JSON Formatter not found")
            }
            
        case .markdownPreview:
            if let tool = ToolRegistry.tool(for: .markdownPreview) {
                PlaceholderToolView(tool: tool)
            } else {
                ErrorView(message: "Markdown Preview not found")
            }
            
        // Dynamic tool routes (new framework)
        case .dynamicTool(let toolId):
            if let toolProvider = ToolRegistry.toolProvider(for: route) {
                AnyView(toolProvider.createView())
            } else if let tool = ToolRegistry.tool(for: toolId) {
                // Fallback to placeholder for tools without ToolProvider
                PlaceholderToolView(tool: tool)
            } else {
                ErrorView(message: "Tool '\(toolId)' not found")
            }
        }
    }
}

/// Error view for missing or invalid tools
private struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Tool Error")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Go to Home") {
                // Navigate back to home using EnvironmentObject router
                // The router will be available in production usage
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
            )
            .foregroundColor(.accentColor)
        }
        .padding()
        .navigationTitle("Error")
    }
}

#Preview {
    RootNavigationView()
} 