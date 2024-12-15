import SwiftUI

struct CalendarView: View {
    @Binding var tasks: [Date: [Task]]
    @State private var selectedDate: Date? = nil
    @State private var currentWeek: Date = Date()

    var body: some View {
        VStack(alignment: .leading) {
            // Навигация по неделям
            HStack {
                Button(action: {
                    currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? currentWeek
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.red)
                }

                Spacer()

                Text(weekDateRange(for: currentWeek))
                    .font(.headline)

                Spacer()

                Button(action: {
                    currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.red)
                }
            }
            .padding()

            // Дни недели
            HStack(spacing: 16) {
                ForEach(daysInWeek(for: currentWeek), id: \.self) { day in
                    let isToday = Calendar.current.isDateInToday(day)
                    let isSelected = selectedDate == Calendar.current.startOfDay(for: day)

                    Circle()
                        .frame(width: 36, height: 36)
                        .foregroundColor(isSelected ? .customBrown : (isToday ? .red : .gray.opacity(0.2)))
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

            // Задачи на выбранную дату
            if let selectedDate = selectedDate {
                let tasksForDate = tasks[Calendar.current.startOfDay(for: selectedDate)] ?? []
                VStack(alignment: .leading) {
                    Text("Задачи на \(formattedDate(selectedDate))")
                        .font(.headline)
                        .padding(.bottom, 8)

                    if tasksForDate.isEmpty {
                        Text("Нет задач на этот день.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(tasksForDate, id: \.id) { task in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("• \(task.title)")
                                        .fontWeight(.bold)
                                    Text(task.time)
                                        .foregroundColor(.gray)
                                    Text("Описание: \(task.description)")
                                    Text("Место: \(task.location)")
                                }

                                Spacer()

                                Button(action: {
                                    deleteTask(task, for: selectedDate)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                )
                .padding(.horizontal)
            } else {
                Text("Выберите день, чтобы увидеть задачи.")
                    .foregroundColor(.gray)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.pink.opacity(0.1).edgesIgnoringSafeArea(.all))
    }

    private func deleteTask(_ task: Task, for date: Date) {
        guard let index = tasks[Calendar.current.startOfDay(for: date)]?.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        tasks[Calendar.current.startOfDay(for: date)]?.remove(at: index)
    }
}
