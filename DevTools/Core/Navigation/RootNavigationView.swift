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
    @EnvironmentObject private var router: Router
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView()
        } detail: {
            destinationView(for: router.selectedSidebarRoute)
        }
        .navigationSplitViewStyle(BalancedNavigationSplitViewStyle())
        .task {
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
            
        // Legacy tool routes (for tools NOT yet on the new framework)
        case .dateConverter:
            DateConverterView()
            
        // All other tools (legacy and new) are handled dynamically
        case .jsonFormatter, .markdownPreview, .dynamicTool:
            AsyncToolView(route: route)
        }
    }
}

/// Async tool view that handles async tool lookup
private struct AsyncToolView: View {
    let route: Route
    @State private var toolProvider: (any ToolProvider.Type)?
    @State private var tool: DevTool?
    @State private var isLoading = true
    @State private var fallbackName: String = "Tool"
    @State private var toolView: AnyView?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading \(fallbackName)...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let toolView = toolView {
                toolView
            } else if let tool = tool {
                // Fallback to placeholder for legacy tools without a specific view
                PlaceholderToolView(tool: tool)
            } else {
                ErrorView(message: "Tool '\(fallbackName)' not found")
            }
        }
        .task(id: route) {
            await loadTool()
        }
    }

    @MainActor
    private func loadTool() async {
        isLoading = true
        
        // Set a default name first
        let initialName = await ToolRegistry.tool(for: route)?.name ?? "Tool"
        fallbackName = initialName

        // Try to get ToolProvider first for new framework tools
        let provider = await ToolRegistry.toolProvider(for: route)

        // If no provider, it might be a legacy tool.
        let toolFallback = await ToolRegistry.tool(for: route)

        // Create the view on the main actor if we have a provider
        if let provider = provider {
            toolView = AnyView(provider.createView())
        } else {
            toolView = nil
        }
        
        self.toolProvider = provider
        self.tool = toolFallback
        self.isLoading = false
        
        if let finalName = toolFallback?.name {
            self.fallbackName = finalName
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