//
//  DateConversionServiceTests.swift
//  DevToolsTests
//
//  Created by DevTools on 9/6/25.
//

import XCTest
@testable import DevTools

final class DateConversionServiceTests: XCTestCase {
    
    var service: DateConversionService!
    
    override func setUpWithError() throws {
        service = DateConversionService.shared
    }
    
    override func tearDownWithError() throws {
        service = nil
    }
    
    // MARK: - Timestamp Conversion Tests
    
    func testConvertToTimestamp() {
        // Given
        let input = "2023-09-06T15:30:00Z"
        
        // When
        let result = service.convert(input: input, type: .timestamp)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertFalse(result.result.isEmpty)
        XCTAssertNotNil(result.sourceDate)
        XCTAssertEqual(result.targetFormat, "Full date and time")
    }
    
    func testConvertToTimestampWithInvalidInput() {
        // Given
        let input = "invalid date"
        
        // When
        let result = service.convert(input: input, type: .timestamp)
        
        // Then
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, "Unable to parse date from input")
    }
    
    // MARK: - ISO 8601 Conversion Tests
    
    func testConvertToISO8601() {
        // Given
        let input = "Sep 6, 2023 3:30 PM"
        
        // When
        let result = service.convert(input: input, type: .iso8601)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.result.contains("2023"))
        XCTAssertTrue(result.result.contains("T"))
        XCTAssertEqual(result.targetFormat, "ISO 8601")
    }
    
    // MARK: - Epoch Time Conversion Tests
    
    func testConvertToEpoch() {
        // Given
        let input = "2023-09-06T15:30:00Z"
        
        // When
        let result = service.convert(input: input, type: .epoch)
        
        // Then
        XCTAssertTrue(result.success)
        let epochTime = Int(result.result)
        XCTAssertNotNil(epochTime)
        XCTAssertGreaterThan(epochTime!, 1693000000) // Should be around 2023
        XCTAssertEqual(result.targetFormat, "Unix epoch")
    }
    
    func testConvertFromEpochTime() {
        // Given
        let input = "1693488600" // Sep 6, 2023 3:30 PM UTC
        
        // When
        let result = service.convert(input: input, type: .timestamp)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertNotNil(result.sourceDate)
    }
    
    // MARK: - Custom Format Conversion Tests
    
    func testConvertToCustomFormat() {
        // Given
        let input = "2023-09-06T15:30:00Z"
        let customFormat = "yyyy-MM-dd HH:mm:ss"
        
        // When
        let result = service.convert(input: input, type: .custom, customFormat: customFormat)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.result.contains("2023-09-06"))
        XCTAssertEqual(result.targetFormat, customFormat)
    }
    
    func testConvertToCustomFormatWithoutFormat() {
        // Given
        let input = "2023-09-06T15:30:00Z"
        
        // When
        let result = service.convert(input: input, type: .custom)
        
        // Then
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, "Custom format is required")
    }
    
    // MARK: - Relative Time Conversion Tests
    
    func testConvertToRelativeTime() {
        // Given
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)
        let formatter = ISO8601DateFormatter()
        let input = formatter.string(from: oneHourAgo)
        
        // When
        let result = service.convert(input: input, type: .relative)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.result.contains("ago") || result.result.contains("hour"))
        XCTAssertEqual(result.targetFormat, "Relative time")
    }
    
    // MARK: - Timezone Conversion Tests
    
    func testConvertTimezone() {
        // Given
        let input = "2023-09-06T15:30:00Z"
        let targetTimezone = TimeZone(identifier: "America/New_York")!
        
        // When
        let result = service.convert(input: input, type: .timezone, timezone: targetTimezone)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertNotNil(result.sourceDate)
        XCTAssertEqual(result.targetFormat, "Timezone: America/New_York")
    }
    
    // MARK: - Edge Cases Tests
    
    func testConvertWithEmptyInput() {
        // Given
        let input = ""
        
        // When
        let result = service.convert(input: input, type: .timestamp)
        
        // Then
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, "Input cannot be empty")
    }
    
    func testConvertWithWhitespaceInput() {
        // Given
        let input = "   \n\t   "
        
        // When
        let result = service.convert(input: input, type: .timestamp)
        
        // Then
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, "Input cannot be empty")
    }
    
    // MARK: - Date Format Validation Tests
    
    func testValidateDateFormat() {
        // Given
        let validFormat = "yyyy-MM-dd HH:mm:ss"
        let invalidFormat = "invalid-format"
        
        // When & Then
        XCTAssertTrue(service.validateDateFormat(validFormat))
        XCTAssertFalse(service.validateDateFormat(invalidFormat))
    }
    
    // MARK: - Utility Methods Tests
    
    func testGetCurrentDate() {
        // Given
        let preset = DateFormatPreset.iso8601
        
        // When
        let result = service.getCurrentDate(format: preset)
        
        // Then
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("T"))
    }
    
    func testCalculateRelativeDate() {
        // Given
        let baseDate = Date()
        let value = 2
        let unit = RelativeTimeUnit.hours
        
        // When
        let result = service.calculateRelativeDate(from: baseDate, adding: value, unit: unit)
        
        // Then
        let expectedInterval = baseDate.timeIntervalSince1970 + unit.timeInterval(for: value)
        XCTAssertEqual(result.timeIntervalSince1970, expectedInterval, accuracy: 1.0)
    }
    
    func testGetAvailableTimezones() {
        // When
        let timezones = service.getAvailableTimezones()
        
        // Then
        XCTAssertFalse(timezones.isEmpty)
        XCTAssertTrue(timezones.contains { $0.identifier == "GMT" }) // UTC resolves to GMT
        XCTAssertTrue(timezones.contains { $0.identifier == "America/New_York" })
    }
    
    // MARK: - Multiple Format Parsing Tests
    
    func testParseDifferentDateFormats() {
        let testCases = [
            "2023-09-06T15:30:00Z",
            "2023-09-06 15:30:00",
            "09/06/2023 15:30:00",
            "09/06/2023",
            "2023-09-06",
            "Sep 6, 2023",
            "1693488600" // Epoch time
        ]
        
        for input in testCases {
            // When
            let result = service.convert(input: input, type: .timestamp)
            
            // Then
            XCTAssertTrue(result.success, "Failed to parse: \(input)")
            XCTAssertNotNil(result.sourceDate, "No source date for: \(input)")
        }
    }
} 