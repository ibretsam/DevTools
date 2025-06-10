//
//  ClipboardServiceTests.swift
//  DevToolsTests
//
//  Created by Khanh Le on 9/6/25.
//

import XCTest
import AppKit
@testable import DevTools

final class ClipboardServiceTests: XCTestCase {
    
    var clipboardService: ClipboardService!
    private let originalPasteboardContents = NSPasteboard.general.string(forType: .string)
    
    override func setUpWithError() throws {
        clipboardService = ClipboardService.shared
        // Clear clipboard before each test
        clipboardService.clear()
    }
    
    override func tearDownWithError() throws {
        // Restore original clipboard contents if any
        if let originalContents = originalPasteboardContents {
            clipboardService.copy(originalContents)
        } else {
            clipboardService.clear()
        }
        clipboardService = nil
    }
    
    // MARK: - Copy Tests
    
    func testCopyString() {
        let testString = "Hello, DevTools!"
        
        // When
        let success = clipboardService.copy(testString)
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(clipboardService.getString(), testString)
    }
    
    func testCopyURL() {
        let testURL = URL(string: "https://example.com")!
        
        // When
        let success = clipboardService.copy(testURL)
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(clipboardService.getURL(), testURL)
    }
    
    func testCopyMultipleItems() {
        let items: [NSPasteboard.PasteboardType: String] = [
            .string: "Test String",
            .URL: "https://example.com"
        ]
        
        // When
        let success = clipboardService.copy(items: items)
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(clipboardService.getString(), "Test String")
    }
    
    // MARK: - Read Tests
    
    func testGetStringWhenEmpty() {
        // Given empty clipboard
        clipboardService.clear()
        
        // When
        let result = clipboardService.getString()
        
        // Then
        XCTAssertNil(result)
    }
    
    func testGetURLWithValidString() {
        // Given
        clipboardService.copy("https://example.com")
        
        // When
        let result = clipboardService.getURL()
        
        // Then
        XCTAssertEqual(result, URL(string: "https://example.com"))
    }
    
    func testGetURLWithInvalidString() {
        // Given
        clipboardService.copy("not a url")
        
        // When
        let result = clipboardService.getURL()
        
        // Then
        XCTAssertNil(result)
    }
    
    // MARK: - Utility Tests
    
    func testHasContent() {
        // Initially empty
        clipboardService.clear()
        XCTAssertFalse(clipboardService.hasContent())
        
        // After adding content
        clipboardService.copy("test")
        XCTAssertTrue(clipboardService.hasContent())
    }
    
    func testContainsType() {
        // Given
        clipboardService.copy("test string")
        
        // When/Then
        XCTAssertTrue(clipboardService.contains(type: .string))
        XCTAssertFalse(clipboardService.contains(type: .fileURL))
    }
    
    func testAvailableTypes() {
        // Given
        clipboardService.copy("test")
        
        // When
        let types = clipboardService.availableTypes()
        
        // Then
        XCTAssertTrue(types.contains(.string))
    }
    
    func testClear() {
        // Given
        clipboardService.copy("test")
        XCTAssertTrue(clipboardService.hasContent())
        
        // When
        clipboardService.clear()
        
        // Then
        XCTAssertFalse(clipboardService.hasContent())
    }
} 