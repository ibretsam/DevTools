import SwiftUI
import MarkdownUI
import UniformTypeIdentifiers

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

    Happy markdown editing! 🚀
    """
    
    @State private var showPreviewOnly = false

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
                copyHTML()
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

            TextEditor(text: $markdownText)
                .fontDesign(.monospaced)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func preview() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Live Preview")
                    .font(.headline)
                Spacer()
                Text("Rendered")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
            .padding()

            Divider()

            ScrollView {
                Markdown(markdownText)
                    .markdownTheme(.gitHub)
                    .padding()
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    // MARK: - Private Methods
    
    private func copyHTML() {
        let html = MarkdownContent(markdownText).renderHTML()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(html, forType: .string)
    }
} 