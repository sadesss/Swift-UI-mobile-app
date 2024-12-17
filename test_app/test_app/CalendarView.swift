// CalendarView.swift
import SwiftUI

/// Структура для представления редактируемой задачи, соответствующая протоколу Identifiable.
struct EditableTask: Identifiable {
    let id = UUID()
    let date: Date
    let index: Int
}

struct CalendarView: View {
    @Binding var tasks: [Date: [Task]]
    @State private var currentWeek: Date = Date()
    @State private var editableTask: EditableTask? = nil  // Переменная для управления модальным окном
    @State private var selectedDate: Date? = nil  // Переменная для выбранной даты

    // Добавлено для управления навигацией
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            weekNavigation
            weekDaysView
            tasksForSelectedDateView
            Spacer()
        }
        .sheet(item: $editableTask) { editable in
            // Создаём Binding для конкретной задачи
            EditTaskView(task: Binding(
                get: {
                    tasks[Calendar.current.startOfDay(for: editable.date)]?[editable.index] ?? Task(title: "", time: "", description: "", location: "", category: .other)
                },
                set: { newTask in
                    let day = Calendar.current.startOfDay(for: editable.date)
                    if var dayTasks = tasks[day], editable.index < dayTasks.count {
                        dayTasks[editable.index] = newTask
                        tasks[day] = dayTasks
                    }
                }
            ))
        }
        .padding()
        .background(Color.pink.opacity(0.1).edgesIgnoringSafeArea(.all))
        // Скрываем стандартную кнопку "Back"
        .navigationBarBackButtonHidden(true)
        // Добавляем собственную кнопку "Назад"
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Закрываем текущее представление
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left") // Иконка стрелки назад (опционально)
                            .foregroundColor(.blue) // Цвет иконки
                        Text("Назад")
                            .foregroundColor(.blue) // Цвет текста
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
                        // При выборе дня обновляем selectedDate
                        selectedDate = Calendar.current.startOfDay(for: day)
                    }
            }
        }
        .padding()
    }

    private var tasksForSelectedDateView: some View {
        VStack(alignment: .leading) {
            if let selectedDate = selectedDate {
                let dayStart = Calendar.current.startOfDay(for: selectedDate)
                let tasksForDate = tasks[dayStart] ?? []
                Text("Задачи на \(formattedDate(selectedDate))")
                    .font(.headline)
                    .padding(.bottom, 8)

                if tasksForDate.isEmpty {
                    Text("Нет задач на этот день.")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {  // Добавляем ScrollView для удобства
                        ForEach(tasksForDate.indices, id: \.self) { index in
                            let task = tasksForDate[index]
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("• \(task.title)").fontWeight(.bold)
                                    Text(task.time).foregroundColor(.gray)
                                    Text("Описание: \(task.description)")
                                    Text("Место: \(task.location)")

                                    // Добавляем метку категории
                                    HStack {
                                        Circle()
                                            .fill(task.category.color)
                                            .frame(width: 8, height: 8)
                                        Text(task.category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.top, 4)
                                }

                                Spacer()

                                // Кнопка редактирования
                                Button(action: {
                                    editableTask = EditableTask(date: selectedDate, index: index)
                                }) {
                                    Image(systemName: "pencil").foregroundColor(.blue)
                                }

                                // Кнопка удаления
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

    /// Удаляет задачу из списка
    private func deleteTask(_ task: Task, for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        tasks[day]?.removeAll(where: { $0.id == task.id })
    }

    /// Возвращает строку с диапазоном дат недели
    private func weekDateRange(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)!
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
        CalendarView(tasks: .constant([:]))
    }
}
