# System Patterns - DevTools

## Architecture Overview
**Clean Architecture with MVVM + Router Pattern + Simplified Tool Framework**
- Separation of concerns with clear boundaries
- Testable business logic independent of UI
- Centralized navigation management
- **NEW**: Plugin-based tool architecture for maximum contributor ease

## Core Components

### Navigation System
- **Router Pattern**: Centralized navigation using modern SwiftUI NavigationStack
- **Auto-Generated Routes**: Routes automatically created from tool metadata
- **Dual Navigation**: Sidebar + Home page grid access
- **Deep Linking**: Support for URL-based tool access

### NEW: Simplified Tool Architecture
**"One File, One Tool, One Registration" Philosophy**

```
ToolProvider Protocol
├── ToolMetadata (Identity & Configuration)
├── ContentView (SwiftUI UI)
├── Optional: ViewModel (State Management)
├── Optional: Services (Business Logic)
└── Optional: TestSuite (Testing)
```

### Data Flow Pattern
```
View → ViewModel → Service → Store
     ←           ←         ←
```

## Key Patterns

### 1. NEW: ToolProvider Protocol (Simplified)
```swift
protocol ToolProvider {
    // Required - Tool identity
    static var metadata: ToolMetadata { get }
    
    // Required - Main view
    associatedtype ContentView: View
    static func createView() -> ContentView
    
    // Optional - Default implementations provided
    static var viewModel: (any ObservableObject)? { get }
    static var services: [any ToolService] { get }
    static var testSuite: ToolTestSuite? { get }
}
```

### 2. NEW: Centralized Tool Metadata
```swift
struct ToolMetadata {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: ToolCategory
    let route: Route // Auto-generated from id
    let version: String = "1.0"
    let author: String = "Community"
}
```

### 3. NEW: Single-File Tool Template
```swift
struct MyNewTool: ToolProvider {
    static let metadata = ToolMetadata(
        id: "my-new-tool",
        name: "My New Tool", 
        description: "What this tool does",
        icon: "star.fill",
        category: .utilities
    )
    
    static func createView() -> MyNewToolView {
        MyNewToolView()
    }
}

struct MyNewToolView: View {
    var body: some View {
        // Tool implementation here
    }
}
```

### 4. Simplified Registration System
```swift
struct ToolRegistry {
    static func registerTools() {
        register([
            DateConverterTool.self,
            JSONFormatterTool.self,
            MyNewTool.self,  // ← Only line contributors add!
        ])
    }
}
```

### 5. Centralized Router (Enhanced)
- **Auto-route generation** from tool metadata
- **Type-safe navigation** maintained
- **No manual switch statements** to update
- **Lazy loading** of tool views

## NEW: Contributor Workflow

### Step 1: Copy Template (30 seconds)
```bash
cp Templates/NewToolTemplate.swift Tools/MyNewTool.swift
```

### Step 2: Customize Tool (5-30 minutes)
- Update metadata
- Implement tool functionality

### Step 3: Register Tool (10 seconds)
```swift
// Add ONE line to ToolRegistry.swift:
MyNewTool.self,
```

### Step 4: Test & Submit ✅

## Persistence Strategy
- **UserDefaults**: App settings and preferences
- **Core Data**: History and recent items
- **FileManager**: Temporary tool data if needed
- **Keychain**: Sensitive data (future consideration)

## Service Layer
- **ClipboardService**: System clipboard integration
- **FileService**: Drag & drop handling
- **PersistenceService**: Data storage abstraction
- **ToolService**: Tool management and registration
- **NEW**: **ToolValidationService**: Compile-time tool validation

## Testing Architecture
- **Unit Tests**: ViewModels and Services
- **Integration Tests**: Tool workflows
- **UI Tests**: Critical user paths
- **NEW**: **Optional Tool Tests**: Easy-to-add test templates
- **NEW**: **Tool Validation**: Automated validation system

## macOS Integration Patterns
- **Drag & Drop**: NSItemProvider and Transferable protocol
- **Clipboard**: NSPasteboard integration
- **Menu Bar**: Native menu integration
- **Keyboard Shortcuts**: Command handling
- **Window Management**: Multi-window support (future)

## NEW: Developer Experience Tools
- **Template Files**: Copy-and-modify tool templates
- **Validation Scripts**: Pre-commit tool validation
- **Documentation Generator**: Auto-generated tool docs
- **Testing Utilities**: Optional but easy testing framework 