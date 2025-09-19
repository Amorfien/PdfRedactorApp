//
//  PDFDocument.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 16.09.2025.
//

import CoreData

@objc(DocEntity)
public class DocEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var fileExtension: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var pdfData: Data?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var fileSize: String?
}

extension DocEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocEntity> {
        return NSFetchRequest<DocEntity>(entityName: "DocEntity")
    }
}
