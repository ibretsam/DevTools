# Technical Context - DevTools

## Technology Stack

### Core Framework
- **SwiftUI**: Latest version (iOS 17+/macOS 14+) for native UI
- **Swift 5.9+**: Modern Swift with latest language features
- **Xcode 15+**: Latest development environment

### Architecture Components
- **Combine**: Reactive programming for data flow
- **Core Data**: Local data persistence for history/settings
- **Foundation**: System integration (clipboard, file system)
- **UniformTypeIdentifiers**: File type handling for drag & drop

### Navigation
- **NavigationStack**: Modern SwiftUI navigation (iOS 16+/macOS 13+)
- **NavigationSplitView**: Sidebar navigation pattern
- **Router Pattern**: Centralized navigation management

### Testing Framework
- **XCTest**: Native testing framework
- **SwiftUI Testing**: UI component testing
- **SnapshotTesting**: UI consistency verification
- **XCTest Performance**: Performance testing capabilities

## Development Setup

### Project Structure
```
DevTools/
├── App/
│   ├── DevToolsApp.swift
│   └── ContentView.swift
├── Core/
│   ├── Navigation/
│   ├── Services/
│   └── Models/
├── Tools/
│   ├── DateConverter/
│   ├── JSONFormatter/
│   └── MarkdownPreview/
├── Shared/
│   ├── Components/
│   └── Extensions/
└── Resources/
    └── Assets.xcassets
```

### Dependencies
- **No external dependencies initially** - Pure Swift/SwiftUI approach
- **Consider future additions**: 
  - SwiftFormat (code formatting)
  - SwiftLint (code quality)

### Build Configuration
- **Minimum Deployment Target**: macOS 14.0
- **Swift Language Version**: 5.9
- **Build Settings**: Optimize for speed and size

## Development Environment

### Xcode Configuration
- **SwiftUI Previews**: Enabled for rapid development
- **Live Preview**: Real-time UI updates
- **Simulator**: macOS simulator for testing
- **Device Testing**: Real macOS device testing

### Version Control
- **Git**: Source control management
- **Branch Strategy**: Feature branches for each tool
- **Commit Standards**: Conventional commits for clarity

## Performance Considerations

### Memory Management
- **ARC**: Automatic reference counting
- **Weak References**: Prevent retain cycles
- **Lazy Loading**: Load tools on demand

### UI Performance
- **SwiftUI Optimizations**: Proper state management
- **Background Processing**: Heavy operations off main thread
- **Caching**: Cache formatted results where appropriate

## Platform Integration

### macOS Features
- **Drag & Drop**: File and text handling
- **Clipboard**: System pasteboard integration
- **Keyboard Shortcuts**: Native shortcut support
- **Menu Bar**: Standard macOS menu integration
- **Window Management**: Native window controls

### Security & Privacy
- **Sandboxing**: App sandbox compliance
- **Privacy**: No network requests for core functionality
- **Local Processing**: All operations performed locally 