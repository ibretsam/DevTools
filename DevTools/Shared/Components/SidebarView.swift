//
//  SidebarView.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import SwiftUI

/// Sidebar navigation component for the DevTools app
/// Implements the macOS NavigationSplitView sidebar pattern
struct SidebarView: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        List(selection: $router.selectedSidebarRoute) {
            // Home section
            NavigationLink(value: Route.home) {
                Label("Home", systemImage: Route.home.icon)
            }
            
            Divider()
            
            // Tools section
            Section("Developer Tools") {
                ForEach(router.availableTools, id: \.self) { route in
                    NavigationLink(value: route) {
                        Label(route.title, systemImage: route.icon)
                    }
                }
            }
        }
        .navigationTitle("DevTools")
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
        .onChange(of: router.selectedSidebarRoute) { _, newRoute in
            // Save the selected route for persistence
            PersistenceService.shared.saveSelectedRoute(newRoute)
            
            // Clear detail selection when sidebar changes
            router.clearDetailSelection()
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView()
    } detail: {
        Text("Select a tool")
    }
    .environmentObject(Router())
} 