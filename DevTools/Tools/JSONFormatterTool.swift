import SwiftUI

/// Tool for formatting JSON data in real time
struct JSONFormatterTool: ToolProvider {
    static let metadata = ToolMetadata(
        id: "json-formatter",
        name: "JSON Formatter",
        description: "Format and validate JSON data in real time",
        icon: "curlybraces.square",
        category: .formatting
    )

    @MainActor
    static func createView() -> JSONFormatterView {
        JSONFormatterView()
    }
}

struct JSONFormatterView: View {
    @State private var inputText: String = ""
    @State private var formattedText: String = ""

    var body: some View {
        HSplitView {
            inputEditor
            outputEditor
        }
        .onAppear { formatInput() }
        .navigationTitle(JSONFormatterTool.metadata.name)
    }

    private var inputEditor: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("JSON Input")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color(nsColor: .textBackgroundColor))
                .onChange(of: inputText) { _, _ in
                    formatInput()
                }
        }
    }

    private var outputEditor: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Formatted JSON")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            TextEditor(text: .constant(formattedText))
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color(nsColor: .textBackgroundColor))
                .disabled(true)
        }
    }

    private func formatInput() {
        formattedText = JSONFormatterTool.format(jsonString: inputText)
    }
}

extension JSONFormatterTool {
    /// Format a JSON string into pretty printed form
    /// - Parameter jsonString: raw JSON string
    /// - Returns: formatted JSON or error message
    static func format(jsonString: String) -> String {
        let data = Data(jsonString.utf8)
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            return String(decoding: prettyData, as: UTF8.self)
        } catch {
            return "Invalid JSON"
        }
    }
}

#Preview {
    NavigationStack {
        JSONFormatterView()
    }
}
