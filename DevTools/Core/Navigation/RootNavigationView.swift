//
//  RootNavigationView.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import SwiftUI

/// Root navigation view implementing the NavigationSplitView pattern for macOS
/// Follows the pattern from https://www.kiloloco.com/articles/019-swiftui-macos-navigation-basics
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
            // Restore last selected route
            let lastRoute = PersistenceService.shared.getLastSelectedRoute()
            router.selectedSidebarRoute = lastRoute
        }
    }
    
    /// Return the appropriate view for the selected route
    /// Implements the Navigator pattern for type-safe navigation
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .home:
            HomeView()
            
        case .dateConverter:
            DateConverterView()
            
        case .jsonFormatter:
            if let tool = ToolRegistry.tool(for: .jsonFormatter) {
                PlaceholderToolView(tool: tool)
            } else {
                Text("Tool not found")
            }
            
        case .markdownPreview:
            if let tool = ToolRegistry.tool(for: .markdownPreview) {
                PlaceholderToolView(tool: tool)
            } else {
                Text("Tool not found")
            }
        }
    }
}

#Preview {
    RootNavigationView()
} 