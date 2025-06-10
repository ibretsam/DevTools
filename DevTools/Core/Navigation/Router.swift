//
//  Router.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import SwiftUI
import Combine

/// Centralized navigation manager for the DevTools app
/// Implements the Router pattern with SwiftUI NavigationStack
@MainActor
final class Router: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The current navigation path for NavigationStack
    @Published var path = NavigationPath()
    
    /// Currently selected sidebar item
    @Published var selectedSidebarRoute: Route = .home
    
    /// Currently selected detail route (for three-column layout)
    @Published var selectedDetailRoute: Route?
    
    /// Available tools for the sidebar (cached to avoid repeated async calls)
    @Published var availableTools: [Route] = []
    
    // MARK: - Initialization
    
    init() {
        // Don't load tools immediately - wait for registry initialization
        // Tools will be loaded when the registry is initialized
    }
    
    /// Load available tools from the registry
    private func loadAvailableTools() async {
        let tools = await ToolRegistry.allTools
        let routes = tools.map { $0.route }
        
        // Update on main actor
        await MainActor.run {
            self.availableTools = routes
        }
    }
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific route
    /// - Parameter route: The destination route
    func navigate(to route: Route) {
        selectedSidebarRoute = route
        selectedDetailRoute = route
    }
    
    /// Navigate back one step
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    /// Navigate to root (home)
    func navigateToRoot() {
        path.removeLast(path.count)
        selectedSidebarRoute = .home
        selectedDetailRoute = nil
    }
    
    /// Pop to a specific number of views
    /// - Parameter count: Number of views to pop
    func popToView(count: Int) {
        let countToPop = min(count, path.count)
        path.removeLast(countToPop)
    }
    
    /// Check if backward navigation is possible
    /// - Returns: True if can navigate back
    func canNavigateBack() -> Bool {
        return !path.isEmpty
    }
    
    // MARK: - Route Management
    
    /// Refresh available tools (useful after registering new tools)
    func refreshAvailableTools() {
        Task {
            await loadAvailableTools()
        }
    }
    
    /// Reset detail selection when sidebar changes
    func clearDetailSelection() {
        selectedDetailRoute = nil
    }
} 