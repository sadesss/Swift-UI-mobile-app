import Foundation

struct DailyWorkRecord: Identifiable {
    let id = UUID()
    let date: Date
    var secondsWorked: Int
}
