//
//  CoreDataManager.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 16.09.2025.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    private init() {
        container = NSPersistentContainer(name: "PdfConverterApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        context = container.viewContext
    }

    private func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    func deleteDocument(_ document: DocEntity) throws {
        context.delete(document)
        do {
            try context.save()
        } catch {
            throw error
        }
    }

    func deleteAllDocs() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DocEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            throw error
        }
    }

    func setupFetchedResultsController() -> NSFetchedResultsController<DocEntity> {
        let fetchRequest: NSFetchRequest<DocEntity> = DocEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func saveDocument(_ document: DocGeneratorModel) throws {
        let newDocument = DocEntity(context: context)
        newDocument.id = document.id
        newDocument.name = document.name
        newDocument.fileExtension = document.fileExtension
        newDocument.creationDate = document.creationDate
        newDocument.pdfData = document.pdfData
        newDocument.thumbnail = document.thumbnail
        newDocument.fileSize = document.fileSize

        do {
            try context.save()
            print("Successfully saved document")
        } catch {
            throw error
        }
    }

}
