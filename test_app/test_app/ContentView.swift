//ContentView.swift
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
                CalendarSection(selectedDate: $selectedDate)

                WeeklyRecordsView(dailyRecords: $dailyRecords)

                WorkTimeView(
                    isTimerRunning: $isTimerRunning,
                    secondsToday: $secondsToday,
                    secondsThisWeek: Binding(
                        get: { dailyRecords.reduce(0) { $0 + $1.secondsWorked } },
                        set: { _ in }
                    ),
                    currentWeekNumber: $currentWeekNumber
                )

                Spacer()

                BottomNavigation(tasks: $tasks)
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

    // Вспомогательные функции для управления таймером и датами
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
}
