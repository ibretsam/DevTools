import SwiftUI
import UniformTypeIdentifiers

struct DateConverterView: View {
    @StateObject private var viewModel = DateConverterViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Real-time converter section
                realTimeConverterSection
            }
        }
        .frame(minWidth: 400)
        .padding()
        .navigationTitle("Date Converter")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.isHistoryVisible.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.right")
                }
                .help("Toggle History Sidebar")
            }
        }
        .inspector(isPresented: $viewModel.isHistoryVisible) {
            historySidebar
                .inspectorColumnWidth(min: 280, ideal: 320, max: 500)
        }
        .sheet(isPresented: $viewModel.showFormatPresets) {
            formatPresetsSheet
        }
        .onAppear {
            setupAccessibilityAnnouncements()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text("Convert dates between different formats and timezones")
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 28)
    }
    
    // MARK: - Real-Time Converter Section
    private var realTimeConverterSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Quick actions header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Date & Time Converter")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Edit any field to instantly update all other formats")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Button("Now") {
                        viewModel.setCurrentDateTime()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                    .help("Set to current date and time")
                    
                    Button("Paste") {
                        viewModel.pasteFromClipboard()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.08))
                    )
                    .help("Paste from clipboard")
                    
                    Button("Clear") {
                        viewModel.clearAllFields()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.08))
                    )
                    .help("Clear all fields")
                }
            }
            
            // Converter fields - single column layout
            VStack(spacing: 16) {
                // ISO 8601 field
                DateFieldCard(
                    title: "ISO 8601",
                    icon: "calendar.circle",
                    placeholder: "2025-06-09T14:30:00Z",
                    value: $viewModel.iso8601Field,
                    isEditable: true,
                    description: "International standard format"
                )
                
                // Unix Timestamp field
                DateFieldCard(
                    title: "Unix Timestamp",
                    icon: "clock.circle",
                    placeholder: "1717939800",
                    value: $viewModel.timestampField,
                    isEditable: true,
                    description: "Seconds since Unix epoch"
                )
                
                // Human Readable field (read-only)
                DateFieldCard(
                    title: "Human Readable",
                    icon: "person.crop.circle",
                    placeholder: "Sunday, June 9, 2025 at 2:30 PM",
                    value: $viewModel.readableField,
                    isEditable: false,
                    description: "Natural language format"
                )
                
                // Relative Time field (read-only)
                DateFieldCard(
                    title: "Relative Time",
                    icon: "timer.circle",
                    placeholder: "2 hours ago",
                    value: $viewModel.relativeField,
                    isEditable: false,
                    description: "Time relative to now"
                )
                
                // Custom Format field with timezone picker
                CustomFormatFieldCard(
                    customFormat: $viewModel.customFormat,
                    customValue: $viewModel.customField,
                    selectedTimezone: $viewModel.selectedTimezone,
                    availableTimezones: viewModel.availableTimezones,
                    showFormatPresets: $viewModel.showFormatPresets,
                    formattedTimezoneDisplay: viewModel.formattedTimezoneDisplay
                )
                
                // Timezone-specific field
                TimezoneFieldCard(
                    selectedTimezone: $viewModel.selectedTimezone,
                    timezoneValue: $viewModel.timezoneField,
                    availableTimezones: viewModel.availableTimezones,
                    formattedTimezoneDisplay: viewModel.formattedTimezoneDisplay
                )
                
                // Manual Date/Time Picker field
                DatePickerFieldCard(
                    year: $viewModel.manualYear,
                    month: $viewModel.manualMonth,
                    day: $viewModel.manualDay,
                    hour: $viewModel.manualHour,
                    minute: $viewModel.manualMinute,
                    second: $viewModel.manualSecond
                )
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Date Field Card Components
}

// MARK: - Field Card Components

struct DateFieldCard: View {
    let title: String
    let icon: String
    let placeholder: String
    @Binding var value: String
    let isEditable: Bool
    let description: String
    
    @State private var isHovered = false
    @State private var isFocused = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    // Icon with subtle background
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Copy button - always visible when there's content
                    if !value.isEmpty {
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(value, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .help("Copy to clipboard")
                        .opacity(isHovered ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                    }
                    
                    if !value.isEmpty && isEditable {
                        Button(action: { value = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                        .help("Clear")
                        .opacity(isHovered ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            
            // Content field
            VStack(spacing: 0) {
                if isEditable {
                    TextField(placeholder, text: $value, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 0)
                                .fill(isFocused ? Color.accentColor.opacity(0.02) : Color.clear)
                        )
                        .overlay(
                            Rectangle()
                                .fill(isFocused ? Color.accentColor.opacity(0.4) : Color.clear)
                                .frame(height: 2)
                                .animation(.easeInOut(duration: 0.2), value: isFocused),
                            alignment: .bottom
                        )
                        .onTapGesture {
                            isFocused = true
                        }
                } else {
                    Text(value.isEmpty ? placeholder : value)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(value.isEmpty ? .secondary.opacity(0.6) : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.02))
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(
                    color: isHovered ? Color.black.opacity(0.08) : Color.black.opacity(0.04),
                    radius: isHovered ? 8 : 4,
                    x: 0,
                    y: isHovered ? 4 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isHovered ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1),
                    lineWidth: 1
                )
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct CustomFormatFieldCard: View {
    @Binding var customFormat: String
    @Binding var customValue: String
    @Binding var selectedTimezone: TimeZone
    let availableTimezones: [TimeZone]
    @Binding var showFormatPresets: Bool
    let formattedTimezoneDisplay: (TimeZone) -> String
    
    @State private var isHovered = false
    @State private var isFocused = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    // Icon with subtle background
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "textformat")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Custom Format")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("User-defined date pattern")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Copy button for custom formatted value
                    if !customValue.isEmpty {
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(customValue, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .help("Copy formatted date to clipboard")
                        .opacity(isHovered ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                    }
                    
                    Button("Presets") {
                        showFormatPresets = true
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                    .help("Format presets")
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Format pattern input
                TextField("yyyy-MM-dd HH:mm:ss", text: $customFormat)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.secondary.opacity(0.04))
                    )
                    .overlay(
                        Rectangle()
                            .fill(isFocused ? Color.accentColor.opacity(0.4) : Color.secondary.opacity(0.1))
                            .frame(height: 1)
                            .animation(.easeInOut(duration: 0.2), value: isFocused),
                        alignment: .bottom
                    )
                    .onTapGesture {
                        isFocused = true
                    }
            }
            
            // Output section
            VStack(spacing: 0) {
                Text(customValue.isEmpty ? "Formatted date will appear here" : customValue)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(customValue.isEmpty ? .secondary.opacity(0.6) : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.02))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(
                    color: isHovered ? Color.black.opacity(0.08) : Color.black.opacity(0.04),
                    radius: isHovered ? 8 : 4,
                    x: 0,
                    y: isHovered ? 4 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isHovered ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1),
                    lineWidth: 1
                )
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct TimezoneFieldCard: View {
    @Binding var selectedTimezone: TimeZone
    @Binding var timezoneValue: String
    let availableTimezones: [TimeZone]
    let formattedTimezoneDisplay: (TimeZone) -> String
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    // Icon with subtle background
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "globe")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Timezone Converter")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Convert to specific timezone")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Copy button for timezone converted value
                    if !timezoneValue.isEmpty {
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(timezoneValue, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .help("Copy timezone converted date to clipboard")
                        .opacity(isHovered ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Timezone picker
                HStack {
                    Text("Timezone")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Picker("", selection: $selectedTimezone) {
                        ForEach(availableTimezones, id: \.identifier) { timezone in
                            Text(formattedTimezoneDisplay(timezone))
                                .tag(timezone)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .font(.system(size: 11))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.04))
            }
            
            // Output section
            VStack(spacing: 0) {
                Text(timezoneValue.isEmpty ? "Timezone converted date will appear here" : timezoneValue)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(timezoneValue.isEmpty ? .secondary.opacity(0.6) : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.02))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(
                    color: isHovered ? Color.black.opacity(0.08) : Color.black.opacity(0.04),
                    radius: isHovered ? 8 : 4,
                    x: 0,
                    y: isHovered ? 4 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isHovered ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1),
                    lineWidth: 1
                )
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

extension DateConverterView {
    // MARK: - History Sidebar
    private var historySidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("History")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear") {
                    viewModel.clearHistory()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Clear conversion history")
            }
            .padding()
            
            Divider()
            
            // History list
            if viewModel.historyItems.isEmpty {
                VStack {
                    Spacer()
                    Text("No recent conversions")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(viewModel.historyItems) { item in
                            HistoryItemView(item: item) {
                                viewModel.loadRecentConversion(item)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1),
            alignment: .leading
        )
    }
    
    // MARK: - Format Presets Sheet
    private var formatPresetsSheet: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Date Format Presets")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Cancel") {
                    viewModel.showFormatPresets = false
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.08))
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
            
            // Presets List
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(viewModel.formatPresets, id: \.rawValue) { preset in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(preset.displayName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            Text(preset.rawValue)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                            
                            Text(preset.example)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .background(Color.clear)
                        .onTapGesture {
                            viewModel.applyFormatPreset(preset)
                        }
                        .onHover { isHovered in
                            if isHovered {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
        .background(Color(NSColor.controlBackgroundColor))
        .frame(minWidth: 400, maxWidth: 600, minHeight: 300, maxHeight: 500)
    }
    
    // MARK: - Accessibility Support
    private func setupAccessibilityAnnouncements() {
        // Enable VoiceOver announcements for important changes
        // Note: This would be triggered by the ViewModel when conversion completes
        print("Accessibility announcements enabled for Date Converter")
    }
    
    // MARK: - Drag & Drop Handling
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, error in
            if let data = item as? Data,
               let text = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    viewModel.inputText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            } else if let text = item as? String {
                DispatchQueue.main.async {
                    viewModel.inputText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        return true
    }
}

// MARK: - Supporting Views

struct ConversionTypeCard: View {
    let type: DateConversionType
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .accentColor)
                    
                    Spacer()
                }
                
                Text(type.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(type.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Group {
                    if isSelected {
                        Color.accentColor
                    } else if isHovered {
                        Color.accentColor.opacity(0.1)
                    } else {
                        Color(NSColor.controlBackgroundColor)
                    }
                }
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.clear : 
                        isHovered ? Color.accentColor.opacity(0.3) : 
                        Color(NSColor.separatorColor), 
                        lineWidth: 1
                    )
            )
            .scaleEffect(isHovered && !isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .accessibilityLabel(type.displayName)
        .accessibilityHint(type.description)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

struct HistoryItemView: View {
    let item: ConversionHistoryItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.displayTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(item.displaySubtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(item.inputText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(item.outputText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .accessibilityLabel("History item: \(item.displayTitle)")
        .accessibilityHint("Tap to load this conversion into the input fields")
    }
}

struct DatePickerFieldCard: View {
    @Binding var year: Int
    @Binding var month: Int
    @Binding var day: Int
    @Binding var hour: Int
    @Binding var minute: Int
    @Binding var second: Int
    
    @State private var isHovered = false
    
    // Create a computed date property
    private var selectedDate: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.year = year
                components.month = month
                components.day = day
                components.hour = hour
                components.minute = minute
                components.second = second
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
                year = components.year ?? 2025
                month = components.month ?? 1
                day = components.day ?? 1
                hour = components.hour ?? 0
                minute = components.minute ?? 0
                second = components.second ?? 0
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16))
                
                Text("Manual Date & Time")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Copy button
                Button(action: copyToClipboard) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("Copy to clipboard")
                .opacity(isHovered ? 1.0 : 0.7)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Content with proper alignment
            VStack(spacing: 16) {
                // Date Row
                HStack(alignment: .center) {
                    Text("Date")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                        .frame(width: 100, alignment: .leading)
                    
                    DatePicker("", selection: selectedDate, displayedComponents: .date)
                        .datePickerStyle(.field)
                        .labelsHidden()

                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Time Row
                HStack(alignment: .center) {
                    Text("Time")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                        .frame(width: 100, alignment: .leading)
                    
                    // Unified time input that looks like one control
                    HStack(spacing: 0) {
                        // Hour field
                        TextField("", value: Binding(
                            get: { hour },
                            set: { newValue in
                                let validHour = max(0, min(23, newValue))
                                hour = validHour
                                updateDateFromComponents()
                            }
                        ), format: .number.precision(.integerLength(2)))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 13, design: .monospaced))
                        
                        Text(":")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 2)
                        
                        // Minute field
                        TextField("", value: Binding(
                            get: { minute },
                            set: { newValue in
                                let validMinute = max(0, min(59, newValue))
                                minute = validMinute
                                updateDateFromComponents()
                            }
                        ), format: .number.precision(.integerLength(2)))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 13, design: .monospaced))
                        
                        Text(":")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 2)
                        
                        // Second field
                        TextField("", value: Binding(
                            get: { second },
                            set: { newValue in
                                let validSecond = max(0, min(59, newValue))
                                second = validSecond
                                updateDateFromComponents()
                            }
                        ), format: .number.precision(.integerLength(2)))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 13, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private func updateDateFromComponents() {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        if let newDate = Calendar.current.date(from: components) {
            selectedDate.wrappedValue = newDate
        }
    }
    
    private func copyToClipboard() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        
        let dateString = formatter.string(from: selectedDate.wrappedValue)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(dateString, forType: .string)
    }
}

#Preview {
    DateConverterView()
} 
