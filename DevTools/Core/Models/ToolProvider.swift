//
//  ToolProvider.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import SwiftUI
import Foundation

/// Protocol for creating tools in the simplified tool development framework
/// Supports single-file tool creation with optional advanced features
protocol ToolProvider {
    
    // MARK: - Required Properties
    
    /// Tool metadata containing all configuration
    static var metadata: ToolMetadata { get }
    
    /// The main view type for this tool
    associatedtype ContentView: View
    
    /// Create the main view for this tool
    /// - Returns: The tool's main view
    static func createView() -> ContentView
    
    // MARK: - Optional Properties (Default implementations provided)
    
    /// Optional view model for advanced tools
    /// - Returns: Observable object for state management (default: nil)
    static var viewModel: (any ObservableObject)? { get }
    
    /// Optional services for advanced tools
    /// - Returns: Array of tool-specific services (default: empty)
    static var services: [any ToolService] { get }
    
    /// Optional test suite for tools
    /// - Returns: Test suite for this tool (default: nil)
    static var testSuite: ToolTestSuite? { get }
    
    /// Optional tool-specific settings
    /// - Returns: Tool settings configuration (default: empty)
    static var settings: ToolSettings { get }
}

// MARK: - Default Implementations

extension ToolProvider {
    /// Default implementation - no view model
    static var viewModel: (any ObservableObject)? {
        return nil
    }
    
    /// Default implementation - no custom services
    static var services: [any ToolService] {
        return []
    }
    
    /// Default implementation - no test suite
    static var testSuite: ToolTestSuite? {
        return nil
    }
    
    /// Default implementation - default settings
    static var settings: ToolSettings {
        return ToolSettings()
    }
    
    /// Convenience method to get tool as DevTool protocol
    static var asTool: any DevTool {
        return ToolAdapter(provider: self)
    }
}

// MARK: - Supporting Types

/// Protocol for tool-specific services
protocol ToolService {
    var serviceId: String { get }
    func initialize()
    func cleanup()
}

/// Tool-specific settings configuration
struct ToolSettings {
    let supportsHistory: Bool
    let supportsPreferences: Bool
    let supportsKeyboardShortcuts: Bool
    let supportsDropFiles: Bool
    
    init(
        supportsHistory: Bool = false,
        supportsPreferences: Bool = false,
        supportsKeyboardShortcuts: Bool = false,
        supportsDropFiles: Bool = false
    ) {
        self.supportsHistory = supportsHistory
        self.supportsPreferences = supportsPreferences
        self.supportsKeyboardShortcuts = supportsKeyboardShortcuts
        self.supportsDropFiles = supportsDropFiles
    }
}

/// Test suite structure for tools
struct ToolTestSuite {
    let unitTests: [() -> Void]
    let integrationTests: [() -> Void]
    let uiTests: [() -> Void]
    
    init(
        unitTests: [() -> Void] = [],
        integrationTests: [() -> Void] = [],
        uiTests: [() -> Void] = []
    ) {
        self.unitTests = unitTests
        self.integrationTests = integrationTests
        self.uiTests = uiTests
    }
}

// MARK: - Adapter for Legacy Compatibility

/// Adapter to bridge ToolProvider to existing DevTool protocol
private struct ToolAdapter: DevTool {
    private let provider: any ToolProvider.Type
    
    init(provider: any ToolProvider.Type) {
        self.provider = provider
    }
    
    var id: String { provider.metadata.id }
    var name: String { provider.metadata.name }
    var icon: String { provider.metadata.icon }
    var description: String { provider.metadata.description }
    var category: ToolCategory { provider.metadata.category }
    var route: Route { provider.metadata.route }
} 