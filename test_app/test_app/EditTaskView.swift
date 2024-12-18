// EditTaskView.swift
import SwiftUI

struct EditTaskView: View {
    @Binding var task: Task  

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Редактировать задачу")) {
                    TextField("Название", text: $task.title)
                    TextField("Время", text: $task.time)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Описание", text: $task.description)
                    TextField("Место", text: $task.location)
                    
                    Picker("Категория", selection: $task.category) {
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

                Section(header: Text("Повторение")) {
                    Picker("Повторение", selection: $task.recurrenceRule) {
                        ForEach(RecurrenceRule.allCases) { rule in
                            Text(rule.rawValue).tag(rule)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section {
                    Button("Сохранить изменения") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Редактирование задачи")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct EditTaskView_Previews: PreviewProvider {
    static var previews: some View {
        EditTaskView(task: .constant(Task(title: "Пример", time: "10:00", description: "Описание", location: "Место", category: .work, recurrenceRule: .none)))
    }
}
