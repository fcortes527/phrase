//
//  DateProcessing.swift
//  Phrase
//
//  Created by Melanie Zhou on 2/8/24.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore

func getToday() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMMM dd" // Example format: "January 31"
    let today = Date()
    let current_day = dateFormatter.string(from: today)
    return current_day
}

func getMonth() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM"
    let today = Date()
    let current_day = dateFormatter.string(from: today)
    return current_day
}

func formatDateString(_ dateString: String) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let date = formatter.date(from: dateString) else {
        return nil
    }
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MMM d"
    return outputFormatter.string(from: date)
}

func formatTimeString(_ dateString: String) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let date = formatter.date(from: dateString) else {
        return nil
    }
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "h:mm a"
    return outputFormatter.string(from: date)
}

func dateToString(timestamp: Timestamp) -> String {
    let my_date = timestamp.dateValue()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = formatter.string(from: my_date)
    return dateString
}

func convertToDate(from dateString: String, withFormat format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // It's good practice for parsing fixed formats
    let my_date = dateFormatter.date(from: dateString)
    return my_date
}

/* Increment month in YYYY-MM format
 EX: 2023-12 -> 2024-01 */
func incrementMonth(_ dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    guard let date = dateFormatter.date(from: dateString) else {
        return ""
    }
    if let incrementedDate = Calendar.current.date(byAdding: .month, value: 1, to: date) {
        return dateFormatter.string(from: incrementedDate)
    }
    return ""
}

/* Increment month in YYYY-MM format
 EX: 2024-01 -> 2023-12 */
func decrementMonth(_ dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    guard let date = dateFormatter.date(from: dateString) else {
        return ""
    }
    if let decrementedDate = Calendar.current.date(byAdding: .month, value: -1, to: date) {
        return dateFormatter.string(from: decrementedDate)
    }
    return ""
}

/* Format "YYYY-MM" into "Month-name Year" for display purposes */
func formatMonthYear(_ dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    guard let date = dateFormatter.date(from: dateString) else {
        return ""
    }
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter.string(from: date)
}


/* Take YYYY-MM out of yyyy-MM-dd HH:mm:ss string */
func extractMonthYear(_ str: String) -> String {
    // takes YYYY-MM prefix out
    return String(str.prefix(7))
}

/* Returns lowest month in YYYY-MM format from users entries */
func lowestMonth(_ entries: [Entry]) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let monthsAndYears = entries.compactMap { dateFormatter.date(from: $0.created_date) }
        .map { (Calendar.current.component(.year, from: $0), Calendar.current.component(.month, from: $0)) }
    
    if let earliestDate = monthsAndYears.min(by: { $0 < $1 }) {
        return String(format: "%04d-%02d", earliestDate.0, earliestDate.1)
    } else {
        return ""
    }
}

/* Returns highest month in YYYY-MM format from users entries */
func highestMonth(_ entries: [Entry]) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let monthsAndYears = entries.compactMap { dateFormatter.date(from: $0.created_date) }
        .map { (Calendar.current.component(.year, from: $0), Calendar.current.component(.month, from: $0)) }
    
    if let earliestDate = monthsAndYears.max(by: { $0 < $1 }) {
        return String(format: "%04d-%02d", earliestDate.0, earliestDate.1)
    } else {
        return ""
    }
}

/* Returns true is Data A is earlier than B */
func isEarlierDate(_ dateA: String, than dateB: String) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    
    guard let dateA = dateFormatter.date(from: dateA),
          let dateB = dateFormatter.date(from: dateB) else {
        fatalError("Invalid date format")
    }
    return dateA < dateB
}

/* Returns true is Date A is earlier than B */
func isLaterDate(_ dateA: String, than dateB: String) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    
    guard let dateA = dateFormatter.date(from: dateA),
          let dateB = dateFormatter.date(from: dateB) else {
        fatalError("Invalid date format")
    }
    return dateA > dateB
}

/* Tries to decrement month, but stops if current is lowest possible */
func tryDecrementMonth(_ month: String, _ entries: [Entry]) -> String {
    let decremented_month = decrementMonth(month)
    let lowest_month = lowestMonth(entries)
    return isLaterDate(lowest_month, than: decremented_month) ? lowest_month : decremented_month
}

/* Tries to increment month, but stops if current is highest possible */
func tryIncrementMonth(_ month: String, _ entries: [Entry]) -> String {
    let incremented_month = incrementMonth(month)
    let highest_month = highestMonth(entries)
    return isEarlierDate(highest_month, than: incremented_month) ? highest_month : incremented_month
}

func getCurrentMonthYear() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    let today = Date()
    let current_day = dateFormatter.string(from: today)
    return current_day
}

func generateBetween(_ start: String, _ end: String) -> [String] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    
    guard let startDate = dateFormatter.date(from: start),
          let endDate = dateFormatter.date(from: end) else {
        return [""]
    }
    var currentDate = startDate
    var months: [String] = []
    
    let calendar = Calendar.current
    while !calendar.isDate(currentDate, inSameDayAs: endDate) {
        months.append(dateFormatter.string(from: currentDate))
        if let nextMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = nextMonth
        } else {
            break
        }
    }
    months.append(dateFormatter.string(from: endDate))
    return months
}

func generateMonthYearOptions(_ entries: [Entry]) -> [String] {
    let highest_month = getCurrentMonthYear()
    let lowest_month = lowestMonth(entries)
    let between = generateBetween(highest_month, lowest_month)
    return between
}
