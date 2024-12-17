// BottomNavigation.swift
import SwiftUI

struct BottomNavigation: View {
    @Binding var tasks: [Date: [Task]]
    
    @State private var showShareSheet = false
    @State private var exportFileURL: URL? = nil
    @State private var showExportSuccessAlert = false
    @State private var showExportErrorAlert = false
    @State private var exportErrorMessage: String = ""
    
    var body: some View {
        HStack {
            NavigationLink(destination: AddTaskView(tasks: $tasks)) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.pink)
                    .font(.largeTitle)
            }
            
            Spacer()
            
            NavigationLink(destination: CalendarView(tasks: $tasks)) {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.pink)
                    .font(.largeTitle)
            }
            
            Spacer()
            
            Button(action: {
                exportICal()
            }) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .foregroundColor(.pink)
                    .font(.largeTitle)
            }
        }
        .padding()
        .background(Color.pink.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal)
        .sheet(isPresented: $showShareSheet) {
            if let exportFileURL = exportFileURL {
                ShareSheet(activityItems: [exportFileURL])
            }
        }
        .alert(isPresented: $showExportErrorAlert) {
            Alert(title: Text("Ошибка"), message: Text(exportErrorMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showExportSuccessAlert) {
            Alert(title: Text("Успех"), message: Text("Календарь задач успешно экспортирован."), dismissButton: .default(Text("OK")))
        }
    }
    
    private func exportICal() {
        guard let icalData = ICalExporter.export(tasks: tasks) else {
            exportErrorMessage = "Не удалось создать данные iCal."
            showExportErrorAlert = true
            return
        }
        
        // Сохранение iCal файла во временную директорию
        let tempDirectory = FileManager.default.temporaryDirectory
        let icalFileURL = tempDirectory.appendingPathComponent("tasks_export.ics")
        
        do {
            try icalData.write(to: icalFileURL)
            print("iCal файл успешно сохранён по адресу: \(icalFileURL)")
            
            // Устанавливаем экспортированный файл
            self.exportFileURL = icalFileURL
            
            // Отображаем ShareSheet с iCal файлом
            showShareSheet = true
            
            // Показать сообщение об успешном экспорте после открытия ShareSheet
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Пауза для отображения ShareSheet
                showExportSuccessAlert = true
            }
        } catch {
            print("Ошибка при записи файла iCal: \(error)")
            exportErrorMessage = "Не удалось сохранить файл iCal."
            showExportErrorAlert = true
        }
    }
}
