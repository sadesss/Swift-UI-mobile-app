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
                ShareSheet(activityItems: [exportFileURL], completion: {
                    // После закрытия ShareSheet показываем сообщение об успешном экспорте
                    showExportSuccessAlert = true
                })
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
        
        // Получение пути к Documents Directory
        let fileManager = FileManager.default
        let documentsDirectory: URL
        do {
            documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            exportErrorMessage = "Не удалось найти директорию документов."
            showExportErrorAlert = true
            return
        }
        
        let icalFileURL = documentsDirectory.appendingPathComponent("tasks_export.ics")
        
        do {
            try icalData.write(to: icalFileURL)
            print("iCal файл успешно сохранён по адресу: \(icalFileURL)")
            
            // Проверка существования файла
            if fileManager.fileExists(atPath: icalFileURL.path) {
                print("Файл iCal существует.")
            } else {
                print("Файл iCal не существует.")
                exportErrorMessage = "Файл iCal не был создан."
                showExportErrorAlert = true
                return
            }
            
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
