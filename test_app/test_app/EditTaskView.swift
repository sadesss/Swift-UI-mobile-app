// EditTaskView.swift
import SwiftUI

struct EditTaskView: View {
    @Binding var task: Task  // Привязка к редактируемой задаче

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Редактировать задачу")) {
                    TextField("Название", text: $task.title)
                    TextField("Время", text: $task.time)
                    TextField("Описание", text: $task.description)
                    TextField("Место", text: $task.location)
                    
                    Picker("Календарь", selection: $task.category) {
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
