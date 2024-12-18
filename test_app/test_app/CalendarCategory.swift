
// CalendarCategory.swift
import SwiftUI

/// Перечисление категорий календарей с соответствующими цветами.
enum CalendarCategory: String, CaseIterable, Identifiable {
    case work = "Рабочий"
    case personal = "Личный"
    case study = "Учебный"
    case sports = "Спортивный"
    case other = "Другое"
    case household = "Бытовой"

    var id: String { self.rawValue }

    var color: Color {
        switch self {
        case .work:
            return .green
        case .personal:
            return .blue
        case .study:
            return .yellow
        case .sports:
            return .purple
        case .other:
            return .gray
        case .household:
            return .orange
        }
    }
}
