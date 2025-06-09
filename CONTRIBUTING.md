# Contributing to DevTools

Welcome to DevTools! We've made it incredibly easy to contribute new tools to help fellow developers. This guide will get you up and running in minutes.

## 🚀 Quick Start: Adding a New Tool

### Prerequisites
- macOS 14.0+
- Xcode 15.0+
- Basic Swift/SwiftUI knowledge

### 5-Minute Tool Creation

1. **Copy the Template**
   ```bash
   cp Templates/NewToolTemplate.swift DevTools/Tools/YourToolName.swift
   ```

2. **Customize Your Tool**
   - Open `DevTools/Tools/YourToolName.swift`
   - Update the tool metadata (name, description, icon, etc.)
   - Implement your tool's functionality

3. **Register Your Tool**
   - Open `DevTools/Core/Models/DevTool.swift`
   - Add `YourToolName.self,` to the `toolProviders` array in `registerTools()`

4. **Test and Submit**
   ```bash
   # Build and test
   xcodebuild -project DevTools.xcodeproj -scheme DevTools build
   
   # Run the app
   open DevTools.app
   ```

That's it! Your tool will automatically appear in the sidebar and home page.

## 📝 Tool Template Structure

```swift
struct YourToolName: ToolProvider {
    // 1. Required: Tool metadata
    static let metadata = ToolMetadata(
        id: "your-tool-name",           // Unique ID (kebab-case)
        name: "Your Tool Name",         // Display name
        description: "What it does",    // Brief description
        icon: "star.fill",              // SF Symbol icon
        category: .utilities            // Tool category
    )
    
    // 2. Required: View creation
    static func createView() -> YourToolView {
        YourToolView()
    }
    
    // 3. Optional: Advanced features
    static var settings: ToolSettings {
        return ToolSettings(
            supportsHistory: true,
            supportsKeyboardShortcuts: true
        )
    }
}
```

## 🛠 Tool Categories

Choose the appropriate category for your tool:

- **`.dateTime`** - Date and time related tools
- **`.textProcessing`** - Text manipulation and processing
- **`.formatting`** - Code formatting and prettification
- **`.encoding`** - Encoding, decoding, and encryption
- **`.utilities`** - General developer utilities

## ✨ Best Practices

### Tool Design
- **Keep it simple** - Focus on one task
- **Make it fast** - Tools should be responsive
- **Include error handling** - Graceful error messages
- **Add copy functionality** - Easy to copy results
- **Use consistent UI** - Follow the established patterns

### Code Quality
- **Follow Swift conventions** - Use proper naming
- **Add comments** - Explain complex logic
- **Handle edge cases** - Empty input, invalid data
- **Test your tool** - Verify it works correctly

### UI Guidelines
- **Use the template layout** - Input → Action → Output
- **Include clear labels** - Input/Output sections
- **Provide feedback** - Loading states, errors
- **Add keyboard shortcuts** - ⌘+Return for main action

## 🔧 Advanced Features (Optional)

### Custom ViewModels
For complex state management:

```swift
static var viewModel: (any ObservableObject)? {
    return YourToolViewModel()
}
```

### Custom Services
For complex business logic:

```swift
static var services: [any ToolService] {
    return [YourToolService()]
}
```

### Tool Settings
Enable additional features:

```swift
static var settings: ToolSettings {
    return ToolSettings(
        supportsHistory: true,           // Save tool usage history
        supportsPreferences: false,      // Tool-specific preferences
        supportsKeyboardShortcuts: true, // Custom keyboard shortcuts
        supportsDropFiles: false         // File drag & drop support
    )
}
```

## 📋 Example Tools

### Simple Tool: Text Reverser
```swift
struct TextReverserTool: ToolProvider {
    static let metadata = ToolMetadata(
        id: "text-reverser",
        name: "Text Reverser",
        description: "Reverse any text input",
        icon: "arrow.left.arrow.right",
        category: .textProcessing
    )
    
    static func createView() -> TextReverserView {
        TextReverserView()
    }
}
```

### Advanced Tool: JSON Formatter
```swift
struct JSONFormatterTool: ToolProvider {
    static let metadata = ToolMetadata(
        id: "json-formatter",
        name: "JSON Formatter",
        description: "Format and validate JSON data",
        icon: "curlybraces",
        category: .formatting
    )
    
    static func createView() -> JSONFormatterView {
        JSONFormatterView(viewModel: JSONFormatterViewModel())
    }
    
    static var viewModel: (any ObservableObject)? {
        return JSONFormatterViewModel()
    }
    
    static var settings: ToolSettings {
        return ToolSettings(
            supportsHistory: true,
            supportsDropFiles: true
        )
    }
}
```

## 🧪 Testing (Optional but Recommended)

Create tests for your tool:

```swift
// YourToolNameTests.swift
class YourToolNameTests: XCTestCase {
    func testBasicFunctionality() {
        // Test your tool's core logic
        let result = YourToolService().processData("test input")
        XCTAssertEqual(result, "expected output")
    }
}
```

## 🐛 Validation

The framework includes automatic validation:

- **Unique tool IDs** - Prevents conflicts
- **Required metadata** - Ensures completeness
- **Icon validation** - Checks SF Symbol existence
- **Build-time checks** - Catches errors early

## 🎯 Common Tool Ideas

Need inspiration? Here are some tool ideas:

### Text Processing
- Base64 Encoder/Decoder ✅ (example included)
- URL Encoder/Decoder
- HTML Entity Encoder
- Markdown to HTML Converter
- Text Case Converter
- Lorem Ipsum Generator

### Development
- UUID Generator
- Password Generator
- QR Code Generator
- Color Picker/Converter
- Regular Expression Tester
- API Response Formatter

### Utilities
- File Hash Calculator
- Image Metadata Viewer
- JSON Path Extractor
- SQL Formatter
- CSV to JSON Converter
- Timestamp Converter

## 📞 Getting Help

- **Check existing tools** - See how similar tools are implemented
- **Read the template** - Comprehensive comments and examples
- **Ask questions** - Open an issue for help
- **Join discussions** - Share ideas and get feedback

## 🚀 Submitting Your Tool

1. **Test thoroughly** - Make sure it works correctly
2. **Follow the conventions** - Use consistent naming and structure  
3. **Add documentation** - Update this file if needed
4. **Create a PR** - Include a clear description of your tool
5. **Be responsive** - Address feedback promptly

## 🏆 Recognition

Contributors will be recognized in:
- Tool author metadata
- Release notes
- Contributors list
- Project README

Thank you for contributing to DevTools! Your tools help developers worldwide be more productive. 🎉 