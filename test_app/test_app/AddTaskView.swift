import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var location: String = ""
    
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
                }
                
                Section {
                    Button(action: saveTask) {
                        Text("Сохранить задачу")
                    }
                    .disabled(title.isEmpty || description.isEmpty || location.isEmpty)
                }
            }
            .navigationTitle("Новая задача")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveTask() {
        let task = Task(
            title: title,
            time: formattedTime(),
            description: description,
            location: location
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

struct Task: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let description: String
    let location: String
}
