//
//  ToolMetadata.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import Foundation

/// Centralized metadata structure for tool configuration
/// Part of the simplified tool development framework
struct ToolMetadata {
    /// Unique identifier for the tool (used for route generation)
    let id: String
    
    /// Display name of the tool
    let name: String
    
    /// Brief description of the tool's functionality
    let description: String
    
    /// SF Symbol icon name
    let icon: String
    
    /// Category this tool belongs to
    let category: ToolCategory
    
    /// Tool version
    let version: String
    
    /// Tool author/contributor
    let author: String
    
    /// Auto-generated route from tool ID
    var route: Route {
        Route.fromToolId(id)
    }
    
    /// Initialize with all parameters
    /// - Parameters:
    ///   - id: Unique tool identifier (kebab-case recommended)
    ///   - name: Display name for the tool
    ///   - description: Brief description of functionality
    ///   - icon: SF Symbol icon name
    ///   - category: Tool category for organization
    ///   - version: Tool version (defaults to "1.0")
    ///   - author: Tool author (defaults to "Community")
    init(
        id: String,
        name: String,
        description: String,
        icon: String,
        category: ToolCategory,
        version: String = "1.0",
        author: String = "Community"
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.version = version
        self.author = author
    }
} 