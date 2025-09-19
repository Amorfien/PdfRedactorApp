//
//  DocGeneratorViewModel.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 17.09.2025.
//

import SwiftUI
import PhotosUI
import PDFKit

final class DocGeneratorViewModel: NSObject, ObservableObject {

    @Published var selectedImages: [UIImage] = []
    @Published var generatedPDF: PDFDocument?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let coreDataManager = CoreDataManager.shared

    func removeImage(_ image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
        }
    }

    func generatePDF(completion: @escaping (Data?) -> Void) {
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
        generatedPDF = pdfDocument
        completion(pdfDocument.dataRepresentation())
    }

    func savePDFToCoreData() {
        guard let pdfData = generatedPDF?.dataRepresentation() else { return }
        let thumbnailData = DocumentService.makeThumbnail(from: pdfData)
        let fileSize = DocumentService.makeFileSizeStr(from: pdfData)

        let newDocument = DocGeneratorModel(
            id: UUID(),
            name: "document_\(Date().timeIntervalSince1970)",
            fileExtension: "pdf",
            creationDate: Date(),
            pdfData: pdfData,
            thumbnail: thumbnailData,
            fileSize: fileSize
        )

        do {
            try coreDataManager.saveDocument(newDocument)
            errorMessage = nil
        } catch {
            errorMessage = "Не удалось сохранить документ в базу данных"
        }
    }

    func clearSelection() {
        selectedImages.removeAll()
    }
}
