//
//  Route.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import Foundation

/// Type-safe navigation routes for the DevTools app
/// Enhanced to support auto-generation from tool IDs in the simplified framework
enum Route: Hashable {
    // Core navigation
    case home
    
    // Legacy tool routes (maintained for backward compatibility)
    case dateConverter
    case jsonFormatter
    case markdownPreview
    
    // Dynamic tool routes (auto-generated from tool IDs)
    case dynamicTool(String)
    
    // MARK: - Auto-Generation Support
    
    /// Create a route from a tool ID
    /// - Parameter toolId: The tool's unique identifier
    /// - Returns: Appropriate route for the tool
    static func fromToolId(_ toolId: String) -> Route {
        // Map known tool IDs to legacy routes for backward compatibility
        switch toolId {
        case "date-converter":
            return .dateConverter
        case "json-formatter":
            return .jsonFormatter
        case "markdown-preview":
            return .markdownPreview
        default:
            return .dynamicTool(toolId)
        }
    }
    
    /// Get the tool ID from this route
    var toolId: String? {
        switch self {
        case .home:
            return nil
        case .dateConverter:
            return "date-converter"
        case .jsonFormatter:
            return "json-formatter"
        case .markdownPreview:
            return "markdown-preview"
        case .dynamicTool(let toolId):
            return toolId
        }
    }
    
    // MARK: - Legacy Properties (for backward compatibility)
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .dateConverter:
            return "Date Converter"
        case .jsonFormatter:
            return "JSON Formatter"
        case .markdownPreview:
            return "Markdown Preview"
        case .dynamicTool(let toolId):
            // Title will be provided by the tool's metadata
            return toolId.replacingOccurrences(of: "-", with: " ").capitalized
        }
    }
    
    var icon: String {
        switch self {
        case .home:
            return "house"
        case .dateConverter:
            return "calendar.badge.clock"
        case .jsonFormatter:
            return "curlybraces"
        case .markdownPreview:
            return "doc.text"
        case .dynamicTool(_):
            // Icon will be provided by the tool's metadata
            return "wrench.fill"
        }
    }
    
    // MARK: - Hashable Support
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine("home")
        case .dateConverter:
            hasher.combine("dateConverter")
        case .jsonFormatter:
            hasher.combine("jsonFormatter")
        case .markdownPreview:
            hasher.combine("markdownPreview")
        case .dynamicTool(let toolId):
            hasher.combine("dynamicTool")
            hasher.combine(toolId)
        }
    }
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home),
             (.dateConverter, .dateConverter),
             (.jsonFormatter, .jsonFormatter),
             (.markdownPreview, .markdownPreview):
            return true
        case (.dynamicTool(let lhsId), .dynamicTool(let rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
} 