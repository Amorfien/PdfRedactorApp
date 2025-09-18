//
//  DocGeneratorViewModel.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 17.09.2025.
//

import SwiftUI
import PhotosUI
import PDFKit
import CoreData

final class DocGeneratorViewModel: NSObject, ObservableObject {
//    @Published var selectedItems: [PhotosPickerItem] = [] {
//        didSet {
//            loadImages()
//        }
//    }
    @Published var selectedImages: [UIImage] = [] {
        didSet {
            loadImages()
        }
    }

//    @Published var selectedImages: [UIImage] = []
    @Published var generatedPDFURL: URL?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let context = CoreDataManager.shared.container.viewContext

//    private let context: NSManagedObjectContext
//    @Environment(\.managedObjectContext) private var context

//    init(context: NSManagedObjectContext) {
//        self.context = context
//        super.init()
//    }

    func loadImages() {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil

            var loadedImages: [UIImage] = []

//            for item in selectedItems {
//                do {
//                    if let data = try await item.loadTransferable(type: Data.self),
//                       let image = UIImage(data: data) {
//                        loadedImages.append(image)
//                    }
//                } catch {
//                    errorMessage = "Не удалось загрузить изображение"
//                }
//            }

            selectedImages.append(contentsOf: loadedImages)
            isLoading = false
        }
    }

    func removeImage(_ image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
            // Также удаляем соответствующий PhotosPickerItem
//            if index < selectedItems.count {
//                selectedItems.remove(at: index)
//            }
        }
    }

    func generatePDF(completion: @escaping (URL?) -> Void) {
        guard !selectedImages.isEmpty else {
            errorMessage = "Нет изображений для создания PDF"
            completion(nil)
            return
        }

        let pdfDocument = PDFDocument()

        for (index, image) in selectedImages.enumerated() {
            if let pdfPage = PDFPage(image: image) {
                pdfDocument.insert(pdfPage, at: index)
            }
        }

        // Создаем временный файл
        let tempDirectory = FileManager.default.temporaryDirectory
//        print(tempDirectory)
        let fileName = "document_\(Date().timeIntervalSince1970).pdf"
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        if pdfDocument.write(to: fileURL) {
            generatedPDFURL = fileURL
            completion(fileURL)
        } else {
            errorMessage = "Не удалось создать PDF документ"
            completion(nil)
        }
    }

    func savePDF() {
        guard let pdfURL = generatedPDFURL else {
            errorMessage = "Сначала создайте PDF документ"
            return
        }

        do {
            let pdfData = try Data(contentsOf: pdfURL)
            savePDFToCoreData(pdfData: pdfData, fileName: pdfURL.lastPathComponent)
        } catch {
            errorMessage = "Не удалось сохранить PDF"
        }
    }

    private func savePDFToCoreData(pdfData: Data, fileName: String) {
//        let context = CoreDataManager.shared.container.viewContext
        let newDocument = DocEntity(context: context)
        newDocument.id = UUID()
        newDocument.name = fileName.replacingOccurrences(of: ".pdf", with: "")
        newDocument.fileExtension = "pdf"
        newDocument.creationDate = Date()
        newDocument.pdfData = pdfData

        newDocument.fileSize = fileSizeString(for: generatedPDFURL)

        // Генерируем thumbnail
        if let pdfDocument = PDFDocument(data: pdfData),
           let firstPage = pdfDocument.page(at: 0) {
            let thumbnailSize = CGSize(width: 100, height: 100)
            let thumbnail = firstPage.thumbnail(of: thumbnailSize, for: .cropBox)
            newDocument.thumbnail = thumbnail.pngData()
        }

        do {
            try context.save()
            errorMessage = nil
        } catch {
            errorMessage = "Не удалось сохранить документ в базу данных"
        }
    }

    private func fileSizeString(for fileURL: URL?) -> String {
        if let fileURL {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                if let fileSize = attributes[.size] as? Int64 {
                    return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
                }
            } catch {
                print("Ошибка получения размера файла: \(error)")
            }
        }
        return "Неизвестный размер"
    }

    func clearSelection() {
//        selectedItems.removeAll()
        selectedImages.removeAll()
        generatedPDFURL = nil
    }
}
