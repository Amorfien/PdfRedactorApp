//
//  WelcomeViewModel.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 16.09.2025.
//

import Foundation
import SwiftUI

import CoreData

final class WelcomeViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var features: [WelcomeFeature] = []

    // MARK: - Init
    init() {
        loadFeatures()

//        let context = CoreDataManager.shared.container.viewContext
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DocEntity.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try context.execute(deleteRequest)
//            try context.save()
//            print("Все DocEntity удалены")
//        } catch {
//            print("Ошибка удаления: \(error)")
//        }
    }

    // MARK: - Public Methods
    func loadFeatures() {
        features = [
            WelcomeFeature(icon: "photo", title: "Добавление фотографий", description: "Загружайте изображения из галереи или файловой системы"),
            WelcomeFeature(icon: "doc.text", title: "Конвертация в PDF", description: "Преобразуйте выбранные изображения в PDF документы"),
            WelcomeFeature(icon: "eye", title: "Просмотр документов", description: "Просматривайте созданные PDF файлы в удобной читалке"),
            WelcomeFeature(icon: "square.and.arrow.up", title: "Поделиться", description: "Отправляйте документы через доступные приложения"),
            WelcomeFeature(icon: "folder", title: "Сохранение", description: "Сохраняйте документы для последующего доступа"),
            WelcomeFeature(icon: "trash", title: "Управление", description: "Удаляйте ненужные страницы и документы"),
            WelcomeFeature(icon: "doc.on.doc", title: "Объединение", description: "Объединяйте несколько документов в один")
        ]
    }

    func generateButtonDidTap() {
        print("Generate")
    }
    func StorageButtonDidTap() {
        print("Storage")
    }
}
