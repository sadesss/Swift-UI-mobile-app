// ShareSheet.swift
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    var completion: (() -> Void)? = nil  // Новый параметр для обратного вызова

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        
        // Устанавливаем обработчик завершения
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            completion?()  // Вызываем обратный вызов при закрытии ShareSheet
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
