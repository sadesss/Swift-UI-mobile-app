// AddTaskView.swift
import SwiftUI
import Foundation

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var location: String = ""
    @State private var category: CalendarCategory = .other  // Новое состояние для категории

    @Binding var tasks: [Date: [Task]]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Дата и время")) {
                    DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)
                    DatePicker("Время", selection: $selectedTime, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("Детали задачи")) {
                    TextField("Название", text: $title)
                    TextField("Описание", text: $description)
                    TextField("Место", text: $location)
                    
                    Picker("Календарь", selection: $category) {
                        ForEach(CalendarCategory.allCases) { category in
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 10, height: 10)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }

                Section {
                    Button(action: saveTask) {
                        Text("Сохранить задачу")
                    }
                    .disabled(title.isEmpty || description.isEmpty || location.isEmpty)
                }
            }
            .navigationTitle("Новая задача")
            
        }
    }

    private func saveTask() {
        let task = Task(
            title: title,
            time: formattedTime(),
            description: description,
            location: location,
            category: category  // Устанавливаем категорию
        )
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        if tasks[startOfDay] != nil {
            tasks[startOfDay]?.append(task)
        } else {
            tasks[startOfDay] = [task]
        }
        presentationMode.wrappedValue.dismiss()
    }

    private func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
}
