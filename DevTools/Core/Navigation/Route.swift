//
//  Route.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import Foundation

/// Type-safe navigation routes for the DevTools app
/// Follows the Navigator pattern for centralized navigation management
enum Route: Hashable {
    case home
    case dateConverter
    case jsonFormatter
    case markdownPreview
    
    // Future tools can be added here
    // case base64Encoder
    // case urlEncoder
    // case colorPicker
    
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
        }
    }
} 