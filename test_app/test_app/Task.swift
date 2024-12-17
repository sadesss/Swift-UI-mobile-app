// Task.swift
import Foundation

/// Модель данных для задачи.
struct Task: Identifiable, Equatable {
    let id: UUID
    var title: String
    var time: String
    var description: String
    var location: String
    var category: CalendarCategory  

    init(id: UUID = UUID(), title: String, time: String, description: String, location: String, category: CalendarCategory = .other) {
        self.id = id
        self.title = title
        self.time = time
        self.description = description
        self.location = location
        self.category = category
    }
}
