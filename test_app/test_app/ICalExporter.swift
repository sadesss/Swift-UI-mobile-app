// ICalExporter.swift
import Foundation

struct ICalExporter {
    static func export(tasks: [Date: [Task]]) -> Data? {
        var icalString = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//Planeta//Planeta v1.0//EN
        CALSCALE:GREGORIAN
        """

        let calendar = Calendar.current
        let timeZone = TimeZone.current.identifier
        icalString += "\nBEGIN:VTIMEZONE\nTZID:\(timeZone)\nEND:VTIMEZONE\n"

        for (date, tasksForDate) in tasks {
            for task in tasksForDate {
                // Генерация UID
                let uid = UUID().uuidString + "@mail.ru"

                // DTSTAMP - текущее время в UTC
                let dtstamp = formattedDate(date: Date(), format: "yyyyMMdd'T'HHmmss'Z'")

                // DTSTART и DTEND
                guard let dtstartDate = dateWithTime(from: task.time, date: date) else {
                    print("Неверный формат времени для задачи: \(task.title)")
                    continue // Пропустить задачу, если время некорректно
                }
                let dtstart = formattedDate(date: dtstartDate, format: "yyyyMMdd'T'HHmmss")
                
                // Предполагаем продолжительность задачи 1 час
                guard let dtendDate = calendar.date(byAdding: .hour, value: 1, to: dtstartDate) else {
                    print("Неверное время окончания для задачи: \(task.title)")
                    continue
                }
                let dtend = formattedDate(date: dtendDate, format: "yyyyMMdd'T'HHmmss")

                // SUMMARY, DESCRIPTION, LOCATION, CATEGORIES
                let summary = escapeString(task.title)
                let description = escapeString(task.description)
                let location = escapeString(task.location)
                let categories = escapeString(task.category.rawValue)

                // VEVENT
                let vevent = """
                BEGIN:VEVENT
                UID:\(uid)
                DTSTAMP:\(dtstamp)
                DTSTART;TZID=\(timeZone):\(dtstart)
                DTEND;TZID=\(timeZone):\(dtend)
                SUMMARY:\(summary)
                DESCRIPTION:\(description)
                LOCATION:\(location)
                CATEGORIES:\(categories)
                END:VEVENT
                """
                icalString += "\n" + vevent
            }
        }

        icalString += "\nEND:VCALENDAR"

        return icalString.data(using: .utf8)
    }

    private static func formattedDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private static func dateWithTime(from timeString: String, date: Date) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        guard let time = dateFormatter.date(from: timeString) else {
            print("Неверный формат времени: \(timeString)")
            return nil
        }
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        return calendar.date(from: components)
    }

    private static func escapeString(_ string: String) -> String {
        var escaped = string
        escaped = escaped.replacingOccurrences(of: "\\", with: "\\\\")
        escaped = escaped.replacingOccurrences(of: ";", with: "\\;")
        escaped = escaped.replacingOccurrences(of: ",", with: "\\,")
        escaped = escaped.replacingOccurrences(of: "\n", with: "\\n")
        return escaped
    }
}
