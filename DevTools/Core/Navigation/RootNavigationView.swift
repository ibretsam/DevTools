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
        .task {
            // Initialize tool registry asynchronously
            await ToolRegistry.initialize()
            
            // Restore last selected route
            await MainActor.run {
                let lastRoute = PersistenceService.shared.getLastSelectedRoute()
                router.selectedSidebarRoute = lastRoute
            }
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
            AsyncToolView(route: .jsonFormatter, fallbackName: "JSON Formatter")
            
        case .markdownPreview:
            AsyncToolView(route: .markdownPreview, fallbackName: "Markdown Preview")
            
        // Dynamic tool routes (new framework)
        case .dynamicTool(let toolId):
            AsyncToolView(route: route, fallbackName: toolId)
        }
    }
}

/// Async tool view that handles async tool lookup
private struct AsyncToolView: View {
    let route: Route
    let fallbackName: String
    @State private var toolProvider: (any ToolProvider.Type)?
    @State private var tool: DevTool?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading \(fallbackName)...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let toolProvider = toolProvider {
                AnyView(toolProvider.createView())
            } else if let tool = tool {
                // Fallback to placeholder for tools without ToolProvider
                PlaceholderToolView(tool: tool)
            } else {
                ErrorView(message: "Tool '\(fallbackName)' not found")
            }
        }
        .task {
            await loadTool()
        }
    }
    
    private func loadTool() async {
        // Try to get ToolProvider first
        let provider = await ToolRegistry.toolProvider(for: route)
        
        // If no provider, try to get tool for fallback
        let toolFallback: DevTool?
        if provider == nil {
            if case .dynamicTool(let toolId) = route {
                toolFallback = await ToolRegistry.tool(for: toolId)
            } else {
                toolFallback = await ToolRegistry.tool(for: route)
            }
        } else {
            toolFallback = nil
        }
        
        await MainActor.run {
            self.toolProvider = provider
            self.tool = toolFallback
            self.isLoading = false
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