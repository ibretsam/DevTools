//
//  DateConverterViewModel.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import Foundation
import SwiftUI
import Combine
import CoreData

/// ViewModel for the Date Converter tool
/// Manages state and business logic following MVVM pattern
@MainActor
final class DateConverterViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var inputText: String = ""
    
    // Real-time converter fields
    @Published var iso8601Field: String = "" {
        didSet { if iso8601Field != oldValue { updateFromISO8601() } }
    }
    @Published var timestampField: String = "" {
        didSet { if timestampField != oldValue { updateFromTimestamp() } }
    }
    @Published var readableField: String = "" {
        didSet { if readableField != oldValue { updateFromReadable() } }
    }
    @Published var relativeField: String = ""
    @Published var customField: String = ""
    @Published var timezoneField: String = ""
    
    // Manual date/time picker components
    @Published var manualYear: Int = Calendar.current.component(.year, from: Date()) {
        didSet { if manualYear != oldValue { updateFromManualComponents() } }
    }
    @Published var manualMonth: Int = Calendar.current.component(.month, from: Date()) {
        didSet { if manualMonth != oldValue { updateFromManualComponents() } }
    }
    @Published var manualDay: Int = Calendar.current.component(.day, from: Date()) {
        didSet { if manualDay != oldValue { updateFromManualComponents() } }
    }
    @Published var manualHour: Int = Calendar.current.component(.hour, from: Date()) {
        didSet { if manualHour != oldValue { updateFromManualComponents() } }
    }
    @Published var manualMinute: Int = Calendar.current.component(.minute, from: Date()) {
        didSet { if manualMinute != oldValue { updateFromManualComponents() } }
    }
    @Published var manualSecond: Int = Calendar.current.component(.second, from: Date()) {
        didSet { if manualSecond != oldValue { updateFromManualComponents() } }
    }
    
    // Internal state to prevent infinite loops during updates
    private var isUpdating = false
    
    @Published var selectedConversionType: DateConversionType = .timestamp
    @Published var customFormat: String = "yyyy-MM-dd HH:mm:ss" {
        didSet { if customFormat != oldValue { updateCustomField() } }
    }
    @Published var selectedTimezone: TimeZone = TimeZone.current
    @Published var conversionResult: DateConversionResult?
    @Published var showFormatPresets: Bool = false
    @Published var isHistoryVisible: Bool = true
    @Published var historyItems: [ConversionHistoryItem] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var recentConversions: [ConversionHistoryItem] = []
    
    // MARK: - Private Properties
    
    private let conversionService = DateConversionService.shared
    private let clipboardService = ClipboardService.shared
    private let persistenceService = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var availableTimezones: [TimeZone] {
        conversionService.getAvailableTimezones()
    }
    
    /// Format timezone identifier for display
    func formattedTimezoneDisplay(for timezone: TimeZone) -> String {
        let identifier = timezone.identifier
        _ = timezone.abbreviation() ?? ""
        let offsetSeconds = timezone.secondsFromGMT()
        let offsetHours = offsetSeconds / 3600
        let offsetMinutes = abs(offsetSeconds % 3600) / 60
        
        let offsetString: String
        if offsetSeconds == 0 {
            offsetString = "UTC+0"
        } else {
            let sign = offsetSeconds >= 0 ? "+" : "-"
            if offsetMinutes == 0 {
                offsetString = "UTC\(sign)\(abs(offsetHours))"
            } else {
                offsetString = "UTC\(sign)\(abs(offsetHours)):\(String(format: "%02d", offsetMinutes))"
            }
        }
        
        // Clean up identifier for display
        let displayName = identifier
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: "/")
            .last?
            .description ?? identifier
        
        return "\(displayName) (\(offsetString))"
    }
    
    var formatPresets: [DateFormatPreset] {
        DateFormatPreset.allCases
    }
    
    var hasResult: Bool {
        conversionResult?.success == true
    }
    
    var hasError: Bool {
        conversionResult?.success == false
    }
    
    var errorMessage: String {
        conversionResult?.error ?? ""
    }
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
        loadRecentConversions()
        setupCurrentDateInput()
        loadHistoryFromCoreData()
    }
    
    // MARK: - Setup Methods
    
    private func setupBindings() {
        // Auto-convert when input or settings change
        Publishers.CombineLatest4(
            $inputText.debounce(for: .milliseconds(300), scheduler: RunLoop.main),
            $selectedConversionType,
            $customFormat,
            $selectedTimezone
        )
        .sink { [weak self] _, _, _, _ in
            self?.performConversion()
        }
        .store(in: &cancellables)
    }
    
    private func setupCurrentDateInput() {
        // Set current date as initial input
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        inputText = formatter.string(from: now)
    }
    
    // MARK: - Public Methods
    
    /// Perform the date conversion based on current settings
    func performConversion() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            conversionResult = nil
            return
        }
        
        isLoading = true
        showError = false
        
        // Perform conversion on background queue to avoid blocking UI
        Task {
            let result = await performConversionAsync()
            
            await MainActor.run {
                self.conversionResult = result
                self.isLoading = false
                
                if result.success {
                    self.saveToHistory(result)
                    self.saveHistoryToCoreData(ConversionHistoryItem(
                        inputText: self.inputText,
                        outputText: result.result,
                        conversionType: self.selectedConversionType,
                        customFormat: self.customFormat.isEmpty ? nil : self.customFormat,
                        timezone: self.selectedConversionType == .timezone ? self.selectedTimezone : nil,
                        timestamp: Date()
                    ))
                } else {
                    self.showError = true
                }
            }
        }
    }
    
    /// Paste from clipboard to input
    func pasteFromClipboard() {
        if let clipboardText = clipboardService.getString() {
            inputText = clipboardText
        }
    }
    
    /// Copy result to clipboard
    func copyResultToClipboard() {
        guard let result = conversionResult, result.success else { return }
        clipboardService.copy(result.result)
    }
    
    /// Clear all input and results
    func clearAll() {
        inputText = ""
        conversionResult = nil
        showError = false
    }
    
    /// Set current date and time as input
    func setCurrentDateTime() {
        let now = Date()
        updateAllFieldsFromDate(now)
        
        // Also update the legacy inputText for compatibility
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        inputText = formatter.string(from: now)
        
        // Save to history when "Now" button is pressed
        saveFieldChangeToHistory(inputField: "Now Button", inputValue: "Current date and time", date: now)
    }
    
    /// Set current epoch timestamp as input
    func setCurrentEpochTime() {
        let epochTime = Int(Date().timeIntervalSince1970)
        inputText = String(epochTime)
    }
    
    /// Apply a date format preset
    func applyFormatPreset(_ preset: DateFormatPreset) {
        customFormat = preset.rawValue
        updateCustomField() // Update the custom field with the new format
        showFormatPresets = false // Close the format presets sheet
    }
    
    /// Load a recent conversion
    func loadRecentConversion(_ item: ConversionHistoryItem) {
        inputText = item.inputText
        selectedConversionType = item.conversionType
        if let format = item.customFormat {
            customFormat = format
        }
        if let timezone = item.timezone {
            selectedTimezone = timezone
        }
    }
    
    /// Clear conversion history
    func clearHistory() {
        historyItems.removeAll()
        clearHistoryFromCoreData()
    }
    
    /// Toggle history visibility
    func toggleHistory() {
        isHistoryVisible.toggle()
    }
    
    // MARK: - Private Methods
    
    private func performConversionAsync() async -> DateConversionResult {
        return await withCheckedContinuation { continuation in
            let result = conversionService.convert(
                input: inputText,
                type: selectedConversionType,
                customFormat: selectedConversionType == .custom ? customFormat : nil,
                timezone: selectedConversionType == .timezone ? selectedTimezone : nil
            )
            continuation.resume(returning: result)
        }
    }
    
    private func saveToHistory(_ result: DateConversionResult) {
        let historyItem = ConversionHistoryItem(
            inputText: inputText,
            outputText: result.result,
            conversionType: selectedConversionType,
            customFormat: selectedConversionType == .custom ? customFormat : nil,
            timezone: selectedConversionType == .timezone ? selectedTimezone : nil,
            timestamp: Date()
        )
        
        // Add to recent conversions (limit to 10 most recent)
        recentConversions.insert(historyItem, at: 0)
        if recentConversions.count > 10 {
            recentConversions.removeLast()
        }
        
        // Save to Core Data - this is now handled by saveFieldChangeToHistory for real-time updates
        saveHistoryToCoreData(historyItem)
    }
    
    private func loadRecentConversions() {
        // Load from Core Data - this is now handled by loadHistoryFromCoreData on app start
        recentConversions = []
    }
    
    // MARK: - Core Data Integration
    
    private func loadHistoryFromCoreData() {
        let request: NSFetchRequest<HistoryItem> = HistoryItem.fetchRequest()
        request.predicate = NSPredicate(format: "toolID == %@", "DateConverter")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HistoryItem.createdAt, ascending: false)]
        request.fetchLimit = 50
        
        do {
            let coreDataItems = try persistenceService.context.fetch(request)
            historyItems = coreDataItems.compactMap { item in
                guard let inputData = item.inputData,
                      let outputData = item.outputData,
                      let createdAt = item.createdAt,
                      let settings = item.toolSettings as? [String: Any],
                      let typeRawValue = settings["conversionType"] as? String,
                      let conversionType = DateConversionType(rawValue: typeRawValue) else {
                    return nil
                }
                
                let customFormat = settings["customFormat"] as? String
                let timezoneIdentifier = settings["timezoneIdentifier"] as? String
                let timezone = timezoneIdentifier != nil ? TimeZone(identifier: timezoneIdentifier!) : nil
                
                return ConversionHistoryItem(
                    inputText: inputData,
                    outputText: outputData,
                    conversionType: conversionType,
                    customFormat: customFormat,
                    timezone: timezone,
                    timestamp: createdAt
                )
            }
        } catch {
            print("Failed to load history from Core Data: \(error)")
        }
    }
    
    private func saveHistoryToCoreData(_ item: ConversionHistoryItem) {
        let historyItem = HistoryItem(context: persistenceService.context)
        historyItem.id = UUID()
        historyItem.toolID = "DateConverter"
        historyItem.inputData = item.inputText
        historyItem.outputData = item.outputText
        historyItem.createdAt = item.timestamp
        
        var settings: [String: Any] = [
            "conversionType": item.conversionType.rawValue
        ]
        
        if let customFormat = item.customFormat {
            settings["customFormat"] = customFormat
        }
        
        if let timezone = item.timezone {
            settings["timezoneIdentifier"] = timezone.identifier
        }
        
        historyItem.toolSettings = settings
        
        do {
            try persistenceService.save()
        } catch {
            print("Failed to save history to Core Data: \(error)")
        }
    }
    
    private func clearHistoryFromCoreData() {
        let request: NSFetchRequest<NSFetchRequestResult> = HistoryItem.fetchRequest()
        request.predicate = NSPredicate(format: "toolID == %@", "DateConverter")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try persistenceService.context.execute(deleteRequest)
            try persistenceService.save()
        } catch {
            print("Failed to clear history from Core Data: \(error)")
        }
    }
    
    /// Save field change to history when user edits a real-time field
    private func saveFieldChangeToHistory(inputField: String, inputValue: String, date: Date) {
        // Create a comprehensive output showing all current field values
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        let readableOutput = formatter.string(from: date)
        
        let historyItem = ConversionHistoryItem(
            inputText: "\(inputField): \(inputValue)",
            outputText: readableOutput,
            conversionType: .timestamp, // Use timestamp as default type for real-time conversions
            customFormat: nil,
            timezone: nil,
            timestamp: Date()
        )
        
        // Add to in-memory history list
        historyItems.insert(historyItem, at: 0)
        
        // Limit to 50 most recent items
        if historyItems.count > 50 {
            historyItems.removeLast()
        }
        
        // Save to Core Data
        saveHistoryToCoreData(historyItem)
    }
    
    // MARK: - Real-time Field Updates
    
    func clearAllFields() {
        // Clear all real-time fields without triggering updates
        isUpdating = true
        iso8601Field = ""
        timestampField = ""
        readableField = ""
        relativeField = ""
        customField = ""
        timezoneField = ""
        isUpdating = false
    }
    
    private func updateFromISO8601() {
        guard !isUpdating, !iso8601Field.isEmpty else { return }
        if let date = parseDate(from: iso8601Field) {
            updateAllFieldsFromDate(date)
            saveFieldChangeToHistory(inputField: "ISO 8601", inputValue: iso8601Field, date: date)
        }
    }
    
    private func updateFromTimestamp() {
        guard !isUpdating, !timestampField.isEmpty else { return }
        if let date = parseDate(from: timestampField) {
            updateAllFieldsFromDate(date)
            saveFieldChangeToHistory(inputField: "Unix Timestamp", inputValue: timestampField, date: date)
        }
    }
    
    private func updateFromReadable() {
        guard !isUpdating, !readableField.isEmpty else { return }
        if let date = parseDate(from: readableField) {
            updateAllFieldsFromDate(date)
            saveFieldChangeToHistory(inputField: "Human Readable", inputValue: readableField, date: date)
        }
    }
    
    private func updateFromManualComponents() {
        guard !isUpdating else { return }
        
        // Create date from manual components
        var components = DateComponents()
        components.year = manualYear
        components.month = manualMonth
        components.day = manualDay
        components.hour = manualHour
        components.minute = manualMinute
        components.second = manualSecond
        
        if let date = Calendar.current.date(from: components) {
            updateAllFieldsFromDate(date)
            let manualInput = "\(manualYear)-\(String(format: "%02d", manualMonth))-\(String(format: "%02d", manualDay)) \(String(format: "%02d", manualHour)):\(String(format: "%02d", manualMinute)):\(String(format: "%02d", manualSecond))"
            saveFieldChangeToHistory(inputField: "Manual Date & Time", inputValue: manualInput, date: date)
        }
    }
    
    private func updateCustomField() {
        guard !isUpdating else { return }
        
        // Get current date from any populated field
        var currentDate: Date?
        if !iso8601Field.isEmpty {
            currentDate = parseDate(from: iso8601Field)
        } else if !timestampField.isEmpty {
            currentDate = parseDate(from: timestampField)
        } else if !readableField.isEmpty {
            currentDate = parseDate(from: readableField)
        }
        
        if let date = currentDate, !customFormat.isEmpty {
            let customFormatter = DateFormatter()
            customFormatter.dateFormat = customFormat
            customField = customFormatter.string(from: date)
            
            // Save to history when custom format is applied
            saveFieldChangeToHistory(inputField: "Custom Format (\(customFormat))", inputValue: customField, date: date)
        }
    }
    
    private func updateAllFieldsFromDate(_ date: Date?) {
        guard let date = date else { return }
        
        isUpdating = true
        
        // Update ISO 8601
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if iso8601Field.isEmpty || !iso8601Field.contains("T") {
            iso8601Field = iso8601Formatter.string(from: date)
        }
        
        // Update timestamp
        if timestampField.isEmpty || !timestampField.allSatisfy(\.isNumber) {
            timestampField = String(Int(date.timeIntervalSince1970))
        }
        
        // Update readable
        let readableFormatter = DateFormatter()
        readableFormatter.dateStyle = .full
        readableFormatter.timeStyle = .medium
        if readableField.isEmpty {
            readableField = readableFormatter.string(from: date)
        }
        
        // Update relative (always calculated, read-only)
        relativeField = formatRelativeTime(from: date)
        
        // Update custom format
        if !customFormat.isEmpty {
            let customFormatter = DateFormatter()
            customFormatter.dateFormat = customFormat
            customField = customFormatter.string(from: date)
        }
        
        // Update timezone
        let timezoneFormatter = DateFormatter()
        timezoneFormatter.dateStyle = .full
        timezoneFormatter.timeStyle = .medium
        timezoneFormatter.timeZone = selectedTimezone
        timezoneField = timezoneFormatter.string(from: date)
        
        // Update manual components
        let calendar = Calendar.current
        manualYear = calendar.component(.year, from: date)
        manualMonth = calendar.component(.month, from: date)
        manualDay = calendar.component(.day, from: date)
        manualHour = calendar.component(.hour, from: date)
        manualMinute = calendar.component(.minute, from: date)
        manualSecond = calendar.component(.second, from: date)
        
        isUpdating = false
    }
    
    private func parseDate(from input: String) -> Date? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try parsing as epoch timestamp
        if let epochTime = Double(trimmed) {
            return Date(timeIntervalSince1970: epochTime)
        }
        
        // Try various date formatters
        let formatters = createDateFormatters()
        
        for formatter in formatters {
            if let date = formatter.date(from: trimmed) {
                return date
            }
        }
        
        return nil
    }
    
    private func createDateFormatters() -> [DateFormatter] {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd HH:mm:ss",
            "MM/dd/yyyy HH:mm:ss",
            "MM/dd/yyyy",
            "yyyy-MM-dd",
            "dd/MM/yyyy",
            "EEE, dd MMM yyyy HH:mm:ss zzz",
            "EEEE, MMMM d, yyyy",
            "MMM d, yyyy h:mm a",
            "MMM d, yyyy",
            "d MMM yyyy",
            "h:mm a",
            "HH:mm:ss",
            "HH:mm"
        ]
        
        return formats.map { format in
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
        }
    }
    
    private func formatRelativeTime(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if timeInterval < 2592000 {
            let days = Int(timeInterval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else {
            let months = Int(timeInterval / 2592000)
            return "\(months) month\(months == 1 ? "" : "s") ago"
        }
    }
}

// MARK: - History Item Model

/// Represents a conversion history item
struct ConversionHistoryItem: Identifiable {
    let id = UUID()
    let inputText: String
    let outputText: String
    let conversionType: DateConversionType
    let customFormat: String?
    let timezone: TimeZone?
    let timestamp: Date
    
    var displayTitle: String {
        return conversionType.displayName
    }
    
    var displaySubtitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
} 
