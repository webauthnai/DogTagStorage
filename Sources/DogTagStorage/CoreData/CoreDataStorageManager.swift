// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import CoreData

/// Core Data implementation of StorageManager for macOS 12-13 compatibility
@available(macOS 12.0, *)
internal actor CoreDataStorageManager: StorageManager {
    
    // MARK: - Properties
    
    private let persistentContainer: NSPersistentContainer
    private let configuration: StorageConfiguration
    
    // MARK: - Model Creation
    
    /// Create the Core Data model programmatically - no XML/xcdatamodeld files needed!
    /// This exactly matches the schema defined in the original DogTagStorage.xcdatamodeld
    internal static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create WebAuthnClientCredential entity
        let credentialEntity = NSEntityDescription()
        credentialEntity.name = "WebAuthnClientCredential"
        credentialEntity.managedObjectClassName = "CDWebAuthnCredential"
        
        let credentialAttributes = [
            createAttribute(name: "id", type: .stringAttributeType, optional: false),
            createAttribute(name: "rpId", type: .stringAttributeType, optional: false),
            createAttribute(name: "userHandle", type: .binaryDataAttributeType, optional: false),
            createAttribute(name: "publicKey", type: .binaryDataAttributeType, optional: false),
            createAttribute(name: "privateKeyRef", type: .stringAttributeType, optional: true),
            createAttribute(name: "createdAt", type: .dateAttributeType, optional: false),
            createAttribute(name: "lastUsed", type: .dateAttributeType, optional: true),
            createAttribute(name: "signCount", type: .integer32AttributeType, optional: false, defaultValue: 0),
            createAttribute(name: "isResident", type: .booleanAttributeType, optional: false, defaultValue: false),
            createAttribute(name: "userDisplayName", type: .stringAttributeType, optional: true),
            createAttribute(name: "credentialType", type: .stringAttributeType, optional: false, defaultValue: "public-key")
        ]
        credentialEntity.properties = credentialAttributes
        
        // Add uniqueness constraint on id field
        credentialEntity.uniquenessConstraints = [["id"]]
        
        // Create ServerCredential entity
        let serverEntity = NSEntityDescription()
        serverEntity.name = "ServerCredential"
        serverEntity.managedObjectClassName = "CDServerCredential"
        
        let serverAttributes = [
            createAttribute(name: "id", type: .stringAttributeType, optional: false),
            createAttribute(name: "credentialId", type: .stringAttributeType, optional: false),
            createAttribute(name: "publicKeyJWK", type: .stringAttributeType, optional: false),
            createAttribute(name: "signCount", type: .integer32AttributeType, optional: false, defaultValue: 0),
            createAttribute(name: "isDiscoverable", type: .booleanAttributeType, optional: false, defaultValue: false),
            createAttribute(name: "createdAt", type: .dateAttributeType, optional: false),
            createAttribute(name: "lastVerified", type: .dateAttributeType, optional: true),
            createAttribute(name: "rpId", type: .stringAttributeType, optional: false),
            createAttribute(name: "userHandle", type: .binaryDataAttributeType, optional: false),
            // Additional fields to preserve 100% of WebAuthnCredential data
            createAttribute(name: "algorithm", type: .integer32AttributeType, optional: false, defaultValue: -7),
            createAttribute(name: "protocolVersion", type: .stringAttributeType, optional: false, defaultValue: "fido2"),
            createAttribute(name: "attestationFormat", type: .stringAttributeType, optional: true),
            createAttribute(name: "aaguid", type: .stringAttributeType, optional: true),
            createAttribute(name: "backupEligible", type: .booleanAttributeType, optional: false, defaultValue: false),
            createAttribute(name: "backupState", type: .booleanAttributeType, optional: false, defaultValue: false),
            createAttribute(name: "emoji", type: .stringAttributeType, optional: false, defaultValue: "🔑"),
            createAttribute(name: "lastLoginIP", type: .stringAttributeType, optional: true),
            createAttribute(name: "isEnabled", type: .booleanAttributeType, optional: false, defaultValue: true),
            createAttribute(name: "isAdmin", type: .booleanAttributeType, optional: false, defaultValue: false),
            createAttribute(name: "userNumber", type: .integer32AttributeType, optional: false, defaultValue: 0)
        ]
        serverEntity.properties = serverAttributes
        
        // Add uniqueness constraint on id field
        serverEntity.uniquenessConstraints = [["id"]]
        
        // Create VirtualKey entity
        let virtualKeyEntity = NSEntityDescription()
        virtualKeyEntity.name = "VirtualKey"
        virtualKeyEntity.managedObjectClassName = "CDVirtualKey"
        
        let virtualKeyAttributes = [
            createAttribute(name: "id", type: .stringAttributeType, optional: false),
            createAttribute(name: "name", type: .stringAttributeType, optional: false),
            createAttribute(name: "encryptedPrivateKey", type: .binaryDataAttributeType, optional: false),
            createAttribute(name: "publicKey", type: .binaryDataAttributeType, optional: false),
            createAttribute(name: "algorithm", type: .stringAttributeType, optional: false),
            createAttribute(name: "keySize", type: .integer32AttributeType, optional: false),
            createAttribute(name: "createdAt", type: .dateAttributeType, optional: false),
            createAttribute(name: "lastUsed", type: .dateAttributeType, optional: true),
            createAttribute(name: "isActive", type: .booleanAttributeType, optional: false, defaultValue: true),
            createAttribute(name: "kdfAlgorithm", type: .stringAttributeType, optional: true),
            createAttribute(name: "kdfIterations", type: .integer32AttributeType, optional: true),
            createAttribute(name: "kdfSalt", type: .binaryDataAttributeType, optional: true),
            createAttribute(name: "kdfKeyLength", type: .integer32AttributeType, optional: true)
        ]
        virtualKeyEntity.properties = virtualKeyAttributes
        
        // Add uniqueness constraint on id field
        virtualKeyEntity.uniquenessConstraints = [["id"]]
        
        // Add all entities to the model
        model.entities = [credentialEntity, serverEntity, virtualKeyEntity]
        
        return model
    }
    
    private static func createAttribute(name: String, type: NSAttributeType, optional: Bool, defaultValue: Any? = nil) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        if let defaultValue = defaultValue {
            attribute.defaultValue = defaultValue
        }
        return attribute
    }
    
    // MARK: - Initialization
    
    init(configuration: StorageConfiguration = .default) async throws {
        self.configuration = configuration
        // Create Core Data model programmatically for better testing compatibility
        let model = Self.createManagedObjectModel()
        
        persistentContainer = NSPersistentContainer(name: "DogTagStorage", managedObjectModel: model)
        
        // Configure persistent store
        let storeURL = getStoreURL()
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.type = NSSQLiteStoreType
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        
        // Load the persistent store
        try await loadPersistentStore()
    }
    
    private func getStoreURL() -> URL {
        // Use custom database path if provided
        if let customPath = configuration.customDatabasePath, !customPath.isEmpty {
            let customURL = URL(fileURLWithPath: customPath)
            print("🔧 [CoreDataStorageManager] Using custom database path: \(customURL.path)")
            
            // Create parent directory if it doesn't exist
            let parentDirectory = customURL.deletingLastPathComponent()
            print("🔧 [CoreDataStorageManager] Creating parent directory: \(parentDirectory.path)")
            try? FileManager.default.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
            
            print("🔧 [CoreDataStorageManager] Final store URL: \(customURL.path)")
            return customURL
        }
        
        // Fall back to default path
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupport.appendingPathComponent("DogTag")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        
        return appDirectory.appendingPathComponent("DogTagStorage.sqlite")
    }
    
    private func loadPersistentStore() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            persistentContainer.loadPersistentStores { _, error in
                if let error = error {
                    continuation.resume(throwing: StorageError.configurationError("Failed to load persistent store: \(error.localizedDescription)"))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext  
    }
    
    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - Credential Operations
    
    func saveCredential(_ credential: CredentialData) async throws {
        let _ = CDCredentialMapper.fromCredentialData(credential, context: context)
        try saveContext()
    }
    
    func fetchCredential(id: String) async throws -> CredentialData? {
        let request = CDWebAuthnCredential.fetchRequest(id: id)
        let results = try context.fetch(request)
        return results.first.map { CDCredentialMapper.toCredentialData($0) }
    }
    
    func fetchCredentials(for rpId: String) async throws -> [CredentialData] {
        let request = CDWebAuthnCredential.fetchRequest(for: rpId)
        let results = try context.fetch(request)
        return CDCredentialMapper.toCredentialDataArray(results)
    }
    
    func fetchCredentials() async throws -> [CredentialData] {
        let request = CDWebAuthnCredential.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let results = try context.fetch(request)
        return CDCredentialMapper.toCredentialDataArray(results)
    }
    
    func updateCredential(_ credential: CredentialData) async throws {
        let request = CDWebAuthnCredential.fetchRequest(id: credential.id)
        let results = try context.fetch(request)
        
        if let existingCredential = results.first {
            CDCredentialMapper.updateCredential(existingCredential, from: credential)
            try saveContext()
        } else {
            throw StorageError.notFound("Credential with id \(credential.id) not found")
        }
    }
    
    func deleteCredential(id: String) async throws {
        let request = CDWebAuthnCredential.fetchRequest(id: id)
        let results = try context.fetch(request)
        
        if let credential = results.first {
            context.delete(credential)
            try saveContext()
        } else {
            throw StorageError.notFound("Credential with id \(id) not found")
        }
    }
    
    func updateSignCount(credentialId: String, newCount: Int) async throws {
        let request = CDWebAuthnCredential.fetchRequest(id: credentialId)
        let results = try context.fetch(request)
        
        if let credential = results.first {
            credential.signCount = Int32(newCount)
            credential.lastUsed = Date()
            try saveContext()
        } else {
            throw StorageError.notFound("Credential with id \(credentialId) not found")
        }
    }
    

    
    // MARK: - Server Credential Operations
    
    func saveServerCredential(_ serverCredential: ServerCredentialData) async throws {
        let _ = CDServerCredentialMapper.fromServerCredentialData(serverCredential, context: context)
        try saveContext()
    }
    
    func fetchServerCredential(id: String) async throws -> ServerCredentialData? {
        let request = CDServerCredential.fetchRequest(id: id)
        let results = try context.fetch(request)
        return results.first.map { CDServerCredentialMapper.toServerCredentialData($0) }
    }
    
    func fetchServerCredential(credentialId: String) async throws -> ServerCredentialData? {
        let request = CDServerCredential.fetchRequest()
        request.predicate = NSPredicate(format: "credentialId == %@", credentialId as any CVarArg)
        request.fetchLimit = 1
        let results = try context.fetch(request)
        return results.first.map { CDServerCredentialMapper.toServerCredentialData($0) }
    }
    
    func fetchServerCredentials() async throws -> [ServerCredentialData] {
        let request = CDServerCredential.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let results = try context.fetch(request)
        return CDServerCredentialMapper.toServerCredentialDataArray(results)
    }
    
    func updateServerCredential(_ credential: ServerCredentialData) async throws {
        let request = CDServerCredential.fetchRequest(id: credential.id)
        let results = try context.fetch(request)
        
        if let existingCredential = results.first {
            CDServerCredentialMapper.updateCDServerCredential(existingCredential, with: credential)
            try saveContext()
        } else {
            throw StorageError.notFound("Server credential with id \(credential.id) not found")
        }
    }
    
    func deleteServerCredential(id: String) async throws {
        let request = CDServerCredential.fetchRequest(id: id)
        let results = try context.fetch(request)
        
        if let credential = results.first {
            context.delete(credential)
            try saveContext()
        } else {
            throw StorageError.notFound("Server credential with id \(id) not found")
        }
    }
    

    
    // MARK: - Virtual Key Operations
    
    func saveVirtualKey(_ virtualKey: VirtualKeyData) async throws {
        let _ = CDVirtualKeyMapper.fromVirtualKeyData(virtualKey, context: context)
        try saveContext()
    }
    
    func fetchVirtualKey(id: String) async throws -> VirtualKeyData? {
        let request = CDVirtualKey.fetchRequest(id: id)
        let results = try context.fetch(request)
        return results.first.map { CDVirtualKeyMapper.toVirtualKeyData($0) }
    }
    
    func fetchVirtualKeys() async throws -> [VirtualKeyData] {
        let request = CDVirtualKey.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let results = try context.fetch(request)
        return CDVirtualKeyMapper.toVirtualKeyDataArray(results)
    }
    
    func fetchActiveVirtualKeys() async throws -> [VirtualKeyData] {
        let request = CDVirtualKey.fetchActiveKeys()
        let results = try context.fetch(request)
        return CDVirtualKeyMapper.toVirtualKeyDataArray(results)
    }
    
    func updateVirtualKey(_ virtualKey: VirtualKeyData) async throws {
        let request = CDVirtualKey.fetchRequest(id: virtualKey.id)
        let results = try context.fetch(request)
        
        if let existingKey = results.first {
            CDVirtualKeyMapper.updateVirtualKey(existingKey, from: virtualKey)
            try saveContext()
        } else {
            throw StorageError.notFound("Virtual key with id \(virtualKey.id) not found")
        }
    }
    
    func deleteVirtualKey(id: String) async throws {
        let request = CDVirtualKey.fetchRequest(id: id)
        let results = try context.fetch(request)
        
        if let virtualKey = results.first {
            context.delete(virtualKey)
            try saveContext()
        } else {
            throw StorageError.notFound("Virtual key with id \(id) not found")
        }
    }
    

    
    // MARK: - Bulk Operations
    
    func deleteAllCredentials() async throws {
        let request: NSFetchRequest<any NSFetchRequestResult> = CDWebAuthnCredential.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        try saveContext()
    }
    
    func deleteAllServerCredentials() async throws {
        let request: NSFetchRequest<any NSFetchRequestResult> = CDServerCredential.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        try saveContext()
    }
    
    func deleteAllVirtualKeys() async throws {
        let request: NSFetchRequest<any NSFetchRequestResult> = CDVirtualKey.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        try saveContext()
    }
    
    // MARK: - Diagnostics and Maintenance
    
    func getStorageInfo() async throws -> StorageInfo {
        let credentialCount = try context.count(for: CDWebAuthnCredential.fetchRequest())
        let serverCredentialCount = try context.count(for: CDServerCredential.fetchRequest())
        let virtualKeyCount = try context.count(for: CDVirtualKey.fetchRequest())
        
        let storeURL = getStoreURL()
        let databaseSize = try? FileManager.default.attributesOfItem(atPath: storeURL.path)[.size] as? Int64 ?? 0
        
        return StorageInfo(
            backendType: .coreData,
            databasePath: storeURL.path,
            databaseSize: databaseSize ?? 0,
            credentialCount: credentialCount,
            serverCredentialCount: serverCredentialCount,
            virtualKeyCount: virtualKeyCount,
            schemaVersion: "1.0"
        )
    }
    
    func validateSchema() async throws -> SchemaValidationResult {
        // Basic validation - could be enhanced with more comprehensive checks
        do {
            _ = try context.count(for: CDWebAuthnCredential.fetchRequest())
            _ = try context.count(for: CDServerCredential.fetchRequest())
            _ = try context.count(for: CDVirtualKey.fetchRequest())
            return SchemaValidationResult(isValid: true)
        } catch {
            return SchemaValidationResult(
                isValid: false,
                issues: ["Schema validation failed: \(error.localizedDescription)"],
                recommendedActions: ["Check Core Data model integrity", "Consider database migration"]
            )
        }
    }
} 
