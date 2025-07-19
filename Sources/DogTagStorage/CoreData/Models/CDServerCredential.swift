// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import CoreData

/// Core Data NSManagedObject for server credentials
/// This mirrors the SwiftData SDServerCredential exactly for schema compatibility
@objc(CDServerCredential)
public class CDServerCredential: NSManagedObject {
    
    @NSManaged public var id: String
    @NSManaged public var credentialId: String
    @NSManaged public var publicKeyJWK: String
    @NSManaged public var signCount: Int32
    @NSManaged public var isDiscoverable: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var lastVerified: Date?
    @NSManaged public var rpId: String
    @NSManaged public var userHandle: Data
    
    // Additional fields to preserve 100% of WebAuthnCredential data
    @NSManaged public var algorithm: Int32
    @NSManaged public var protocolVersion: String
    @NSManaged public var attestationFormat: String?
    @NSManaged public var aaguid: String?
    @NSManaged public var backupEligible: Bool
    @NSManaged public var backupState: Bool
    @NSManaged public var emoji: String
    @NSManaged public var lastLoginIP: String?
    @NSManaged public var isEnabled: Bool
    @NSManaged public var isAdmin: Bool
    @NSManaged public var userNumber: Int32
    
    /// Convenience initializer for creating new server credentials
    convenience init(context: NSManagedObjectContext,
                     id: String,
                     credentialId: String,
                     publicKeyJWK: String,
                     signCount: Int = 0,
                     isDiscoverable: Bool = false,
                     createdAt: Date = Date(),
                     lastVerified: Date? = nil,
                     rpId: String,
                     userHandle: Data,
                     algorithm: Int = -7,
                     protocolVersion: String = "fido2",
                     attestationFormat: String? = nil,
                     aaguid: String? = nil,
                     backupEligible: Bool? = nil,
                     backupState: Bool? = nil,
                     emoji: String = "🔑",
                     lastLoginIP: String? = nil,
                     isEnabled: Bool = true,
                     isAdmin: Bool = false,
                     userNumber: Int? = nil) {
        self.init(context: context)
        self.id = id
        self.credentialId = credentialId
        self.publicKeyJWK = publicKeyJWK
        self.signCount = Int32(signCount)
        self.isDiscoverable = isDiscoverable
        self.createdAt = createdAt
        self.lastVerified = lastVerified
        self.rpId = rpId
        self.userHandle = userHandle
        self.algorithm = Int32(algorithm)
        self.protocolVersion = protocolVersion
        self.attestationFormat = attestationFormat
        self.aaguid = aaguid
        self.backupEligible = backupEligible ?? false
        self.backupState = backupState ?? false
        self.emoji = emoji
        self.lastLoginIP = lastLoginIP
        self.isEnabled = isEnabled
        self.isAdmin = isAdmin
        self.userNumber = Int32(userNumber ?? 0)
    }
}

// MARK: - Core Data Configuration

extension CDServerCredential {
    
    /// Fetch request for server credentials
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDServerCredential> {
        return NSFetchRequest<CDServerCredential>(entityName: "ServerCredential")
    }
    
    /// Fetch request for credentials by RP ID
    @nonobjc public class func fetchRequest(for rpId: String) -> NSFetchRequest<CDServerCredential> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "rpId == %@", rpId)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    /// Fetch request for discoverable credentials
    @nonobjc public class func fetchDiscoverableCredentials() -> NSFetchRequest<CDServerCredential> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isDiscoverable == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "lastVerified", ascending: false)]
        return request
    }
    
    /// Fetch request for a specific credential by ID
    @nonobjc public class func fetchRequest(id: String) -> NSFetchRequest<CDServerCredential> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }
} 
