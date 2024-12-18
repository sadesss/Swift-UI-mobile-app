//WeeklyRecord.swift
import Foundation

struct WeeklyRecord: Identifiable {
    let id = UUID()
    let weekNumber: Int
    let weekDates: String
    let secondsWorked: Int
}
