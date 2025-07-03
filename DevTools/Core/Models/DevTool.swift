//
//  DevTool.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import Foundation

/// Protocol defining the common interface for all developer tools
/// Maintained for backward compatibility with legacy tools
protocol DevTool: Sendable {
    /// Unique identifier for the tool
    var id: String { get }
    
    /// Display name of the tool
    var name: String { get }
    
    /// SF Symbol icon name
    var icon: String { get }
    
    /// Brief description of the tool's functionality
    var description: String { get }
    
    /// Category this tool belongs to
    var category: ToolCategory { get }
    
    /// Associated route for navigation
    var route: Route { get }
}

/// Categories for organizing tools
enum ToolCategory: String, CaseIterable, Sendable {
    case dateTime = "Date & Time"
    case textProcessing = "Text Processing"
    case formatting = "Formatting"
    case encoding = "Encoding"
    case utilities = "Utilities"
    
    var icon: String {
        switch self {
        case .dateTime:
            return "clock.fill"
        case .textProcessing:
            return "text.alignleft"
        case .formatting:
            return "text.justify"
        case .encoding:
            return "lock.fill"
        case .utilities:
            return "wrench.fill"
        }
    }
}

/// Concrete implementation for available tools (legacy support)
struct ToolDefinition: DevTool {
    let id: String
    let name: String
    let icon: String
    let description: String
    let category: ToolCategory
    let route: Route
}

/// Enhanced registry supporting both legacy tools and new ToolProvider tools
struct ToolRegistry: Sendable {
    
    // MARK: - Tool Storage
    
    /// Legacy tools defined manually (immutable, so concurrency-safe)
    private static let legacyTools: [DevTool] = [
        ToolDefinition(
            id: "date-converter",
            name: "Date Converter",
            icon: "calendar.badge.clock",
            description: "Convert dates between formats, timezones, and relative time",
            category: .dateTime,
            route: .dateConverter
        ),
    ]
    
    /// New ToolProvider-based tools (thread-safe with actor isolation)
    private actor ToolStorage {
        private var providers: [any ToolProvider.Type] = []
        
        func setProviders(_ providers: [any ToolProvider.Type]) {
            self.providers = providers
        }
        
        func addProvider(_ provider: any ToolProvider.Type) {
            self.providers.append(provider)
        }
        
        func getProviders() -> [any ToolProvider.Type] {
            return providers
        }
    }
    
    private static let toolStorage = ToolStorage()
    
    // MARK: - Registration System
    
    /// Register new ToolProvider-based tools (simplified for contributors)
    /// Contributors only need to add their tool type to this array!
    static func registerTools() async {
        await toolStorage.setProviders([
            // Add new ToolProvider tools here:
            Base64EncoderTool.self,
            MarkdownPreviewTool.self,
            JSONFormatterTool.self,
            // ExampleTool.self,
            // ColorPickerTool.self,
        ])
    }
    
    /// Register a single tool provider (for dynamic registration)
    static func register<T: ToolProvider>(_ provider: T.Type) async {
        await toolStorage.addProvider(provider)
    }
    
    // MARK: - Tool Access
    
    /// Get all available tools (legacy + new framework)
    static var allTools: [DevTool] {
        get async {
            var tools: [DevTool] = Array(legacyTools)
            
            // Add tools from ToolProviders
            let providers = await toolStorage.getProviders()
            for provider in providers {
                tools.append(provider.asTool)
            }
            
            return tools
        }
    }
    
    /// Get tools by category
    static func tools(for category: ToolCategory) async -> [DevTool] {
        let allTools = await allTools
        return allTools.filter { $0.category == category }
    }
    
    /// Get tool by route
    static func tool(for route: Route) async -> DevTool? {
        let allTools = await allTools
        return allTools.first { $0.route == route }
    }
    
    /// Get tool by ID
    static func tool(for id: String) async -> DevTool? {
        let allTools = await allTools
        return allTools.first { $0.id == id }
    }
    
    /// Get ToolProvider for a specific route (for view creation)
    static func toolProvider(for route: Route) async -> (any ToolProvider.Type)? {
        guard let toolId = route.toolId else { return nil }
        let providers = await toolStorage.getProviders()
        return providers.first { $0.metadata.id == toolId }
    }
    
    // MARK: - Framework Utilities
    
    /// Initialize the tool registry (call this at app startup)
    static func initialize() async {
        await registerTools()
        await validateTools()
    }
    
    /// Validate all registered tools (development/debug helper)
    private static func validateTools() async {
        #if DEBUG
        var seenIds = Set<String>()
        let allTools = await allTools
        
        for tool in allTools {
            // Check for duplicate IDs
            if seenIds.contains(tool.id) {
                print("⚠️ Duplicate tool ID found: \(tool.id)")
            }
            seenIds.insert(tool.id)
            
            // Validate tool metadata
            if tool.name.isEmpty {
                print("⚠️ Tool \(tool.id) has empty name")
            }
            
            if tool.description.isEmpty {
                print("⚠️ Tool \(tool.id) has empty description")
            }
        }
        
        print("✅ Tool validation complete - \(allTools.count) tools registered")
        #endif
    }
} 