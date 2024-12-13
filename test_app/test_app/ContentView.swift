import SwiftUI

struct ContentView: View {
    @State private var isTimerRunning = false
    @State private var secondsToday = 0
    @State private var weeklyRecords: [WeeklyRecord] = []
    @State private var dailyRecords: [DailyWorkRecord] = []
    @State private var selectedDate: Date = Date()
    @State private var currentWeekNumber = Calendar.current.component(.weekOfYear, from: Date())
    @State private var tasks: [Date: [Task]] = [:]

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Текущий день и календарь
                VStack(spacing: 8) {
                    Text(currentDayAndDate())
                        .font(.headline)
                        .foregroundColor(.black)
                    

                    HStack(spacing: 8) {
                        ForEach(Weekday.allCases, id: \.self) { weekday in
                            let isToday = Calendar.current.component(.weekday, from: Date()) == weekday.rawValue

                            
                        }
                    }
                    //функция по выбору дня на начальной странице
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
                                    selectedDate = day // Обновляем выбранную дату
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

                // Время за каждый день
                VStack(alignment: .leading) {
                    Text("Время, отработанное за неделю")
                        .font(.headline)
                        .foregroundColor(.black)

                    if dailyRecords.isEmpty {
                        Text("Нет отработанного времени за неделю.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(dailyRecords) { record in
                            HStack {
                                Text(formattedDate(record.date))
                                Spacer()
                                Text(timeString(from: record.secondsWorked))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                )
                .padding(.horizontal)

                // Раздел рабочего времени
                WorkTimeView(
                    isTimerRunning: $isTimerRunning,
                    secondsToday: $secondsToday,
                    secondsThisWeek: Binding(
                        get: { dailyRecords.reduce(0) { $0 + $1.secondsWorked } },
                        set: { _ in } // Временные данные записываются через обновление dailyRecords
                    ),
                    currentWeekNumber: $currentWeekNumber
                )

                Spacer()

                // Нижняя панель навигации
                HStack {
                    NavigationLink(destination: AddTaskView(tasks: $tasks)) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.pink)
                            .font(.largeTitle)
                    }

                    Spacer()

                    NavigationLink(destination: CalendarView(tasks: tasks)) {
                        Image(systemName: "calendar.circle.fill")
                            .foregroundColor(.pink)
                            .font(.largeTitle)
                    }
                }
                .padding()
                .background(Color.pink.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal)
            }
            .background(Color.pink.opacity(0.1).edgesIgnoringSafeArea(.all))
            .onReceive(timer) { _ in
                if isTimerRunning {
                    secondsToday += 1
                    saveDailyRecord(for: Date(), seconds: secondsToday)
                }
                checkForMidnightReset()
            }
        }
    }

    func currentDayAndDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "EEEE, d MMMM"
        return dateFormatter.string(from: date).capitalized
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }

    func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func saveDailyRecord(for date: Date, seconds: Int) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        if let index = dailyRecords.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
            dailyRecords[index].secondsWorked = seconds
        } else {
            dailyRecords.append(DailyWorkRecord(date: startOfDay, secondsWorked: seconds))
        }
    }

    func checkForMidnightReset() {
        let currentDate = Date()
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: currentDate)
        let minute = calendar.component(.minute, from: currentDate)
        let second = calendar.component(.second, from: currentDate)

        if hour == 0 && minute == 0 && second == 0 {
            resetTodayTimer()
        }

        let weekOfYear = calendar.component(.weekOfYear, from: currentDate)
        if weekOfYear != currentWeekNumber {
            currentWeekNumber = weekOfYear
        }
    }

    func resetTodayTimer() {
        saveDailyRecord(for: Date(), seconds: secondsToday)
        secondsToday = 0
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
