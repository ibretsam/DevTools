//
//  DevTool.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import Foundation

/// Protocol defining the common interface for all developer tools
/// Maintained for backward compatibility with legacy tools
protocol DevTool {
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
enum ToolCategory: String, CaseIterable {
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
struct ToolRegistry {
    
    // MARK: - Tool Storage
    
    /// Legacy tools defined manually
    private static let legacyTools: [DevTool] = [
        ToolDefinition(
            id: "date-converter",
            name: "Date Converter",
            icon: "calendar.badge.clock",
            description: "Convert dates between formats, timezones, and relative time",
            category: .dateTime,
            route: .dateConverter
        ),
        ToolDefinition(
            id: "json-formatter",
            name: "JSON Formatter",
            icon: "curlybraces",
            description: "Format, minify, and validate JSON data",
            category: .formatting,
            route: .jsonFormatter
        ),
        ToolDefinition(
            id: "markdown-preview",
            name: "Markdown Preview",
            icon: "doc.text",
            description: "Preview markdown content with live rendering",
            category: .textProcessing,
            route: .markdownPreview
        )
    ]
    
    /// New ToolProvider-based tools (simplified registration)
    private static var toolProviders: [any ToolProvider.Type] = []
    
    // MARK: - Registration System
    
    /// Register new ToolProvider-based tools (simplified for contributors)
    /// Contributors only need to add their tool type to this array!
    static func registerTools() {
        toolProviders = [
            // Add new ToolProvider tools here:
            Base64EncoderTool.self,
            // ExampleTool.self,
            // ColorPickerTool.self,
        ]
    }
    
    /// Register a single tool provider (for dynamic registration)
    static func register<T: ToolProvider>(_ provider: T.Type) {
        toolProviders.append(provider)
    }
    
    // MARK: - Tool Access
    
    /// Get all available tools (legacy + new framework)
    static var allTools: [DevTool] {
        var tools: [DevTool] = Array(legacyTools)
        
        // Add tools from ToolProviders
        for provider in toolProviders {
            tools.append(provider.asTool)
        }
        
        return tools
    }
    
    /// Get tools by category
    static func tools(for category: ToolCategory) -> [DevTool] {
        return allTools.filter { $0.category == category }
    }
    
    /// Get tool by route
    static func tool(for route: Route) -> DevTool? {
        return allTools.first { $0.route == route }
    }
    
    /// Get tool by ID
    static func tool(for id: String) -> DevTool? {
        return allTools.first { $0.id == id }
    }
    
    /// Get ToolProvider for a specific route (for view creation)
    static func toolProvider(for route: Route) -> (any ToolProvider.Type)? {
        guard let toolId = route.toolId else { return nil }
        return toolProviders.first { $0.metadata.id == toolId }
    }
    
    // MARK: - Framework Utilities
    
    /// Initialize the tool registry (call this at app startup)
    static func initialize() {
        registerTools()
        validateTools()
    }
    
    /// Validate all registered tools (development/debug helper)
    private static func validateTools() {
        #if DEBUG
        var seenIds = Set<String>()
        
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