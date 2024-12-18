// CalendarView.swift
import SwiftUI

struct EditableTask: Identifiable {
    let id = UUID()
    let date: Date
    let task: Task
}

struct CalendarView: View {
    @Binding var tasks: [Date: [Task]]
    @State private var currentWeek: Date = Date()
    @State private var editableTask: EditableTask? = nil
    @State private var selectedDate: Date? = nil

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            weekNavigation
            weekDaysView
            tasksForSelectedDateView
            Spacer()
        }
        .sheet(item: $editableTask) { editable in
            EditTaskView(task: Binding(
                get: {
                    let day = Calendar.current.startOfDay(for: editable.date)
                    if let tasksForDay = tasks[day],
                       let index = tasksForDay.firstIndex(where: { $0.id == editable.task.id }) {
                        return tasksForDay[index]
                    }
                    return Task(title: "", time: "", description: "", location: "", category: .other, recurrenceRule: .none)
                },
                set: { newTask in
                    let day = Calendar.current.startOfDay(for: editable.date)
                    if var tasksForDay = tasks[day],
                       let index = tasksForDay.firstIndex(where: { $0.id == editable.task.id }) {
                        tasksForDay[index] = newTask
                        tasks[day] = tasksForDay
                    }
                }
            ))
        }
        .padding()
        .background(Color.pink.opacity(0.1).edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.red)
                        Text("Назад")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    // MARK: - Week Navigation
    private var weekNavigation: some View {
        HStack {
            Button(action: {
                currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? currentWeek
            }) {
                Image(systemName: "chevron.left").foregroundColor(.red)
            }

            Spacer()

            Text(weekDateRange(for: currentWeek)).font(.headline)

            Spacer()

            Button(action: {
                currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
            }) {
                Image(systemName: "chevron.right").foregroundColor(.red)
            }
        }
        .padding()
    }

    private var weekDaysView: some View {
        HStack(spacing: 16) {
            ForEach(daysInWeek(for: currentWeek), id: \.self) { day in
                let isToday = Calendar.current.isDateInToday(day)
                let isSelected = isDaySelected(day)

                Circle()
                    .frame(width: 36, height: 36)
                    .foregroundColor(isSelected ? .brown : (isToday ? .red : .gray.opacity(0.2)))
                    .overlay(
                        Text(dayShortName(for: day))
                            .foregroundColor(isSelected || isToday ? .white : .black)
                            .font(.headline)
                    )
                    .onTapGesture {
                        selectedDate = Calendar.current.startOfDay(for: day)
                    }
            }
        }
        .padding()
    }

    private var tasksForSelectedDateView: some View {
        VStack(alignment: .leading) {
            if let selectedDate = selectedDate {
                let tasksForDate = getTasks(for: selectedDate)
                Text("Задачи на \(formattedDate(selectedDate))")
                    .font(.headline)
                    .padding(.bottom, 8)

                if tasksForDate.isEmpty {
                    Text("Нет задач на этот день.")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        ForEach(tasksForDate) { task in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("• \(task.title)").fontWeight(.bold)
                                    Text(task.time).foregroundColor(.gray)
                                    Text("Описание: \(task.description)")
                                    Text("Место: \(task.location)")

                                    HStack {
                                        Circle()
                                            .fill(task.category.color)
                                            .frame(width: 8, height: 8)
                                        Text(task.category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.top, 4)
                                    
                                    if task.recurrenceRule != .none {
                                        Text("Повторяется: \(task.recurrenceRule.rawValue)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }

                                Spacer()

                                Button(action: {
                                    editableTask = EditableTask(date: selectedDate, task: task)
                                }) {
                                    Image(systemName: "pencil").foregroundColor(.blue)
                                }

                                Button(action: {
                                    deleteTask(task, for: selectedDate)
                                }) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
            } else {
                Text("Выберите день, чтобы увидеть задачи.")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
        )
        .padding(.horizontal)
    }

    // MARK: - Методы

    /// Проверяет, выбран ли данный день
    private func isDaySelected(_ day: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return Calendar.current.isDate(selectedDate, inSameDayAs: day)
    }

    /// Получает список задач для выбранной даты, включая повторяющиеся
    private func getTasks(for date: Date) -> [Task] {
        var resultTasks = [Task]()
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        // Добавляем задачи, назначенные непосредственно на эту дату
        if let tasksForDate = tasks[startOfDay] {
            resultTasks.append(contentsOf: tasksForDate)
        }
        
        // Добавляем задачи, которые повторяются и должны быть включены на эту дату
        for (baseDate, tasksOnBaseDate) in tasks {
            if baseDate == startOfDay { continue }
            for task in tasksOnBaseDate {
                if task.recurrenceRule != .none && isTaskRecurring(task, baseDate: baseDate, on: startOfDay) {
                    let recurringTask = Task(
                        title: task.title + " (Повторение)",
                        time: task.time,
                        description: task.description,
                        location: task.location,
                        category: task.category,
                        recurrenceRule: .none 
                    )
                    resultTasks.append(recurringTask)
                }
            }
        }
        
        return resultTasks.sorted(by: { $0.time < $1.time })
    }
    
    /// Проверяет, должна ли повторяющаяся задача отображаться на данной дате
    private func isTaskRecurring(_ task: Task, baseDate: Date, on date: Date) -> Bool {
        switch task.recurrenceRule {
        case .daily:
            return date >= baseDate
        case .everyOtherDay:
            let daysDifference = Calendar.current.dateComponents([.day], from: baseDate, to: date).day ?? 0
            return daysDifference >= 0 && daysDifference % 2 == 0
        case .weekly:
            let weeksDifference = Calendar.current.dateComponents([.weekOfYear], from: baseDate, to: date).weekOfYear ?? 0
            let sameWeekday = Calendar.current.component(.weekday, from: baseDate) == Calendar.current.component(.weekday, from: date)
            return weeksDifference >= 0 && sameWeekday
        case .biWeekly:
            let weeksDifference = Calendar.current.dateComponents([.weekOfYear], from: baseDate, to: date).weekOfYear ?? 0
            let sameWeekday = Calendar.current.component(.weekday, from: baseDate) == Calendar.current.component(.weekday, from: date)
            return weeksDifference >= 0 && weeksDifference % 2 == 0 && sameWeekday
        case .triWeekly:
            let weeksDifference = Calendar.current.dateComponents([.weekOfYear], from: baseDate, to: date).weekOfYear ?? 0
            let sameWeekday = Calendar.current.component(.weekday, from: baseDate) == Calendar.current.component(.weekday, from: date)
            return weeksDifference >= 0 && weeksDifference % 3 == 0 && sameWeekday
        case .monthly:
            let monthsDifference = Calendar.current.dateComponents([.month], from: baseDate, to: date).month ?? 0
            let sameDay = Calendar.current.component(.day, from: baseDate) == Calendar.current.component(.day, from: date)
            return monthsDifference >= 0 && sameDay
        case .biMonthly:
            let monthsDifference = Calendar.current.dateComponents([.month], from: baseDate, to: date).month ?? 0
            let sameDay = Calendar.current.component(.day, from: baseDate) == Calendar.current.component(.day, from: date)
            return monthsDifference >= 0 && monthsDifference % 2 == 0 && sameDay
        case .triMonthly:
            let monthsDifference = Calendar.current.dateComponents([.month], from: baseDate, to: date).month ?? 0
            let sameDay = Calendar.current.component(.day, from: baseDate) == Calendar.current.component(.day, from: date)
            return monthsDifference >= 0 && monthsDifference % 3 == 0 && sameDay
        case .semiAnnual:
            let monthsDifference = Calendar.current.dateComponents([.month], from: baseDate, to: date).month ?? 0
            let sameDay = Calendar.current.component(.day, from: baseDate) == Calendar.current.component(.day, from: date)
            return monthsDifference >= 0 && monthsDifference % 6 == 0 && sameDay
        case .yearly:
            let yearsDifference = Calendar.current.dateComponents([.year], from: baseDate, to: date).year ?? 0
            let sameMonthAndDay = Calendar.current.component(.month, from: baseDate) == Calendar.current.component(.month, from: date) &&
                                   Calendar.current.component(.day, from: baseDate) == Calendar.current.component(.day, from: date)
            return yearsDifference >= 0 && sameMonthAndDay
        case .none:
            return false
        }
    }

    private func deleteTask(_ task: Task, for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        tasks[day]?.removeAll(where: { $0.id == task.id })
    }

    /// Возвращает строку с диапазоном дат недели
    private func weekDateRange(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        guard let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)),
              let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) else {
            return ""
        }
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }

    /// Возвращает список дат в неделе
    private func daysInWeek(for date: Date) -> [Date] {
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    /// Возвращает короткое название дня недели
    private func dayShortName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
    }

    /// Форматирует дату в строку
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(tasks: .constant([Date(): [Task]()] ))
    }
}
