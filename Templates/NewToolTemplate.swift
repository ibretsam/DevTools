//
//  NewToolTemplate.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import SwiftUI

/// Template for creating new tools in the simplified tool development framework
/// 
/// TO CREATE A NEW TOOL:
/// 1. Copy this file to DevTools/Tools/YourToolName.swift
/// 2. Rename "NewToolTemplate" to your tool name (e.g., "Base64EncoderTool")
/// 3. Update the metadata below with your tool's information
/// 4. Implement your tool's UI in the view
/// 5. Add YourToolName.self to ToolRegistry.registerTools()
/// 6. Build and test!
///
/// That's it! Your tool will automatically appear in the sidebar and home page.

struct NewToolTemplate: ToolProvider {
    
    // MARK: - Tool Configuration (REQUIRED)
    // Update this metadata with your tool's information
    
    static let metadata = ToolMetadata(
        id: "new-tool-template",              // Unique ID (kebab-case recommended)
        name: "New Tool Template",            // Display name
        description: "Template for creating new tools", // Brief description
        icon: "star.fill",                    // SF Symbol icon name
        category: .utilities,                 // Tool category
        version: "1.0",                       // Tool version (optional)
        author: "Community"                   // Author name (optional)
    )
    
    // MARK: - View Creation (REQUIRED)
    // This method creates your tool's main view
    
    static func createView() -> NewToolTemplateView {
        NewToolTemplateView()
    }
    
    // MARK: - Optional Advanced Features
    // Uncomment and implement these if your tool needs advanced features
    
    /*
    // Custom ViewModel for complex state management
    static var viewModel: (any ObservableObject)? {
        return NewToolTemplateViewModel()
    }
    
    // Custom services for business logic
    static var services: [any ToolService] {
        return [NewToolTemplateService()]
    }
    
    // Custom settings for tool behavior
    static var settings: ToolSettings {
        return ToolSettings(
            supportsHistory: true,
            supportsPreferences: false,
            supportsKeyboardShortcuts: true,
            supportsDropFiles: false
        )
    }
    */
}

// MARK: - Tool View Implementation

/// Main view for your tool
/// Implement your tool's user interface here
struct NewToolTemplateView: View {
    
    // Add @State or @StateObject properties for your tool's state
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Header section
            VStack(spacing: 8) {
                Image(systemName: NewToolTemplate.metadata.icon)
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text(NewToolTemplate.metadata.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(NewToolTemplate.metadata.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical)
            
            // Main tool interface
            HStack(spacing: 20) {
                
                // Input section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Input")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $inputText)
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .frame(minHeight: 200)
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: processInput) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 24))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    
                    Button(action: clearAll) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                
                // Output section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Output")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        if !outputText.isEmpty {
                            Button("Copy", action: copyOutput)
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    TextEditor(text: .constant(outputText))
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .frame(minHeight: 200)
                        .disabled(true)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle(NewToolTemplate.metadata.name)
    }
    
    // MARK: - Tool Actions
    // Implement your tool's functionality here
    
    private func processInput() {
        // TODO: Replace this with your tool's logic
        outputText = "Processed: \(inputText)"
        
        // Example transformations you might implement:
        // - Text encoding/decoding
        // - Data format conversions  
        // - Text manipulation
        // - Calculations
        // etc.
    }
    
    private func clearAll() {
        inputText = ""
        outputText = ""
    }
    
    private func copyOutput() {
        ClipboardService.shared.copy(outputText)
    }
}

// MARK: - Optional Advanced Components
// Uncomment and implement these if your tool needs advanced features

/*
/// Custom ViewModel for complex state management
class NewToolTemplateViewModel: ObservableObject {
    @Published var inputData: String = ""
    @Published var outputData: String = ""
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    
    func processData() {
        isProcessing = true
        errorMessage = nil
        
        // Implement your complex business logic here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.outputData = "Processed: \(self.inputData)"
            self.isProcessing = false
        }
    }
}

/// Custom service for business logic
class NewToolTemplateService: ToolService {
    let serviceId = "new-tool-template-service"
    
    func initialize() {
        // Set up any resources your tool needs
    }
    
    func cleanup() {
        // Clean up resources when tool is destroyed
    }
    
    func processData(_ input: String) -> String {
        // Implement your tool's core logic here
        return "Processed: \(input)"
    }
}
*/

// MARK: - Preview

#Preview {
    NavigationStack {
        NewToolTemplateView()
    }
} 