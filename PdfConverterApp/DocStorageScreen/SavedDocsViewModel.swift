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

    // MARK: - Published Properties
    @Published var documents: [DocEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var selectedDocument: DocEntity?
    @Published var showDocumentReader: Bool = false

    // MARK: - Core Data
    private let coreDataManager = CoreDataManager.shared
    private var fetchedResultsController: NSFetchedResultsController<DocEntity>?

    // MARK: - Init
    override init() {
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

    func deleteDocument(_ document: DocEntity) {
        let context = coreDataManager.container.viewContext
        context.delete(document)

        do {
            try context.save()
            // Удаляем файл из файловой системы
//            guard let url = document.fileURL else { return }
//            deleteFile(at: url)
        } catch {
            handleError(error)
        }
    }

    func shareDocument(_ document: DocEntity) -> URL? {
//        return document.fileURL
        return nil
    }

    func deleteAll() {
        let context = coreDataManager.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DocEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Все DocEntity удалены")
            documents.removeAll()
        } catch {
            print("Ошибка удаления: \(error)")
        }
    }

    // MARK: - Private Methods

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<DocEntity> = DocEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataManager.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController?.delegate = self
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

//    private func deleteFile(at url: URL) {
//        do {
//            try FileManager.default.removeItem(at: url)
//        } catch {
//            print("Ошибка при удалении файла: \(error)")
//        }
//    }

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
