//
//  ClipboardService.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import AppKit
import Foundation

/// Service for handling system clipboard operations
/// Thread-safe by being isolated to MainActor (required for NSPasteboard operations)
@MainActor
final class ClipboardService: Sendable {
    
    /// Shared instance
    static let shared = ClipboardService()
    
    private let pasteboard = NSPasteboard.general
    
    private init() {}
    
    // MARK: - Reading from Clipboard
    
    /// Get string content from clipboard
    /// - Returns: String content or nil if not available
    func getString() -> String? {
        return pasteboard.string(forType: .string)
    }
    
    /// Get URL from clipboard
    /// - Returns: URL or nil if not available
    func getURL() -> URL? {
        guard let urlString = pasteboard.string(forType: .URL) ?? pasteboard.string(forType: .string),
              let url = URL(string: urlString),
              url.scheme != nil else {
            return nil
        }
        return url
    }
    
    /// Get file URLs from clipboard (for drag & drop support)
    /// - Returns: Array of file URLs
    func getFileURLs() -> [URL] {
        guard let items = pasteboard.pasteboardItems else { return [] }
        
        var urls: [URL] = []
        for item in items {
            if let urlString = item.string(forType: .fileURL),
               let url = URL(string: urlString) {
                urls.append(url)
            }
        }
        return urls
    }
    
    /// Check if clipboard contains specific type
    /// - Parameter type: NSPasteboard.PasteboardType to check
    /// - Returns: True if clipboard contains the type
    func contains(type: NSPasteboard.PasteboardType) -> Bool {
        return pasteboard.availableType(from: [type]) != nil
    }
    
    // MARK: - Writing to Clipboard
    
    /// Copy string to clipboard
    /// - Parameter string: String to copy
    /// - Returns: True if successful
    @discardableResult
    func copy(_ string: String) -> Bool {
        pasteboard.clearContents()
        return pasteboard.setString(string, forType: .string)
    }
    
    /// Copy URL to clipboard
    /// - Parameter url: URL to copy
    /// - Returns: True if successful
    @discardableResult
    func copy(_ url: URL) -> Bool {
        pasteboard.clearContents()
        return pasteboard.setString(url.absoluteString, forType: .URL)
    }
    
    /// Copy multiple items to clipboard
    /// - Parameter items: Dictionary of type to content
    /// - Returns: True if successful
    @discardableResult
    func copy(items: [NSPasteboard.PasteboardType: String]) -> Bool {
        pasteboard.clearContents()
        
        var success = true
        for (type, content) in items {
            if !pasteboard.setString(content, forType: type) {
                success = false
            }
        }
        return success
    }
    
    // MARK: - Utility Methods
    
    /// Clear clipboard contents
    func clear() {
        pasteboard.clearContents()
    }
    
    /// Get all available types in clipboard
    /// - Returns: Array of available pasteboard types
    func availableTypes() -> [NSPasteboard.PasteboardType] {
        return pasteboard.types ?? []
    }
    
    /// Check if clipboard has any content
    /// - Returns: True if clipboard is not empty
    func hasContent() -> Bool {
        return !availableTypes().isEmpty
    }
} 