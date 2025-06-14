import SwiftUI
import MarkdownUI
import UniformTypeIdentifiers
import AppKit

// MARK: - UTType Extension for Markdown
extension UTType {
    static var markdown: UTType {
        UTType(importedAs: "net.daringfireball.markdown")
    }
}

// MARK: - Tool Definition
struct MarkdownPreviewTool: ToolProvider {
    static var metadata: ToolMetadata {
        ToolMetadata(
            id: "markdown-preview",
            name: "Markdown Preview",
            description: "Real-time markdown editor with live preview.",
            icon: "text.badge.star",
            category: .textProcessing
        )
    }
    
    @MainActor
    static func createView() -> some View {
        MarkdownPreviewView()
    }
}

// MARK: - Tool View Implementation
struct MarkdownPreviewView: View {
    @State private var markdownText: String = """
    # Welcome to Markdown Preview

    This is a **live preview** of your markdown content!

    ## Features
    - Real-time rendering
    - Syntax highlighting
    - Export functionality
    - Drag & drop support
    - **Synchronized scrolling** between editor and preview

    ### Code Example
    ```swift
    func hello() {
        print("Hello, DevTools!")
    }
    ```

    ### Lists
    1. First item
    2. Second item
       - Nested item
       - Another nested item

    ### Links and Images
    [DevTools Repository](https://github.com/your-repo)

    > This is a blockquote with **bold** and *italic* text.

    | Column 1 | Column 2 | Column 3 |
    |----------|----------|----------|
    | Row 1    | Data     | More     |
    | Row 2    | Info     | Content  |

    ---

    ### More Content for Testing Scroll Sync

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

    ### Another Section

    Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

    ### Final Section

    At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.

    Happy markdown editing! 🚀
    """
    
    @State private var showPreviewOnly = false
    
    // Synchronized scrolling state
    @State private var editorScrollPosition: CGFloat = 0
    @State private var previewScrollPosition: CGFloat = 0
    @State private var isUpdatingScroll = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar()
            Divider()
            
            if showPreviewOnly {
                preview()
            } else {
                HSplitView {
                    editor()
                    preview()
                }
            }
        }
        .navigationTitle(MarkdownPreviewTool.metadata.name)
    }

    @ViewBuilder
    private func toolbar() -> some View {
        HStack {
            Picker("View Mode", selection: $showPreviewOnly) {
                Text("Split").tag(false)
                Text("Preview").tag(true)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            
            Spacer()
            
            Button("Clear", systemImage: "trash") {
                markdownText = ""
            }
            .help("Clear all content")

            Button("Copy MD", systemImage: "doc.on.doc") {
                ClipboardService.shared.copy(markdownText)
            }
            .help("Copy markdown to clipboard")

            Button("Copy HTML", systemImage: "chevron.left.forwardslash.chevron.right") {
                _ = copyHTML()
            }
            .help("Copy HTML to clipboard")
        }
        .padding()
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    private func editor() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Markdown Editor")
                    .font(.headline)
                Spacer()
                Text("\(markdownText.count) characters")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            Divider()

            ScrollDetectingTextEditor(
                text: $markdownText,
                onScroll: { scrollPosition in
                    if !isUpdatingScroll {
                        isUpdatingScroll = true
                        editorScrollPosition = scrollPosition
                        // Convert editor scroll to preview scroll (normalized 0-1)
                        previewScrollPosition = scrollPosition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            isUpdatingScroll = false
                        }
                    }
                },
                scrollPosition: $editorScrollPosition,
                isUpdating: $isUpdatingScroll
            )
            .frame(minHeight: 400)
        }
    }

    @ViewBuilder
    private func preview() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Preview")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            SynchronizedScrollView(
                scrollPosition: $previewScrollPosition,
                isUpdating: $isUpdatingScroll,
                onScroll: { scrollPosition in
                    if !isUpdatingScroll {
                        isUpdatingScroll = true
                        previewScrollPosition = scrollPosition
                        // Convert preview scroll to editor scroll (normalized 0-1)
                        editorScrollPosition = scrollPosition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            isUpdatingScroll = false
                        }
                    }
                }
            ) {
                VStack(alignment: .leading, spacing: 0) {
                    if markdownText.isEmpty {
                        Text("Start typing in the editor to see the preview...")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        Markdown(markdownText)
                            .markdownTheme(.gitHub)
                            .textSelection(.enabled)
                            .markdownBlockStyle(\.codeBlock) { configuration in
                                configuration.label
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .allowsHitTesting(false) // Disable hit testing to prevent scroll capture
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding()
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    // MARK: - Private Methods
    
    private func copyHTML() -> String {
        // For now, copy the markdown text as-is since MarkdownUI doesn't provide HTML export
        // In a real implementation, you might want to use a different markdown parser
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
        let html = htmlHeader + markdownText.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;") + htmlFooter
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(html, forType: .string)
        return html
    }
}

// MARK: - Synchronized Scrolling Components

/// A text editor that detects and reports scroll position changes
struct ScrollDetectingTextEditor: NSViewRepresentable {
    @Binding var text: String
    let onScroll: (CGFloat) -> Void
    @Binding var scrollPosition: CGFloat
    @Binding var isUpdating: Bool
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        scrollView.scrollerStyle = .overlay

        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false
        textView.textColor = NSColor.textColor
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.string = text
        textView.delegate = context.coordinator
        textView.drawsBackground = true
        textView.autoresizingMask = [.width, .height]
        textView.translatesAutoresizingMaskIntoConstraints = true

        // Set up text container
        if let textContainer = textView.textContainer {
            textContainer.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
            textContainer.widthTracksTextView = true
        }

        scrollView.documentView = textView
        scrollView.contentView.postsBoundsChangedNotifications = true

        // Set up scroll observation
        NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: scrollView.contentView,
            queue: .main
        ) { _ in
            Task { @MainActor in
                context.coordinator.handleScroll(scrollView: scrollView)
            }
        }

        // Make the text view focusable and accept first responder
        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }

        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // Only update text if it has changed, the text view is not currently being edited,
        // and there's no marked text (IME input)
        if textView.string != text && !context.coordinator.isEditing && !textView.hasMarkedText() {
            let selectedRange = textView.selectedRange()
            textView.string = text
            // Restore cursor position if possible
            if selectedRange.location <= text.count {
                textView.setSelectedRange(selectedRange)
            }
        }
        
        // Update scroll position if needed
        if !isUpdating && abs(context.coordinator.currentScrollPosition - scrollPosition) > 0.01 {
            context.coordinator.setScrollPosition(scrollPosition, in: nsView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @MainActor
    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: ScrollDetectingTextEditor
        var currentScrollPosition: CGFloat = 0
        var isEditing: Bool = false
        
        init(_ parent: ScrollDetectingTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            isEditing = true
            parent.text = textView.string
            // Reset editing flag after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isEditing = false
            }
        }
        
        func handleScroll(scrollView: NSScrollView) {
            guard !parent.isUpdating else { return }
            
            let contentView = scrollView.contentView
            let documentView = scrollView.documentView
            
            guard let documentView = documentView else { return }
            
            let visibleRect = contentView.visibleRect
            let documentHeight = documentView.bounds.height
            let containerHeight = contentView.bounds.height
            
            // Calculate normalized scroll position (0.0 to 1.0)
            let maxScroll = max(0, documentHeight - containerHeight)
            let normalizedPosition = maxScroll > 0 ? visibleRect.origin.y / maxScroll : 0
            
            currentScrollPosition = normalizedPosition
            parent.onScroll(normalizedPosition)
        }
        
        func setScrollPosition(_ position: CGFloat, in scrollView: NSScrollView) {
            guard let documentView = scrollView.documentView else { return }
            
            let contentView = scrollView.contentView
            let documentHeight = documentView.bounds.height
            let containerHeight = contentView.bounds.height
            let maxScroll = max(0, documentHeight - containerHeight)
            
            let targetY = position * maxScroll
            let targetPoint = NSPoint(x: 0, y: targetY)
            
            // Use scrollToVisible to properly update scroll indicators
            documentView.scroll(targetPoint)
            scrollView.reflectScrolledClipView(contentView)
            currentScrollPosition = position
        }
    }
}

/// A scroll view that can detect scroll changes and programmatically set scroll position
struct SynchronizedScrollView<Content: View>: NSViewRepresentable {
    @Binding var scrollPosition: CGFloat
    @Binding var isUpdating: Bool
    let onScroll: (CGFloat) -> Void
    let content: Content
    
    init(
        scrollPosition: Binding<CGFloat>,
        isUpdating: Binding<Bool>,
        onScroll: @escaping (CGFloat) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self._scrollPosition = scrollPosition
        self._isUpdating = isUpdating
        self.onScroll = onScroll
        self.content = content()
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        scrollView.scrollerStyle = .overlay
        
        // Create hosting view for SwiftUI content
        let hostingView = NSHostingView(rootView: content)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.documentView = hostingView
        scrollView.contentView.postsBoundsChangedNotifications = true
        
        // Create a custom scroll view that captures all scroll events
        let customScrollView = ScrollCapturingScrollView()
        customScrollView.hasVerticalScroller = true
        customScrollView.hasHorizontalScroller = false
        customScrollView.autohidesScrollers = false
        customScrollView.scrollerStyle = .overlay
        customScrollView.documentView = hostingView
        customScrollView.contentView.postsBoundsChangedNotifications = true
        customScrollView.scrollHandler = { scrollView in
            context.coordinator.handleScroll(scrollView: scrollView)
        }
        
        // Set up scroll observation
        NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: customScrollView.contentView,
            queue: .main
        ) { _ in
            Task { @MainActor in
                context.coordinator.handleScroll(scrollView: customScrollView)
            }
        }
        
        return customScrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // Update content
        if let hostingView = nsView.documentView as? NSHostingView<Content> {
            hostingView.rootView = content
        }
        
        // Update scroll position if needed
        if !isUpdating && abs(context.coordinator.currentScrollPosition - scrollPosition) > 0.01 {
            context.coordinator.setScrollPosition(scrollPosition, in: nsView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @MainActor
    class Coordinator: NSObject {
        let parent: SynchronizedScrollView
        var currentScrollPosition: CGFloat = 0
        
        init(_ parent: SynchronizedScrollView) {
            self.parent = parent
        }
        
        func handleScroll(scrollView: NSScrollView) {
            guard !parent.isUpdating else { return }
            
            let contentView = scrollView.contentView
            let documentView = scrollView.documentView
            
            guard let documentView = documentView else { return }
            
            let visibleRect = contentView.visibleRect
            let documentHeight = documentView.bounds.height
            let containerHeight = contentView.bounds.height
            
            // Calculate normalized scroll position (0.0 to 1.0)
            let maxScroll = max(0, documentHeight - containerHeight)
            let normalizedPosition = maxScroll > 0 ? visibleRect.origin.y / maxScroll : 0
            
            currentScrollPosition = normalizedPosition
            parent.onScroll(normalizedPosition)
        }
        
        func setScrollPosition(_ position: CGFloat, in scrollView: NSScrollView) {
            guard let documentView = scrollView.documentView else { return }
            
            let contentView = scrollView.contentView
            let documentHeight = documentView.bounds.height
            let containerHeight = contentView.bounds.height
            let maxScroll = max(0, documentHeight - containerHeight)
            
            let targetY = position * maxScroll
            let targetPoint = NSPoint(x: 0, y: targetY)
            
            // Use scrollToVisible to properly update scroll indicators
            documentView.scroll(targetPoint)
            scrollView.reflectScrolledClipView(contentView)
            currentScrollPosition = position
        }
    }
}

// Custom NSScrollView that captures all scroll events
class ScrollCapturingScrollView: NSScrollView {
    var scrollHandler: ((NSScrollView) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureScrollView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureScrollView()
    }
    
    private func configureScrollView() {
        hasVerticalScroller = true
        hasHorizontalScroller = false
        autohidesScrollers = false
        scrollerStyle = .overlay
    }
    
    override func scrollWheel(with event: NSEvent) {
        // Always handle scroll events at this level, regardless of what's underneath
        super.scrollWheel(with: event)
        
        // Manually trigger scroll handling
        if let scrollHandler = scrollHandler {
            Task { @MainActor in
                scrollHandler(self)
            }
        }
    }
}
