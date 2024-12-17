import SwiftUI

struct CalendarSection: View {
    @Binding var selectedDate: Date

    var body: some View {
        VStack(spacing: 8) {
            Text(currentDayAndDate())
                .font(.headline)
                .foregroundColor(.black)

            HStack(spacing: 8) {
                ForEach(daysInWeek(for: selectedDate), id: \.self) { day in
                    let isToday = Calendar.current.isDateInToday(day)
                    let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)

                    Text(dayShortName(for: day))
                        .fontWeight(.bold)
                        .frame(width: 36, height: 36)
                        .background(isToday ? Color.red : Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedDate = day
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
        )
        .padding(.horizontal)
    }

    func currentDayAndDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date()).capitalized
    }

    func daysInWeek(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return []
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    func dayShortName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
    }
}
