// RecurrenceRule.swift
import Foundation

enum RecurrenceRule: String, CaseIterable, Codable, Identifiable {
    case none = "Один раз"
    case daily = "Каждый день"
    case everyOtherDay = "Через день"
    case weekly = "Каждую неделю"
    case biWeekly = "Каждые 2 недели"
    case triWeekly = "Каждые 3 недели"
    case monthly = "Каждый месяц"
    case biMonthly = "Каждые 2 месяца"
    case triMonthly = "Каждые 3 месяца"
    case semiAnnual = "Каждые полгода"
    case yearly = "Каждый год"
    
    var id: String { self.rawValue }
}
