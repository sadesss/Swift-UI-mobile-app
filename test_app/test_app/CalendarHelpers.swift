//CalendarHelpers.swift
import SwiftUI

func weekDateRange(for date: Date) -> String {
    let calendar = Calendar.current
    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? date

    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM"
    let start = formatter.string(from: startOfWeek)
    let end = formatter.string(from: endOfWeek)
    return "\(start) - \(end)"
}

func daysInWeek(for date: Date) -> [Date] {
    let calendar = Calendar.current
    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
}

func dayShortName(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EE"
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter.string(from: date)
}

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM yyyy"
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter.string(from: date)
}

extension Color {
    static let customBrown = Color(red: 0.2, green: 0.1, blue: 0.2)
}
