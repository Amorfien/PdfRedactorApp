//
//  PDFDocument.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 16.09.2025.
//

import CoreData

@objc(DocumentEntity)
public class DocumentEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String?
    @NSManaged public var fileExtension: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var pdfData: Data
    @NSManaged public var thumbnail: Data?
    @NSManaged public var fileURL: URL?
}

extension DocumentEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentEntity> {
        return NSFetchRequest<DocumentEntity>(entityName: "DocumentEntity")
    }
}
