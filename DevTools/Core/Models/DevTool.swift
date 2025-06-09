//
//  DevTool.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import Foundation

/// Protocol defining the common interface for all developer tools
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

/// Concrete implementation for available tools
struct ToolDefinition: DevTool {
    let id: String
    let name: String
    let icon: String
    let description: String
    let category: ToolCategory
    let route: Route
}

/// Registry of all available tools
struct ToolRegistry {
    static let allTools: [DevTool] = [
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
    
    /// Get tools by category
    static func tools(for category: ToolCategory) -> [DevTool] {
        return allTools.filter { $0.category == category }
    }
    
    /// Get tool by route
    static func tool(for route: Route) -> DevTool? {
        return allTools.first { $0.route == route }
    }
} 