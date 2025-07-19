// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import CoreData

/// Core Data NSManagedObject for WebAuthn credentials
/// This mirrors the SwiftData SDWebAuthnCredential exactly for schema compatibility
@objc(CDWebAuthnCredential)
public class CDWebAuthnCredential: NSManagedObject {
    
    @NSManaged public var id: String
    @NSManaged public var rpId: String
    @NSManaged public var userHandle: Data
    @NSManaged public var publicKey: Data
    @NSManaged public var privateKeyRef: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var lastUsed: Date?
    @NSManaged public var signCount: Int32
    @NSManaged public var isResident: Bool
    @NSManaged public var userDisplayName: String?
    @NSManaged public var credentialType: String
    
    /// Convenience initializer for creating new credentials
    convenience init(context: NSManagedObjectContext,
                     id: String,
                     rpId: String,
                     userHandle: Data,
                     publicKey: Data,
                     privateKeyRef: String? = nil,
                     createdAt: Date = Date(),
                     lastUsed: Date? = nil,
                     signCount: Int = 0,
                     isResident: Bool = false,
                     userDisplayName: String? = nil,
                     credentialType: String = "public-key") {
        self.init(context: context)
        self.id = id
        self.rpId = rpId
        self.userHandle = userHandle
        self.publicKey = publicKey
        self.privateKeyRef = privateKeyRef
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.signCount = Int32(signCount)
        self.isResident = isResident
        self.userDisplayName = userDisplayName
        self.credentialType = credentialType
    }
}

// MARK: - Core Data Configuration

extension CDWebAuthnCredential {
    
    /// Fetch request for WebAuthn credentials
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDWebAuthnCredential> {
        return NSFetchRequest<CDWebAuthnCredential>(entityName: "WebAuthnClientCredential")
    }
    
    /// Fetch request for credentials by RP ID
    @nonobjc public class func fetchRequest(for rpId: String) -> NSFetchRequest<CDWebAuthnCredential> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "rpId == %@", rpId)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    /// Fetch request for a specific credential by ID
    @nonobjc public class func fetchRequest(id: String) -> NSFetchRequest<CDWebAuthnCredential> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }
} 
