//
//  Base64EncoderTool.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import SwiftUI
import Foundation

/// Example tool demonstrating the simplified tool development framework
/// This tool encodes and decodes Base64 data
struct Base64EncoderTool: ToolProvider {
    
    // MARK: - Tool Configuration
    
    static let metadata = ToolMetadata(
        id: "base64-encoder",
        name: "Base64 Encoder",
        description: "Encode and decode Base64 data with ease",
        icon: "lock.rectangle",
        category: .encoding,
        version: "1.0",
        author: "DevTools Team"
    )
    
    // MARK: - View Creation
    
    static func createView() -> Base64EncoderView {
        Base64EncoderView()
    }
    
    // Enable history for this tool
    static var settings: ToolSettings {
        return ToolSettings(
            supportsHistory: true,
            supportsKeyboardShortcuts: true
        )
    }
}

// MARK: - Tool View Implementation

struct Base64EncoderView: View {
    
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isEncoding: Bool = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            headerSection
            
            // Mode selector
            modeSelector
            
            // Main content
            HStack(spacing: 20) {
                inputSection
                actionButtons
                outputSection
            }
            .padding()
            
            // Error message
            if let errorMessage = errorMessage {
                errorMessageView(errorMessage)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(Base64EncoderTool.metadata.name)
        .onAppear {
            // Clear any existing error when view appears
            errorMessage = nil
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: Base64EncoderTool.metadata.icon)
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text(Base64EncoderTool.metadata.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(Base64EncoderTool.metadata.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var modeSelector: some View {
        HStack {
            Text("Mode:")
                .font(.headline)
            
            Picker("Mode", selection: $isEncoding) {
                Text("Encode").tag(true)
                Text("Decode").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isEncoding ? "Text to Encode" : "Base64 to Decode")
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
                .onChange(of: inputText) { _, _ in
                    // Clear error when input changes
                    errorMessage = nil
                }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: processInput) {
                VStack(spacing: 4) {
                    Image(systemName: isEncoding ? "lock.fill" : "lock.open.fill")
                        .font(.system(size: 20))
                    Text(isEncoding ? "Encode" : "Decode")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            .keyboardShortcut(.return, modifiers: .command)
            
            Button(action: clearAll) {
                VStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                    Text("Clear")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
    }
    
    private var outputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isEncoding ? "Base64 Output" : "Decoded Text")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !outputText.isEmpty {
                    Button("Copy", action: copyOutput)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .keyboardShortcut("c", modifiers: [.command, .shift])
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
    
    private func errorMessageView(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Dismiss") {
                errorMessage = nil
            }
            .font(.caption)
            .foregroundColor(.accentColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func processInput() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to process"
            return
        }
        
        errorMessage = nil
        
        if isEncoding {
            encodeBase64()
        } else {
            decodeBase64()
        }
    }
    
    private func encodeBase64() {
        let data = inputText.data(using: .utf8) ?? Data()
        outputText = data.base64EncodedString()
    }
    
    private func decodeBase64() {
        guard let data = Data(base64Encoded: inputText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = "Invalid Base64 format. Please check your input."
            outputText = ""
            return
        }
        
        guard let decodedString = String(data: data, encoding: .utf8) else {
            errorMessage = "Decoded data is not valid UTF-8 text."
            outputText = ""
            return
        }
        
        outputText = decodedString
    }
    
    private func clearAll() {
        inputText = ""
        outputText = ""
        errorMessage = nil
    }
    
    private func copyOutput() {
        ClipboardService.shared.copy(outputText)
    }
}

#Preview {
    NavigationStack {
        Base64EncoderView()
    }
} 