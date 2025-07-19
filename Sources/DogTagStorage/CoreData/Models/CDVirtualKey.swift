// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import CoreData

/// Core Data NSManagedObject for virtual keys
/// This mirrors the SwiftData SDVirtualKey exactly for schema compatibility
@objc(CDVirtualKey)
public class CDVirtualKey: NSManagedObject {
    
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var encryptedPrivateKey: Data
    @NSManaged public var publicKey: Data
    @NSManaged public var algorithm: String
    @NSManaged public var keySize: Int32
    @NSManaged public var createdAt: Date
    @NSManaged public var lastUsed: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var kdfAlgorithm: String?
    @NSManaged public var kdfIterations: Int32
    @NSManaged public var kdfSalt: Data?
    @NSManaged public var kdfKeyLength: Int32
    
    /// Convenience initializer for creating new virtual keys
    convenience init(context: NSManagedObjectContext,
                     id: String,
                     name: String,
                     encryptedPrivateKey: Data,
                     publicKey: Data,
                     algorithm: String,
                     keySize: Int,
                     createdAt: Date = Date(),
                     lastUsed: Date? = nil,
                     isActive: Bool = true,
                     kdfAlgorithm: String? = nil,
                     kdfIterations: Int = 0,
                     kdfSalt: Data? = nil,
                     kdfKeyLength: Int = 0) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.encryptedPrivateKey = encryptedPrivateKey
        self.publicKey = publicKey
        self.algorithm = algorithm
        self.keySize = Int32(keySize)
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.isActive = isActive
        self.kdfAlgorithm = kdfAlgorithm
        self.kdfIterations = Int32(kdfIterations)
        self.kdfSalt = kdfSalt
        self.kdfKeyLength = Int32(kdfKeyLength)
    }
}

// MARK: - Core Data Configuration

extension CDVirtualKey {
    
    /// Fetch request for virtual keys
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDVirtualKey> {
        return NSFetchRequest<CDVirtualKey>(entityName: "VirtualKey")
    }
    
    /// Fetch request for keys by algorithm
    @nonobjc public class func fetchRequest(algorithm: String) -> NSFetchRequest<CDVirtualKey> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "algorithm == %@", algorithm)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    /// Fetch request for active keys
    @nonobjc public class func fetchActiveKeys() -> NSFetchRequest<CDVirtualKey> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "lastUsed", ascending: false)]
        return request
    }
    
    /// Fetch request for a specific key by ID
    @nonobjc public class func fetchRequest(id: String) -> NSFetchRequest<CDVirtualKey> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }
} 
