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
    @Published var showMergeSelection: Bool = false
    @Published var documentToMerge: DocEntity?
    @Published var documentsToMerge: [DocEntity] = []
    var dataToOpen: Data?

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
        do {
            try coreDataManager.deleteDocument(document)
        } catch {
            handleError(error)
        }
    }

    func shareDocument(_ document: DocEntity?) -> URL? {
        guard let data = document?.pdfData else { return nil }
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("document.pdf")

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Ошибка сохранения временного файла: \(error)")
            return fileURL
        }
    }

    func startMergeProcess(with document: DocEntity) {
        documentToMerge = document
        documentsToMerge = [document]
        showMergeSelection = true
    }

    func addDocumentToMerge(_ document: DocEntity) {
        if !documentsToMerge.contains(where: { $0.id == document.id }) {
            documentsToMerge.append(document)
        }
    }

    func removeDocumentFromMerge(_ document: DocEntity) {
        documentsToMerge.removeAll { $0.id == document.id }
    }

    func completeMerge() {
        guard documentsToMerge.count >= 2 else { return }

        isLoading = true

        let mergedDocument = PDFDocument()

        for document in documentsToMerge {
            if let pdfDoc = PDFDocument(data: document.pdfData ?? Data()) {
                for pageIndex in 0..<pdfDoc.pageCount {
                    if let page = pdfDoc.page(at: pageIndex) {
                        mergedDocument.insert(page, at: mergedDocument.pageCount)
                    }
                }
            }
        }

        saveMergedDocument(mergedDocument)

        documentsToMerge = []
        documentToMerge = nil
        showMergeSelection = false
        isLoading = false
    }

    func cancelMerge() {
        documentsToMerge = []
        documentToMerge = nil
        showMergeSelection = false
    }

    func deleteAll() {
        do {
            try coreDataManager.deleteAllDocs()
            documents.removeAll()
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Methods

    private func setupFetchedResultsController() {
        fetchedResultsController = coreDataManager.setupFetchedResultsController()
        fetchedResultsController?.delegate = self
    }

    private func saveMergedDocument(_ pdfDocument: PDFDocument) {
        let fileName = "merged_document_\(Date().timeIntervalSince1970).pdf"
        let thumbnailData = DocumentService.makeThumbnail(from: pdfDocument.dataRepresentation())
        let fileSize = DocumentService.makeFileSizeStr(from: pdfDocument.dataRepresentation())

        let newDocument = DocGeneratorModel(
            id: UUID(),
            name: fileName.replacingOccurrences(of: ".pdf", with: ""),
            fileExtension: "pdf",
            creationDate: Date(),
            pdfData: pdfDocument.dataRepresentation(),
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
