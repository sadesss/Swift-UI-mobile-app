// Task.swift
import Foundation
import SwiftUI

struct Task: Identifiable, Equatable {
    let id: UUID
    var title: String
    var time: String
    var description: String
    var location: String
    var category: CalendarCategory
    var recurrenceRule: RecurrenceRule

    init(id: UUID = UUID(), title: String, time: String, description: String, location: String, category: CalendarCategory = .other, recurrenceRule: RecurrenceRule = .none) {
        self.id = id
        self.title = title
        self.time = time
        self.description = description
        self.location = location
        self.category = category
        self.recurrenceRule = recurrenceRule
    }
}
