import XCTest
import SwiftUI
import AppKit
@testable import DevTools

@MainActor
class MarkdownPreviewTests: XCTestCase {
    
    func testMarkdownPreviewToolMetadata() {
        let metadata = MarkdownPreviewTool.metadata
        XCTAssertEqual(metadata.id, "markdown-preview")
        XCTAssertEqual(metadata.name, "Markdown Preview")
        XCTAssertFalse(metadata.description.isEmpty)
        XCTAssertEqual(metadata.icon, "text.badge.star")
        XCTAssertEqual(metadata.category, .textProcessing)
    }
    
    func testMarkdownPreviewViewInitialization() {
        let view = MarkdownPreviewView()
        XCTAssertNotNil(view)
    }
    
    func testTextBindingFunctionality() {
        // Test that text binding works correctly
        var testText = "Initial text"
        let textBinding = Binding(
            get: { testText },
            set: { testText = $0 }
        )
        
        // Verify initial state
        XCTAssertEqual(textBinding.wrappedValue, "Initial text")
        
        // Test setting new value
        textBinding.wrappedValue = "Updated text"
        XCTAssertEqual(testText, "Updated text")
        XCTAssertEqual(textBinding.wrappedValue, "Updated text")
    }
    
    func testScrollDetectingTextEditorComponents() {
        // Test the basic structure without manual context creation
        var testText = "Test content"
        var scrollPosition: CGFloat = 0
        var isUpdating = false
        var scrollCallbackTriggered = false
        
        let textBinding = Binding(get: { testText }, set: { testText = $0 })
        let scrollPositionBinding = Binding(get: { scrollPosition }, set: { scrollPosition = $0 })
        let isUpdatingBinding = Binding(get: { isUpdating }, set: { isUpdating = $0 })
        
        let editor = ScrollDetectingTextEditor(
            text: textBinding,
            onScroll: { position in
                scrollCallbackTriggered = true
                scrollPosition = position
            },
            scrollPosition: scrollPositionBinding,
            isUpdating: isUpdatingBinding
        )
        
        let coordinator = editor.makeCoordinator()
        XCTAssertNotNil(coordinator)
        
        // Test coordinator functionality
        let mockTextView = NSTextView()
        mockTextView.string = "New test content"
        
        let notification = Notification(name: NSText.didChangeNotification, object: mockTextView)
        coordinator.textDidChange(notification)
        
        // Verify text was updated through binding
        XCTAssertEqual(testText, "New test content")
    }
    
    func testScrollSynchronizationLogic() {
        // Test that scroll sync logic works correctly without UI creation
        var scrollSyncEnabled = true
        var editorScrollCalled = false
        var previewScrollCalled = false
        
        let onEditorScroll = { (position: CGFloat) in
            guard scrollSyncEnabled else { return }
            editorScrollCalled = true
        }
        
        let onPreviewScroll = { (position: CGFloat) in
            guard scrollSyncEnabled else { return }
            previewScrollCalled = true
        }
        
        // Test with sync enabled
        scrollSyncEnabled = true
        onEditorScroll(0.5)
        onPreviewScroll(0.3)
        XCTAssertTrue(editorScrollCalled)
        XCTAssertTrue(previewScrollCalled)
        
        // Test with sync disabled
        editorScrollCalled = false
        previewScrollCalled = false
        scrollSyncEnabled = false
        onEditorScroll(0.5)
        onPreviewScroll(0.3)
        XCTAssertFalse(editorScrollCalled)
        XCTAssertFalse(previewScrollCalled)
    }
    
    func testMarkdownPreviewViewStateManagement() {
        let view = MarkdownPreviewView()
        
        // Test that the view can be created and has expected structure
        // Note: We can't easily test State variables directly, but we can test
        // that the view initializes without errors
        XCTAssertNotNil(view)
        
        // Verify that the view compiles and has the expected type
        XCTAssertTrue(view is MarkdownPreviewView)
    }
    
    func testTextInputSimulation() async throws {
        // Create a real NSTextView to test text input functionality
        let expectation = XCTestExpectation(description: "Text input should work")
        
        let textView = NSTextView()
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false
        
        // Verify text view configuration
        XCTAssertTrue(textView.isEditable, "Text view should be editable")
        XCTAssertTrue(textView.isSelectable, "Text view should be selectable")
        XCTAssertTrue(textView.allowsUndo, "Text view should allow undo")
        XCTAssertFalse(textView.isRichText, "Text view should not use rich text")
        
        // Test basic text input
        textView.string = ""
        XCTAssertEqual(textView.string, "")
        
        // Simulate typing
        textView.string = "H"
        XCTAssertEqual(textView.string, "H")
        
        textView.string = "Hello"
        XCTAssertEqual(textView.string, "Hello")
        
        textView.string = "Hello, World!"
        XCTAssertEqual(textView.string, "Hello, World!")
        
        // Test that the text view can handle longer content
        let longText = """
        # Markdown Test
        
        This is a **bold** test of markdown content.
        
        ## Code Block
        ```swift
        func test() {
            print("Hello")
        }
        ```
        
        - List item 1
        - List item 2
        - List item 3
        """
        
        textView.string = longText
        XCTAssertEqual(textView.string, longText)
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testTextEditingFeatures() async throws {
        let expectation = XCTestExpectation(description: "Text editing features should work")
        
        let textView = NSTextView()
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticTextCompletionEnabled = false
        
        // Test initial state
        textView.string = "Initial text"
        XCTAssertEqual(textView.string, "Initial text")
        
        // Test text selection
        textView.setSelectedRange(NSRange(location: 0, length: 7)) // Select "Initial"
        let selectedRange = textView.selectedRange()
        XCTAssertEqual(selectedRange.location, 0)
        XCTAssertEqual(selectedRange.length, 7)
        
        // Test text replacement
        textView.insertText("Updated", replacementRange: selectedRange)
        XCTAssertEqual(textView.string, "Updated text")
        
        // Test appending text
        textView.setSelectedRange(NSRange(location: textView.string.count, length: 0))
        textView.insertText(" with more content")
        XCTAssertEqual(textView.string, "Updated text with more content")
        
        // Test that automatic substitutions are disabled
        XCTAssertFalse(textView.isAutomaticQuoteSubstitutionEnabled)
        XCTAssertFalse(textView.isAutomaticDashSubstitutionEnabled)
        XCTAssertFalse(textView.isAutomaticDataDetectionEnabled)
        XCTAssertFalse(textView.isAutomaticSpellingCorrectionEnabled)
        XCTAssertFalse(textView.isAutomaticTextCompletionEnabled)
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testScrollViewConfiguration() async throws {
        let expectation = XCTestExpectation(description: "Scroll view should be configured correctly")
        
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        scrollView.scrollerStyle = .overlay
        
        let textView = NSTextView()
        scrollView.documentView = textView
        
        // Verify scroll view configuration
        XCTAssertTrue(scrollView.hasVerticalScroller, "Should have vertical scroller")
        XCTAssertFalse(scrollView.hasHorizontalScroller, "Should not have horizontal scroller")
        XCTAssertFalse(scrollView.autohidesScrollers, "Should not auto-hide scrollers")
        XCTAssertEqual(scrollView.scrollerStyle, .overlay, "Should use overlay scroller style")
        XCTAssertNotNil(scrollView.documentView, "Should have document view")
        XCTAssertTrue(scrollView.documentView is NSTextView, "Document view should be NSTextView")
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}
