# System Patterns - DevTools

## Architecture Overview
**Clean Architecture with MVVM + Router Pattern**
- Separation of concerns with clear boundaries
- Testable business logic independent of UI
- Centralized navigation management
- Modular tool architecture for extensibility

## Core Components

### Navigation System
- **Router Pattern**: Centralized navigation using modern SwiftUI NavigationStack
- **Route Enum**: Type-safe navigation destinations
- **Dual Navigation**: Sidebar + Home page grid access
- **Deep Linking**: Support for URL-based tool access

### Tool Architecture
```
Tool Protocol
├── Tool Implementation (Business Logic)
├── Tool View (SwiftUI UI)
├── Tool ViewModel (State Management)
└── Tool Store (Persistence)
```

### Data Flow Pattern
```
View → ViewModel → Service → Store
     ←           ←         ←
```

## Key Patterns

### 1. Tool Protocol
```swift
protocol DevTool {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    var description: String { get }
    var category: ToolCategory { get }
}
```

### 2. Centralized Router
Based on modern SwiftUI patterns, using NavigationStack with programmatic navigation:
- Type-safe route definitions
- Observable navigation state
- Back stack management
- Environment injection

### 3. Persistence Strategy
- **UserDefaults**: App settings and preferences
- **Core Data**: History and recent items
- **FileManager**: Temporary tool data if needed
- **Keychain**: Sensitive data (future consideration)

### 4. Service Layer
- **ClipboardService**: System clipboard integration
- **FileService**: Drag & drop handling
- **PersistenceService**: Data storage abstraction
- **ToolService**: Tool management and registration

## Testing Architecture
- **Unit Tests**: ViewModels and Services
- **Integration Tests**: Tool workflows
- **UI Tests**: Critical user paths
- **Snapshot Tests**: UI component consistency
- **Performance Tests**: Large data handling

## macOS Integration Patterns
- **Drag & Drop**: NSItemProvider and Transferable protocol
- **Clipboard**: NSPasteboard integration
- **Menu Bar**: Native menu integration
- **Keyboard Shortcuts**: Command handling
- **Window Management**: Multi-window support (future) 