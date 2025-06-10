//
//  DateConversionType.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import Foundation

/// Types of date conversions supported by the Date Converter tool
enum DateConversionType: String, CaseIterable, Identifiable {
    case timestamp = "timestamp"
    case iso8601 = "iso8601"
    case relative = "relative"
    case custom = "custom"
    case epoch = "epoch"
    case timezone = "timezone"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .timestamp:
            return "Timestamp"
        case .iso8601:
            return "ISO 8601"
        case .relative:
            return "Relative Time"
        case .custom:
            return "Custom Format"
        case .epoch:
            return "Unix epoch"
        case .timezone:
            return "Timezone"
        }
    }
    
    var description: String {
        switch self {
        case .timestamp:
            return "Human-readable timestamps"
        case .iso8601:
            return "ISO 8601 standard format"
        case .relative:
            return "Relative time expressions"
        case .custom:
            return "Custom date formats"
        case .epoch:
            return "Unix epoch timestamps"
        case .timezone:
            return "Timezone conversions"
        }
    }
    
    var icon: String {
        switch self {
        case .timestamp:
            return "clock"
        case .iso8601:
            return "doc.text"
        case .relative:
            return "clock.arrow.circlepath"
        case .custom:
            return "slider.horizontal.3"
        case .epoch:
            return "number"
        case .timezone:
            return "globe"
        }
    }
}

/// Date format presets for common use cases
enum DateFormatPreset: String, CaseIterable, Identifiable {
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ"
    case iso8601Extended = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case rfc3339 = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
    case shortDate = "MM/dd/yyyy"
    case longDate = "EEEE, MMMM d, yyyy"
    case shortTime = "h:mm a"
    case longTime = "h:mm:ss a z"
    case httpDate = "EEE, dd MMM yyyy HH:mm:ss zzz"
    case filename = "yyyy-MM-dd_HH-mm-ss"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .iso8601:
            return "ISO 8601"
        case .iso8601Extended:
            return "ISO 8601 Extended"
        case .rfc3339:
            return "RFC 3339"
        case .shortDate:
            return "Short Date"
        case .longDate:
            return "Long Date"
        case .shortTime:
            return "Short Time"
        case .longTime:
            return "Long Time"
        case .httpDate:
            return "HTTP Date"
        case .filename:
            return "Filename Safe"
        }
    }
    
    var example: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = rawValue
        return formatter.string(from: date)
    }
}

/// Relative time units for calculations
enum RelativeTimeUnit: String, CaseIterable, Identifiable {
    case seconds = "seconds"
    case minutes = "minutes"
    case hours = "hours"
    case days = "days"
    case weeks = "weeks"
    case months = "months"
    case years = "years"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .seconds:
            return "Seconds"
        case .minutes:
            return "Minutes"
        case .hours:
            return "Hours"
        case .days:
            return "Days"
        case .weeks:
            return "Weeks"
        case .months:
            return "Months"
        case .years:
            return "Years"
        }
    }
    
    func timeInterval(for value: Int) -> TimeInterval {
        switch self {
        case .seconds:
            return TimeInterval(value)
        case .minutes:
            return TimeInterval(value * 60)
        case .hours:
            return TimeInterval(value * 3600)
        case .days:
            return TimeInterval(value * 86400)
        case .weeks:
            return TimeInterval(value * 604800)
        case .months:
            return TimeInterval(value * 2629746) // Average month
        case .years:
            return TimeInterval(value * 31556952) // Average year
        }
    }
} 