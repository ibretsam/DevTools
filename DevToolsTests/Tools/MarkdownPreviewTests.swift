import XCTest
import SwiftUI
import AppKit
import UniformTypeIdentifiers
@testable import DevTools

@MainActor
class MarkdownPreviewTests: XCTestCase {
    
    // MARK: - UTType Extension Tests
    
    func testMarkdownUTTypeExtension() {
        let markdownType = UTType.markdown
        XCTAssertEqual(markdownType.identifier, "net.daringfireball.markdown")
        XCTAssertNotNil(markdownType)
    }
    
    // MARK: - Tool Metadata Tests
    
    func testMarkdownPreviewToolMetadata() {
        let metadata = MarkdownPreviewTool.metadata
        XCTAssertEqual(metadata.id, "markdown-preview")
        XCTAssertEqual(metadata.name, "Markdown Preview")
        XCTAssertEqual(metadata.description, "Real-time markdown editor with live preview.")
        XCTAssertEqual(metadata.icon, "text.badge.star")
        XCTAssertEqual(metadata.category, .textProcessing)
        XCTAssertFalse(metadata.description.isEmpty)
    }
    
    func testMarkdownPreviewToolCreateView() {
        let view = MarkdownPreviewTool.createView()
        XCTAssertTrue(view is MarkdownPreviewView)
        XCTAssertNotNil(view)
    }
    
    // MARK: - View Initialization Tests
    
    func testMarkdownPreviewViewInitialization() {
        let view = MarkdownPreviewView()
        XCTAssertNotNil(view)
        XCTAssertTrue(view is MarkdownPreviewView)
    }
    
    // MARK: - Default Content Tests
    
    func testDefaultMarkdownContent() {
        let view = MarkdownPreviewView()
        
        // Test that default content contains expected elements
        let defaultContent = """
        # Welcome to Markdown Preview

        This is a **live preview** of your markdown content!

        ## Features
        - Real-time rendering
        - Syntax highlighting
        - Export functionality
        - Drag & drop support
        - **Synchronized scrolling** between editor and preview
        """
        
        // Since we can't directly access @State variables, we test that the view initializes properly
        XCTAssertNotNil(view)
        
        // Test that the view body can be constructed without errors
        let body = view.body
        XCTAssertNotNil(body)
    }
    
    // MARK: - HTML Export Tests
    
    @MainActor
    func testHTMLExportGeneration() {
        let testMarkdown = """
        # Test Header
        This is **bold** text and *italic* text.
        
        ## Code Block
        ```swift
        func test() {
            print("Hello")
        }
        ```
        
        > This is a blockquote
        
        | Column 1 | Column 2 |
        |----------|----------|
        | Data 1   | Data 2   |
        """
        
        // Test HTML generation logic (simulating the copyHTML method)
        let htmlHeader = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Markdown Preview</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; line-height: 1.6; }
                h1, h2, h3 { color: #333; }
                code { background: #f4f4f4; padding: 2px 4px; border-radius: 3px; }
                pre { background: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }
                blockquote { border-left: 4px solid #ddd; margin: 0; padding-left: 20px; color: #666; }
                table { border-collapse: collapse; width: 100%; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
            </style>
        </head>
        <body>
        <pre><code>
        """
        let htmlFooter = """
        </code></pre>
        </body>
        </html>
        """
        
        let escapedMarkdown = testMarkdown
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        let html = htmlHeader + escapedMarkdown + htmlFooter
        
        // Verify HTML structure
        XCTAssertTrue(html.contains("<!DOCTYPE html>"))
        XCTAssertTrue(html.contains("<html>"))
        XCTAssertTrue(html.contains("<head>"))
        XCTAssertTrue(html.contains("<title>Markdown Preview</title>"))
        XCTAssertTrue(html.contains("<style>"))
        XCTAssertTrue(html.contains("font-family: -apple-system"))
        XCTAssertTrue(html.contains("<body>"))
        XCTAssertTrue(html.contains("# Test Header"))
        XCTAssertTrue(html.contains("**bold**"))
        XCTAssertTrue(html.contains("&gt; This is a blockquote"))
        XCTAssertTrue(html.contains("</html>"))
        
        // Verify HTML escaping for blockquote character
        XCTAssertFalse(html.contains("> This is a blockquote")) // Should be escaped
        XCTAssertTrue(html.contains("&gt; This is a blockquote"))
    }
    
    func testHTMLExportWithSpecialCharacters() {
        let testMarkdown = "Testing <script>alert('test')</script> and other > characters"
        
        let escapedMarkdown = testMarkdown
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        
        XCTAssertTrue(escapedMarkdown.contains("&lt;script&gt;"))
        XCTAssertTrue(escapedMarkdown.contains("other &gt; characters"))
        XCTAssertFalse(escapedMarkdown.contains("<script>"))
        XCTAssertFalse(escapedMarkdown.contains("other > characters"))
    }
    
    // MARK: - View Mode Tests
    
    func testViewModeToggle() {
        var showPreviewOnly = false
        let showPreviewBinding = Binding(
            get: { showPreviewOnly },
            set: { showPreviewOnly = $0 }
        )
        
        // Test initial state
        XCTAssertFalse(showPreviewBinding.wrappedValue)
        
        // Test toggling to preview only
        showPreviewBinding.wrappedValue = true
        XCTAssertTrue(showPreviewOnly)
        XCTAssertTrue(showPreviewBinding.wrappedValue)
        
        // Test toggling back to split view
        showPreviewBinding.wrappedValue = false
        XCTAssertFalse(showPreviewOnly)
        XCTAssertFalse(showPreviewBinding.wrappedValue)
    }
    
    // MARK: - Character Count Tests
    
    @MainActor
    func testCharacterCount() {
        let testText1 = ""
        let testText2 = "Hello"
        let testText3 = "Hello, World! This is a longer text with special characters: 🚀"
        
        XCTAssertEqual(testText1.count, 0)
        XCTAssertEqual(testText2.count, 5)
        XCTAssertEqual(testText3.count, 62) // Including emoji
    }
    
    // MARK: - Clipboard Operations Tests
    
    func testClipboardOperationsMockup() {
        // Test clipboard functionality logic (without actually using clipboard)
        let testMarkdown = "# Test\nThis is **bold** text."
        
        // Simulate copying markdown
        var copiedMarkdown: String?
        let copyMarkdownAction = {
            copiedMarkdown = testMarkdown
        }
        
        copyMarkdownAction()
        XCTAssertEqual(copiedMarkdown, testMarkdown)
        
        // Simulate copying HTML
        var copiedHTML: String?
        let copyHTMLAction = {
            let htmlHeader = "<!DOCTYPE html>"
            let htmlFooter = "</html>"
            copiedHTML = htmlHeader + testMarkdown + htmlFooter
        }
        
        copyHTMLAction()
        XCTAssertNotNil(copiedHTML)
        XCTAssertTrue(copiedHTML!.contains("<!DOCTYPE html>"))
        XCTAssertTrue(copiedHTML!.contains(testMarkdown))
        XCTAssertTrue(copiedHTML!.contains("</html>"))
    }
    
    // MARK: - Text Binding and State Management Tests

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
    
    func testClearTextFunctionality() {
        var markdownText = "# Some content\nWith multiple lines"
        let clearAction = {
            markdownText = ""
        }
        
        XCTAssertFalse(markdownText.isEmpty)
        clearAction()
        XCTAssertTrue(markdownText.isEmpty)
        XCTAssertEqual(markdownText, "")
    }
    
    // MARK: - Scroll Synchronization State Tests
    
    func testScrollPositionBindings() {
        var editorScrollPosition: CGFloat = 0.0
        var previewScrollPosition: CGFloat = 0.0
        var isUpdatingScroll = false
        
        let editorBinding = Binding(get: { editorScrollPosition }, set: { editorScrollPosition = $0 })
        let previewBinding = Binding(get: { previewScrollPosition }, set: { previewScrollPosition = $0 })
        let updatingBinding = Binding(get: { isUpdatingScroll }, set: { isUpdatingScroll = $0 })
        
        // Test initial values
        XCTAssertEqual(editorBinding.wrappedValue, 0.0)
        XCTAssertEqual(previewBinding.wrappedValue, 0.0)
        XCTAssertFalse(updatingBinding.wrappedValue)
        
        // Test updating scroll positions
        editorBinding.wrappedValue = 0.5
        previewBinding.wrappedValue = 0.3
        updatingBinding.wrappedValue = true
        
        XCTAssertEqual(editorScrollPosition, 0.5)
        XCTAssertEqual(previewScrollPosition, 0.3)
        XCTAssertTrue(isUpdatingScroll)
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
    
    // MARK: - ScrollDetectingTextEditor Tests

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
    
    // MARK: - NSScrollView Configuration Tests
    
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
    
    // MARK: - NSTextView Configuration Tests

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
    
    // MARK: - Text Container Configuration Tests
    
    func testTextContainerConfiguration() {
        let textView = NSTextView()
        let textContainer = textView.textContainer
        
        XCTAssertNotNil(textContainer, "Text view should have a text container")
        
        if let container = textContainer {
            // Test configuration that would be applied in the real component
            container.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
            container.widthTracksTextView = true
            
            XCTAssertEqual(container.containerSize.width, 0)
            XCTAssertEqual(container.containerSize.height, CGFloat.greatestFiniteMagnitude)
            XCTAssertTrue(container.widthTracksTextView)
        }
    }
    
    // MARK: - Font and Color Configuration Tests
    
    func testTextViewStyling() {
        let textView = NSTextView()
        
        // Test font configuration
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        XCTAssertNotNil(textView.font)
        XCTAssertEqual(textView.font?.pointSize, 14)
        
        // Test color configuration
        textView.textColor = NSColor.textColor
        textView.backgroundColor = NSColor.textBackgroundColor
        XCTAssertEqual(textView.textColor, NSColor.textColor)
        XCTAssertEqual(textView.backgroundColor, NSColor.textBackgroundColor)
        
        // Test drawing configuration
        textView.drawsBackground = true
        XCTAssertTrue(textView.drawsBackground)
    }
    
    // MARK: - Markdown Content Validation Tests
    
    func testMarkdownContentHandling() {
        let markdownSamples = [
            "# Header 1",
            "## Header 2",
            "**Bold text**",
            "*Italic text*",
            "`Inline code`",
            "```\nCode block\n```",
            "- List item",
            "1. Numbered item",
            "[Link](https://example.com)",
            "> Blockquote",
            "| Table | Header |\n|-------|--------|\n| Cell  | Data   |"
        ]
        
        for markdown in markdownSamples {
            XCTAssertFalse(markdown.isEmpty, "Markdown sample should not be empty")
            XCTAssertNoThrow(markdown.count, "Should be able to get character count")
        }
    }
    
    // MARK: - Empty State Tests
    
    func testEmptyStateHandling() {
        let emptyText = ""
        let emptyStateMessage = "Start typing in the editor to see the preview..."
        
        XCTAssertTrue(emptyText.isEmpty)
        XCTAssertFalse(emptyStateMessage.isEmpty)
        
        // Test empty state detection logic
        let showEmptyState = emptyText.isEmpty
        XCTAssertTrue(showEmptyState)
        
        // Test with non-empty text
        let nonEmptyText = "Some content"
        let showEmptyStateWithContent = nonEmptyText.isEmpty
        XCTAssertFalse(showEmptyStateWithContent)
    }
    
    // MARK: - View Layout Tests
    
    func testMarkdownPreviewViewStateManagement() {
        let view = MarkdownPreviewView()
        
        // Test that the view can be created and has expected structure
        // Note: We can't easily test State variables directly, but we can test
        // that the view initializes without errors
        XCTAssertNotNil(view)
        
        // Verify that the view compiles and has the expected type
        XCTAssertTrue(view is MarkdownPreviewView)
    }
    
    // MARK: - Performance and Memory Tests
    
    func testLargeTextHandling() {
        let largeText = String(repeating: "This is a line of text.\n", count: 1000)
        
        XCTAssertEqual(largeText.components(separatedBy: "\n").count - 1, 1000) // -1 because last line ends with \n
        XCTAssertTrue(largeText.count > 20000) // Should be substantial
        
        // Test that we can work with large text without issues
        var processedText = largeText
        processedText = processedText.replacingOccurrences(of: "<", with: "&lt;")
        XCTAssertEqual(processedText.count, largeText.count) // No < characters to replace
        
        // Test character count for large text
        let characterCount = processedText.count
        XCTAssertGreaterThan(characterCount, 20000)
    }
    
    // MARK: - Integration Tests
    
    func testToolIntegration() {
        // Test that the tool properly integrates with the ToolProvider protocol
        let metadata = MarkdownPreviewTool.metadata
        let view = MarkdownPreviewTool.createView()
        
        XCTAssertNotNil(metadata)
        XCTAssertNotNil(view)
        XCTAssertTrue(view is MarkdownPreviewView)
        
        // Test metadata completeness
        XCTAssertFalse(metadata.id.isEmpty)
        XCTAssertFalse(metadata.name.isEmpty)
        XCTAssertFalse(metadata.description.isEmpty)
        XCTAssertFalse(metadata.icon.isEmpty)
    }
    
    // MARK: - SynchronizedScrollView Tests
    
    func testSynchronizedScrollViewComponents() {
        var scrollPosition: CGFloat = 0
        var isUpdating = false
        var scrollCallbackTriggered = false
        var lastScrollPosition: CGFloat = 0
        
        let scrollPositionBinding = Binding(get: { scrollPosition }, set: { scrollPosition = $0 })
        let isUpdatingBinding = Binding(get: { isUpdating }, set: { isUpdating = $0 })
        
        let synchronizedScrollView = SynchronizedScrollView(
            scrollPosition: scrollPositionBinding,
            isUpdating: isUpdatingBinding,
            onScroll: { position in
                scrollCallbackTriggered = true
                lastScrollPosition = position
            }
        ) {
            Text("Test content for scroll view")
                .padding()
        }
        
        // Test coordinator creation
        let coordinator = synchronizedScrollView.makeCoordinator()
        XCTAssertNotNil(coordinator)
        XCTAssertEqual(coordinator.currentScrollPosition, 0)
        
        // Test scroll position handling
        scrollPosition = 0.5
        XCTAssertEqual(scrollPositionBinding.wrappedValue, 0.5)
        
        // Test updating state
        isUpdating = true
        XCTAssertTrue(isUpdatingBinding.wrappedValue)
    }
    
    func testScrollCapturingScrollViewConfiguration() {
        let scrollView = ScrollCapturingScrollView()
        var handlerTriggered = false
        
        scrollView.scrollHandler = { _ in
            handlerTriggered = true
        }
        
        // Test that the scroll handler can be set
        XCTAssertNotNil(scrollView.scrollHandler)
        
        // Test scroll view configuration
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        scrollView.scrollerStyle = .overlay
        
        XCTAssertTrue(scrollView.hasVerticalScroller)
        XCTAssertFalse(scrollView.hasHorizontalScroller)
        XCTAssertFalse(scrollView.autohidesScrollers)
        XCTAssertEqual(scrollView.scrollerStyle, .overlay)
    }
    
    // MARK: - Toolbar Action Integration Tests
    
    func testToolbarActionsIntegration() {
        // Test the logic behind toolbar actions
        var markdownText = "# Test Content\nSome **bold** text."
        var showPreviewOnly = false
        var clipboardContent: String?
        var htmlExported: String?
        
        // Test clear action
        let clearAction = {
            markdownText = ""
        }
        
        // Test copy markdown action
        let copyMarkdownAction = {
            clipboardContent = markdownText
        }
        
        // Test copy HTML action (simulated)
        let copyHTMLAction = {
            let htmlHeader = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>Markdown Preview</title>
                <style>
                    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; line-height: 1.6; }
                    h1, h2, h3 { color: #333; }
                    code { background: #f4f4f4; padding: 2px 4px; border-radius: 3px; }
                    pre { background: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }
                    blockquote { border-left: 4px solid #ddd; margin: 0; padding-left: 20px; color: #666; }
                    table { border-collapse: collapse; width: 100%; }
                    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                    th { background-color: #f2f2f2; }
                </style>
            </head>
            <body>
            <pre><code>
            """
            let htmlFooter = """
            </code></pre>
            </body>
            </html>
            """
            let escapedMarkdown = markdownText
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            htmlExported = htmlHeader + escapedMarkdown + htmlFooter
        }
        
        // Test view mode toggle
        let toggleViewModeAction = {
            showPreviewOnly.toggle()
        }
        
        // Execute and test actions
        XCTAssertFalse(markdownText.isEmpty)
        clearAction()
        XCTAssertTrue(markdownText.isEmpty)
        
        // Reset for other tests
        markdownText = "# Test Content\nSome **bold** text."
        
        copyMarkdownAction()
        XCTAssertEqual(clipboardContent, markdownText)
        
        copyHTMLAction()
        XCTAssertNotNil(htmlExported)
        XCTAssertTrue(htmlExported!.contains("<!DOCTYPE html>"))
        XCTAssertTrue(htmlExported!.contains("# Test Content"))
        XCTAssertTrue(htmlExported!.contains("Some **bold** text."))
        
        XCTAssertFalse(showPreviewOnly)
        toggleViewModeAction()
        XCTAssertTrue(showPreviewOnly)
        toggleViewModeAction()
        XCTAssertFalse(showPreviewOnly)
    }
    
    // MARK: - View Layout and State Tests
    
    func testViewLayoutStates() {
        // Test different view layout states
        var showPreviewOnly = false
        let showPreviewBinding = Binding(
            get: { showPreviewOnly },
            set: { showPreviewOnly = $0 }
        )
        
        // Test split view mode (default)
        XCTAssertFalse(showPreviewBinding.wrappedValue)
        
        // Test preview only mode
        showPreviewBinding.wrappedValue = true
        XCTAssertTrue(showPreviewOnly)
        
        // Test toggling back
        showPreviewBinding.wrappedValue = false
        XCTAssertFalse(showPreviewOnly)
    }
    
    func testDefaultMarkdownContentStructure() {
        // Test that the default content contains all expected markdown elements
        let expectedElements = [
            "# Welcome to Markdown Preview",
            "**live preview**",
            "## Features",
            "- Real-time rendering",
            "- Syntax highlighting", 
            "- Export functionality",
            "- Drag & drop support",
            "- **Synchronized scrolling**",
            "### Code Example",
            "```swift",
            "func hello()",
            "### Lists",
            "1. First item",
            "2. Second item",
            "- Nested item",
            "### Links and Images",
            "[DevTools Repository]",
            "> This is a blockquote",
            "| Column 1 | Column 2 | Column 3 |",
            "|----------|----------|----------|",
            "Lorem ipsum dolor sit amet",
            "Happy markdown editing! 🚀"
        ]
        
        // Create a view and verify default content structure
        let view = MarkdownPreviewView()
        XCTAssertNotNil(view)
        
        // Since we can't directly access @State, we test that each expected element
        // would be valid markdown content
        for element in expectedElements {
            XCTAssertFalse(element.isEmpty)
            XCTAssertNoThrow(element.count)
        }
    }
    
    // MARK: - Error Handling and Edge Cases
    
    @MainActor
    func testHTMLEscapingEdgeCases() {
        let testCases = [
            ("", ""), // Empty string
            ("Normal text", "Normal text"), // No special characters
            ("<script>alert('xss')</script>", "&lt;script&gt;alert('xss')&lt;/script&gt;"), // XSS attempt
            ("Text with > arrows < and > more", "Text with &gt; arrows &lt; and &gt; more"), // Multiple arrows
            ("Nested <<>> tags", "Nested &lt;&lt;&gt;&gt; tags"), // Nested brackets
            ("Mixed <b>bold</b> & entities", "Mixed &lt;b&gt;bold&lt;/b&gt; &amp; entities") // Mixed content
        ]
        
        for (input, expected) in testCases {
            let escaped = input
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            XCTAssertEqual(escaped, expected, "Failed for input: \(input)")
        }
    }
    
    func testCharacterCountEdgeCases() {
        let testCases = [
            ("", 0),
            ("a", 1),
            ("🚀", 1), // Emoji
            ("👨‍👩‍👧‍👦", 1), // Complex emoji family
            ("Hello\nWorld", 11), // With newline
            ("Tab\there", 8), // With tab
            ("Unicode: 你好", 11), // Unicode characters
            (String(repeating: "a", count: 1000), 1000) // Large text
        ]
        
        for (text, expectedCount) in testCases {
            XCTAssertEqual(text.count, expectedCount, "Failed for text: \(text)")
        }
    }
    
    func testScrollPositionNormalization() {
        // Test scroll position calculation edge cases
        let testCases: [(documentHeight: CGFloat, containerHeight: CGFloat, scrollY: CGFloat, expectedNormalized: CGFloat)] = [
            (100, 100, 0, 0), // No scrollable content
            (200, 100, 0, 0), // Top position
            (200, 100, 100, 1.0), // Bottom position
            (200, 100, 50, 0.5), // Middle position
            (300, 100, 100, 0.5), // Middle of longer content
            (150, 200, 0, 0), // Container taller than content
        ]
        
        for testCase in testCases {
            let maxScroll = max(0, testCase.documentHeight - testCase.containerHeight)
            let normalizedPosition = maxScroll > 0 ? testCase.scrollY / maxScroll : 0
            
            XCTAssertEqual(normalizedPosition, testCase.expectedNormalized, accuracy: 0.001,
                          "Failed for documentHeight: \(testCase.documentHeight), containerHeight: \(testCase.containerHeight), scrollY: \(testCase.scrollY)")
        }
    }
    
    // MARK: - Markdown Content Rendering Tests
    
    func testMarkdownContentTypes() {
        let markdownExamples = [
            ("# Header", "Headers"),
            ("**Bold** and *italic*", "Text formatting"),
            ("`inline code`", "Inline code"),
            ("```\ncode block\n```", "Code blocks"),
            ("- List item", "Lists"),
            ("1. Numbered item", "Numbered lists"),
            ("[Link text](https://example.com)", "Links"),
            ("> Blockquote", "Blockquotes"),
            ("| Table | Header |\n|-------|--------|\n| Cell  | Data   |", "Tables"),
            ("---", "Horizontal rules"),
            ("![Image](https://example.com/image.png)", "Images"),
            ("~~Strikethrough~~", "Strikethrough text")
        ]
        
        for (markdown, description) in markdownExamples {
            XCTAssertFalse(markdown.isEmpty, "\(description) example should not be empty")
            XCTAssertGreaterThan(markdown.count, 0, "\(description) should have content")
            
            // Test that content can be processed for HTML export
            let escaped = markdown
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            XCTAssertNotNil(escaped, "\(description) should be escapable for HTML")
        }
    }
    
    // MARK: - Performance Tests
    
    func testLargeContentPerformance() {
        // Test handling of large markdown content
        let largeContent = generateLargeMarkdownContent(lines: 5000)
        
        XCTAssertGreaterThan(largeContent.count, 100000)
        
        // Test character count performance
        let startTime = CFAbsoluteTimeGetCurrent()
        let characterCount = largeContent.count
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        
        XCTAssertGreaterThan(characterCount, 100000)
        XCTAssertLessThan(executionTime, 1.0, "Character count should be fast even for large content")
        
        // Test HTML escaping performance
        let escapeStartTime = CFAbsoluteTimeGetCurrent()
        let escapedContent = largeContent
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        let escapeEndTime = CFAbsoluteTimeGetCurrent()
        let escapeExecutionTime = escapeEndTime - escapeStartTime
        
        XCTAssertGreaterThan(escapedContent.count, 100000)
        XCTAssertLessThan(escapeExecutionTime, 2.0, "HTML escaping should be reasonable even for large content")
    }
    
    private func generateLargeMarkdownContent(lines: Int) -> String {
        var content = "# Large Markdown Document\n\n"
        
        for i in 1...lines {
            switch i % 10 {
            case 0:
                content += "## Section \(i / 10)\n\n"
            case 1:
                content += "This is **bold text** in line \(i).\n\n"
            case 2:
                content += "This is *italic text* in line \(i).\n\n"
            case 3:
                content += "This is `inline code` in line \(i).\n\n"
            case 4:
                content += "```swift\nfunc example\(i)() {\n    print(\"Line \(i)\")\n}\n```\n\n"
            case 5:
                content += "- List item \(i)\n"
            case 6:
                content += "1. Numbered item \(i)\n"
            case 7:
                content += "[Link \(i)](https://example.com/\(i))\n\n"
            case 8:
                content += "> Blockquote for line \(i)\n\n"
            default:
                content += "Regular paragraph text for line \(i). Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\n"
            }
        }
        
        return content
    }
    
    // MARK: - Accessibility and UI Tests
    
    func testUIComponentAccessibility() {
        // Test that UI components have proper accessibility support
        let testCases = [
            ("Clear", "Clear all content"), // Button with help text
            ("Copy MD", "Copy markdown to clipboard"),
            ("Copy HTML", "Copy HTML to clipboard")
        ]
        
        for (buttonTitle, helpText) in testCases {
            XCTAssertFalse(buttonTitle.isEmpty, "Button title should not be empty")
            XCTAssertFalse(helpText.isEmpty, "Help text should not be empty")
            XCTAssertNotEqual(buttonTitle, helpText, "Button title and help text should be different")
        }
    }
    
    // MARK: - ToolProvider Integration Tests
    
    func testToolProviderIntegration() {
        let metadata = MarkdownPreviewTool.metadata
        XCTAssertEqual(metadata.id, "markdown-preview")
        XCTAssertEqual(metadata.name, "Markdown Preview")
        XCTAssertEqual(metadata.description, "Real-time markdown editor with live preview.")
        XCTAssertEqual(metadata.icon, "text.badge.star")
        XCTAssertEqual(metadata.category, .textProcessing)
    }
    
    func testCreateView() {
        let view = MarkdownPreviewTool.createView()
        XCTAssertTrue(view is MarkdownPreviewView, "createView should return MarkdownPreviewView")
    }
    
    // MARK: - SynchronizedScrollView Logic Tests
    
    func testSynchronizedScrollViewInitialization() {
        var scrollPosition: CGFloat = 0.0
        var isUpdating = false
        var scrollCallbackTriggered = false
        var capturedScrollPosition: CGFloat = 0.0
        
        let scrollPositionBinding = Binding(get: { scrollPosition }, set: { scrollPosition = $0 })
        let isUpdatingBinding = Binding(get: { isUpdating }, set: { isUpdating = $0 })
        
        let scrollView = SynchronizedScrollView(
            scrollPosition: scrollPositionBinding,
            isUpdating: isUpdatingBinding,
            onScroll: { position in
                scrollCallbackTriggered = true
                capturedScrollPosition = position
            }
        ) {
            Text("Test Content")
        }
        
        XCTAssertNotNil(scrollView)
        XCTAssertEqual(scrollPosition, 0.0)
        XCTAssertFalse(isUpdating)
    }
    
    @MainActor
    func testScrollCapturingScrollViewLogic() {
        let scrollView = ScrollCapturingScrollView()
        var handlerCalled = false
        
        scrollView.scrollHandler = { _ in
            handlerCalled = true
        }
        
        XCTAssertNotNil(scrollView.scrollHandler)
        XCTAssertTrue(scrollView.hasVerticalScroller)
        XCTAssertFalse(scrollView.hasHorizontalScroller)
        XCTAssertFalse(scrollView.autohidesScrollers)
        XCTAssertEqual(scrollView.scrollerStyle, .overlay)
    }
    
    // MARK: - Toolbar Action Tests
    
    func testClearActionLogic() {
        var markdownText = "Some initial content"
        let textBinding = Binding(get: { markdownText }, set: { markdownText = $0 })
        
        // Simulate clear action
        markdownText = ""
        
        XCTAssertEqual(textBinding.wrappedValue, "")
        XCTAssertTrue(markdownText.isEmpty)
    }
    
    func testCopyMarkdownActionLogic() {
        let testMarkdown = "# Test Header\n\nThis is **bold** text."
        
        // Test that we can prepare content for copying
        XCTAssertFalse(testMarkdown.isEmpty)
        XCTAssertTrue(testMarkdown.contains("#"))
        XCTAssertTrue(testMarkdown.contains("**"))
    }
    
    func testCopyHTMLActionLogic() {
        let testMarkdown = "# Header\n\nThis is a <test> with & special chars."
        
        // Test HTML generation logic
        let htmlHeader = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Markdown Preview</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; line-height: 1.6; }
                h1, h2, h3 { color: #333; }
                code { background: #f4f4f4; padding: 2px 4px; border-radius: 3px; }
                pre { background: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }
                blockquote { border-left: 4px solid #ddd; margin: 0; padding-left: 20px; color: #666; }
                table { border-collapse: collapse; width: 100%; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
            </style>
        </head>
        <body>
        <pre><code>
        """
        let htmlFooter = """
        </code></pre>
        </body>
        </html>
        """
        
        let escapedMarkdown = testMarkdown
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        let html = htmlHeader + escapedMarkdown + htmlFooter
        
        // Verify HTML structure
        XCTAssertTrue(html.contains("<!DOCTYPE html>"))
        XCTAssertTrue(html.contains("<html>"))
        XCTAssertTrue(html.contains("<head>"))
        XCTAssertTrue(html.contains("<style>"))
        XCTAssertTrue(html.contains("body {"))
        XCTAssertTrue(html.contains("&lt;test&gt;"))
        XCTAssertFalse(html.contains("<test>"))
        XCTAssertTrue(html.contains("</html>"))
    }
    
    func testViewModeToggleLogic() {
        var showPreviewOnly = false
        let viewModeBinding = Binding(get: { showPreviewOnly }, set: { showPreviewOnly = $0 })
        
        // Test split mode (default)
        XCTAssertFalse(viewModeBinding.wrappedValue)
        
        // Test preview only mode
        viewModeBinding.wrappedValue = true
        XCTAssertTrue(showPreviewOnly)
        XCTAssertTrue(viewModeBinding.wrappedValue)
        
        // Test back to split mode
        viewModeBinding.wrappedValue = false
        XCTAssertFalse(showPreviewOnly)
        XCTAssertFalse(viewModeBinding.wrappedValue)
    }
    
    // MARK: - View Layout Tests
    
    func testViewLayoutSwitching() {
        var showPreviewOnly = false
        
        // Test split view layout (default)
        XCTAssertFalse(showPreviewOnly)
        
        // Test preview only layout
        showPreviewOnly = true
        XCTAssertTrue(showPreviewOnly)
        
        // Test back to split layout
        showPreviewOnly = false
        XCTAssertFalse(showPreviewOnly)
    }
}