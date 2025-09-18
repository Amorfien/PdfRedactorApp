//
//  SavedDocsViewModel.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 17.09.2025.
//

import CoreData
import SwiftUI
import PDFKit

final class SavedDocsViewModel: NSObject, ObservableObject {

    @Environment(\.managedObjectContext) private var context

    // MARK: - Published Properties
    @Published var documents: [DocumentEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var selectedDocument: DocumentEntity?
    @Published var showDocumentReader: Bool = false
    @Published var showMergeSelection: Bool = false
    @Published var documentToMerge: DocumentEntity?
    @Published var documentsToMerge: [DocumentEntity] = []

    // MARK: - Core Data
    private let coreDataManager = CoreDataManager.shared
    private var fetchedResultsController: NSFetchedResultsController<DocumentEntity>?
//    private let context: NSManagedObjectContext

    // MARK: - Init
    override init() {
//        self.context = context
        super.init()
        setupFetchedResultsController()
        loadDocuments()
    }

    // MARK: - Public Methods

    func loadDocuments() {
        isLoading = true

        do {
            try fetchedResultsController?.performFetch()
            if let fetchedDocuments = fetchedResultsController?.fetchedObjects {
                documents = fetchedDocuments.sorted { ($0.creationDate ?? Date()) > ($1.creationDate ?? Date()) }
            }
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    func deleteDocument(_ document: DocumentEntity) {
        let context = coreDataManager.container.viewContext
        context.delete(document)

        do {
            try context.save()
            // Удаляем файл из файловой системы
            guard let url = document.fileURL else { return }
            deleteFile(at: url)
        } catch {
            handleError(error)
        }
    }

    func shareDocument(_ document: DocumentEntity) -> URL? {
        return document.fileURL
    }

    func startMergeProcess(with document: DocumentEntity) {
        documentToMerge = document
        documentsToMerge = [document]
        showMergeSelection = true
    }

    func addDocumentToMerge(_ document: DocumentEntity) {
        if !documentsToMerge.contains(where: { $0.id == document.id }) {
            documentsToMerge.append(document)
        }
    }

    func removeDocumentFromMerge(_ document: DocumentEntity) {
        documentsToMerge.removeAll { $0.id == document.id }
    }

//    func completeMerge() {
//        guard documentsToMerge.count >= 2 else { return }
//
//        isLoading = true
//
//        // Создаем новый объединенный PDF
//        let mergedDocument = DocumentEntity()
//
//        for document in documentsToMerge {
//            if let pdfDoc = DocumentEntity(url: document.fileURL) {
//                for pageIndex in 0..<pdfDoc.pageCount {
//                    if let page = pdfDoc.page(at: pageIndex) {
//                        mergedDocument.insert(page, at: mergedDocument.pageCount)
//                    }
//                }
//            }
//        }
//
//        // Сохраняем объединенный документ
//        saveMergedDocument(mergedDocument)
//
//        // Сбрасываем состояние
//        documentsToMerge = []
//        documentToMerge = nil
//        showMergeSelection = false
//        isLoading = false
//    }

    func cancelMerge() {
        documentsToMerge = []
        documentToMerge = nil
        showMergeSelection = false
    }

    // MARK: - Private Methods

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataManager.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController?.delegate = self
    }

//    private func saveMergedDocument(_ pdfDocument: DocumentEntity) {
//        let fileManager = FileManager.default
//        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileName = "merged_document_\(Date().timeIntervalSince1970).pdf"
//        let fileURL = documentsDirectory.appendingPathComponent(fileName)
//
//        if pdfDocument.write(to: fileURL) {
//            // Сохраняем в CoreData
//            saveDocumentToCoreData(fileURL: fileURL, fileName: fileName)
//        }
//    }

    private func saveDocumentToCoreData(fileURL: URL, fileName: String) {
        let context = coreDataManager.container.viewContext
        let newDocument = DocumentEntity(context: context)

        newDocument.id = UUID()
        newDocument.name = fileName
        newDocument.fileExtension = "pdf"
        newDocument.creationDate = Date()
        newDocument.fileURL = fileURL

        // Генерируем thumbnail
        if let thumbnail = generateThumbnail(for: fileURL) {
            newDocument.thumbnail = thumbnail.jpegData(compressionQuality: 0.8)
        }

        do {
            try context.save()
        } catch {
            handleError(error)
        }
    }

    private func generateThumbnail(for fileURL: URL) -> UIImage? {
        guard let document = PDFDocument(url: fileURL),
              let page = document.page(at: 0) else { return nil }

        let size = CGSize(width: 100, height: 150)
        let pageSize = page.bounds(for: .mediaBox)
        let scale = min(size.width / pageSize.width, size.height / pageSize.height)
        let scaledSize = CGSize(width: pageSize.width * scale, height: pageSize.height * scale)

        return page.thumbnail(of: scaledSize, for: .mediaBox)
    }

    private func deleteFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Ошибка при удалении файла: \(error)")
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension SavedDocsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadDocuments()
    }
}
