// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import SwiftData

/// SwiftData-based storage manager implementation
/// This provides real persistence using SwiftData for macOS 14+ and iOS 17+
@available(macOS 14.0, iOS 17.0, *)
internal actor SwiftDataStorageManager: StorageManager {
    private let configuration: StorageConfiguration
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(configuration: StorageConfiguration) async throws {
        self.configuration = configuration
        
        // Create schema with all model types
        let schema = Schema([
            SDWebAuthnCredential.self,
            SDServerCredential.self,
            SDVirtualKey.self
        ])
        
        // Configure model container with custom database path if provided
        let modelConfiguration: ModelConfiguration
        if let customPath = configuration.customDatabasePath, !customPath.isEmpty {
            let customURL = URL(fileURLWithPath: customPath)
            print("🔧 [SwiftDataStorageManager] Using custom database path: \(customURL.path)")
            
            // Create parent directory if it doesn't exist
            let parentDirectory = customURL.deletingLastPathComponent()
            print("🔧 [SwiftDataStorageManager] Creating parent directory: \(parentDirectory.path)")
            try? FileManager.default.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
            
            modelConfiguration = ModelConfiguration(url: customURL)
            print("🔧 [SwiftDataStorageManager] Configured with custom URL: \(customURL.path)")
        } else {
            modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            print("🔧 [SwiftDataStorageManager] Using default configuration")
        }
        
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContext = ModelContext(modelContainer)
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Initialized with schema version \(configuration.schemaVersion)")
            }
        } catch {
            throw StorageError.configurationError("Failed to initialize SwiftData container: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Credential Operations
    
    func saveCredential(_ credential: CredentialData) async throws {
        do {
            // Check if credential already exists
            let existingCredential = try await fetchSwiftDataCredential(id: credential.id)
            
            if let existing = existingCredential {
                // Update existing
                CredentialMapper.updateSwiftData(existing, with: credential)
            } else {
                // Insert new
                let newModel = CredentialMapper.toSwiftData(credential)
                modelContext.insert(newModel)
            }
            
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Saved credential: \(credential.id)")
            }
        } catch {
            throw StorageError.operationFailed(operation: "saveCredential", reason: error.localizedDescription)
        }
    }
    
    func fetchCredentials() async throws -> [CredentialData] {
        do {
            let descriptor = FetchDescriptor<SDWebAuthnCredential>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { CredentialMapper.fromSwiftData($0) }
        } catch {
            throw StorageError.operationFailed(operation: "fetchCredentials", reason: error.localizedDescription)
        }
    }
    
    func fetchCredential(id: String) async throws -> CredentialData? {
        do {
            let model = try await fetchSwiftDataCredential(id: id)
            return model.map { CredentialMapper.fromSwiftData($0) }
        } catch {
            throw StorageError.operationFailed(operation: "fetchCredential", reason: error.localizedDescription)
        }
    }
    
    func fetchCredentials(for rpId: String) async throws -> [CredentialData] {
        do {
            let predicate = #Predicate<SDWebAuthnCredential> { $0.rpId == rpId }
            let descriptor = FetchDescriptor<SDWebAuthnCredential>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { CredentialMapper.fromSwiftData($0) }
        } catch {
            throw StorageError.operationFailed(operation: "fetchCredentials(for:)", reason: error.localizedDescription)
        }
    }
    
    func deleteCredential(id: String) async throws {
        do {
            guard let model = try await fetchSwiftDataCredential(id: id) else {
                throw StorageError.notFound("Credential with id: \(id)")
            }
            
            modelContext.delete(model)
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Deleted credential: \(id)")
            }
        } catch {
            if error is StorageError {
                throw error
            }
            throw StorageError.operationFailed(operation: "deleteCredential", reason: error.localizedDescription)
        }
    }
    
    func updateCredential(_ credential: CredentialData) async throws {
        try await saveCredential(credential) // SwiftData handles update via save
    }
    
    func updateSignCount(credentialId: String, newCount: Int) async throws {
        do {
            guard let model = try await fetchSwiftDataCredential(id: credentialId) else {
                throw StorageError.notFound("Credential with id: \(credentialId)")
            }
            
            model.signCount = newCount
            model.lastUsed = Date()
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Updated sign count for credential: \(credentialId)")
            }
        } catch {
            if error is StorageError {
                throw error
            }
            throw StorageError.operationFailed(operation: "updateSignCount", reason: error.localizedDescription)
        }
    }
    
    // MARK: - Server Credential Operations
    
    func saveServerCredential(_ serverCredential: ServerCredentialData) async throws {
        do {
            let existingCredential = try await fetchSwiftDataServerCredential(id: serverCredential.id)
            
            if let existing = existingCredential {
                ServerCredentialMapper.updateSwiftData(existing, with: serverCredential)
            } else {
                let newModel = ServerCredentialMapper.toSwiftData(serverCredential)
                modelContext.insert(newModel)
            }
            
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Saved server credential: \(serverCredential.id)")
            }
        } catch {
            throw StorageError.operationFailed(operation: "saveServerCredential", reason: error.localizedDescription)
        }
    }
    
    func fetchServerCredentials() async throws -> [ServerCredentialData] {
        do {
            let descriptor = FetchDescriptor<SDServerCredential>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { ServerCredentialMapper.fromSwiftData($0) }
        } catch {
            throw StorageError.operationFailed(operation: "fetchServerCredentials", reason: error.localizedDescription)
        }
    }
    
    func fetchServerCredential(id: String) async throws -> ServerCredentialData? {
        do {
            let model = try await fetchSwiftDataServerCredential(id: id)
            return model.map { ServerCredentialMapper.fromSwiftData($0) }
        } catch {
            throw StorageError.operationFailed(operation: "fetchServerCredential", reason: error.localizedDescription)
        }
    }
    
    func fetchServerCredential(credentialId: String) async throws -> ServerCredentialData? {
        do {
            let predicate = #Predicate<SDServerCredential> { $0.credentialId == credentialId }
            let descriptor = FetchDescriptor<SDServerCredential>(predicate: predicate)
            let models = try modelContext.fetch(descriptor)
            return models.first.map { ServerCredentialMapper.fromSwiftData($0) }
        } catch {
            throw StorageError.operationFailed(operation: "fetchServerCredential(credentialId:)", reason: error.localizedDescription)
        }
    }
    
    func deleteServerCredential(id: String) async throws {
        do {
            guard let model = try await fetchSwiftDataServerCredential(id: id) else {
                throw StorageError.notFound("Server credential with id: \(id)")
            }
            
            modelContext.delete(model)
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Deleted server credential: \(id)")
            }
        } catch {
            if error is StorageError {
                throw error
            }
            throw StorageError.operationFailed(operation: "deleteServerCredential", reason: error.localizedDescription)
        }
    }
    
    func updateServerCredential(_ serverCredential: ServerCredentialData) async throws {
        try await saveServerCredential(serverCredential)
    }
    
    // MARK: - Virtual Key Operations
    
    func saveVirtualKey(_ virtualKey: VirtualKeyData) async throws {
        do {
            let existingKey = try await fetchSwiftDataVirtualKey(id: virtualKey.id)
            
            if let existing = existingKey {
                VirtualKeyMapper.updateSwiftData(existing, with: virtualKey)
            } else {
                let newModel = VirtualKeyMapper.toSwiftData(virtualKey)
                modelContext.insert(newModel)
            }
            
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Saved virtual key: \(virtualKey.id)")
            }
        } catch {
            throw StorageError.operationFailed(operation: "saveVirtualKey", reason: error.localizedDescription)
        }
    }
    
    func fetchVirtualKeys() async throws -> [VirtualKeyData] {
        do {
            let descriptor = FetchDescriptor<SDVirtualKey>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { VirtualKeyMapper.fromSwiftData($0) }
        } catch {
            throw StorageError.operationFailed(operation: "fetchVirtualKeys", reason: error.localizedDescription)
        }
    }
    
    func fetchVirtualKey(id: String) async throws -> VirtualKeyData? {
        do {
            let model = try await fetchSwiftDataVirtualKey(id: id)
            return model.map { VirtualKeyMapper.fromSwiftData($0) }
        } catch {
            throw StorageError.operationFailed(operation: "fetchVirtualKey", reason: error.localizedDescription)
        }
    }
    
    func fetchActiveVirtualKeys() async throws -> [VirtualKeyData] {
        do {
            let predicate = #Predicate<SDVirtualKey> { $0.isActive == true }
            let descriptor = FetchDescriptor<SDVirtualKey>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { VirtualKeyMapper.fromSwiftData($0) }
        } catch {
            throw StorageError.operationFailed(operation: "fetchActiveVirtualKeys", reason: error.localizedDescription)
        }
    }
    
    func deleteVirtualKey(id: String) async throws {
        do {
            guard let model = try await fetchSwiftDataVirtualKey(id: id) else {
                throw StorageError.notFound("Virtual key with id: \(id)")
            }
            
            modelContext.delete(model)
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Deleted virtual key: \(id)")
            }
        } catch {
            if error is StorageError {
                throw error
            }
            throw StorageError.operationFailed(operation: "deleteVirtualKey", reason: error.localizedDescription)
        }
    }
    
    func updateVirtualKey(_ virtualKey: VirtualKeyData) async throws {
        try await saveVirtualKey(virtualKey)
    }
    
    // MARK: - Bulk Operations
    
    func deleteAllCredentials() async throws {
        do {
            let descriptor = FetchDescriptor<SDWebAuthnCredential>()
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Deleted \(models.count) credentials")
            }
        } catch {
            throw StorageError.operationFailed(operation: "deleteAllCredentials", reason: error.localizedDescription)
        }
    }
    
    func deleteAllServerCredentials() async throws {
        do {
            let descriptor = FetchDescriptor<SDServerCredential>()
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Deleted \(models.count) server credentials")
            }
        } catch {
            throw StorageError.operationFailed(operation: "deleteAllServerCredentials", reason: error.localizedDescription)
        }
    }
    
    func deleteAllVirtualKeys() async throws {
        do {
            let descriptor = FetchDescriptor<SDVirtualKey>()
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
            
            if configuration.enableLogging {
                print("[SwiftDataStorageManager] Deleted \(models.count) virtual keys")
            }
        } catch {
            throw StorageError.operationFailed(operation: "deleteAllVirtualKeys", reason: error.localizedDescription)
        }
    }
    
    // MARK: - Diagnostics
    
    func getStorageInfo() async throws -> StorageInfo {
        do {
            // Get counts
            let credentialCount = try modelContext.fetchCount(FetchDescriptor<SDWebAuthnCredential>())
            let serverCredentialCount = try modelContext.fetchCount(FetchDescriptor<SDServerCredential>())
            let virtualKeyCount = try modelContext.fetchCount(FetchDescriptor<SDVirtualKey>())
            
            // Get database path
            let databasePath = getDatabasePath()
            
            // Get database size
            let databaseSize = getDatabaseSize(path: databasePath)
            
            return StorageInfo(
                backendType: .swiftData,
                databasePath: databasePath,
                databaseSize: databaseSize,
                credentialCount: credentialCount,
                serverCredentialCount: serverCredentialCount,
                virtualKeyCount: virtualKeyCount,
                schemaVersion: configuration.schemaVersion
            )
        } catch {
            throw StorageError.operationFailed(operation: "getStorageInfo", reason: error.localizedDescription)
        }
    }
    
    func validateSchema() async throws -> SchemaValidationResult {
        var issues: [String] = []
        var recommendedActions: [String] = []
        
        do {
            // Test basic operations to validate schema
            _ = try modelContext.fetchCount(FetchDescriptor<SDWebAuthnCredential>())
            _ = try modelContext.fetchCount(FetchDescriptor<SDServerCredential>())
            _ = try modelContext.fetchCount(FetchDescriptor<SDVirtualKey>())
            
            // Schema is valid if we can perform basic operations
            return SchemaValidationResult(isValid: true, issues: issues, recommendedActions: recommendedActions)
            
        } catch {
            issues.append("Schema validation failed: \(error.localizedDescription)")
            recommendedActions.append("Verify SwiftData model definitions match expected schema")
            recommendedActions.append("Consider running migration if schema has changed")
            
            return SchemaValidationResult(isValid: false, issues: issues, recommendedActions: recommendedActions)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func fetchSwiftDataCredential(id: String) async throws -> SDWebAuthnCredential? {
        let predicate = #Predicate<SDWebAuthnCredential> { $0.id == id }
        let descriptor = FetchDescriptor<SDWebAuthnCredential>(predicate: predicate)
        let models = try modelContext.fetch(descriptor)
        return models.first
    }
    
    private func fetchSwiftDataServerCredential(id: String) async throws -> SDServerCredential? {
        let predicate = #Predicate<SDServerCredential> { $0.id == id }
        let descriptor = FetchDescriptor<SDServerCredential>(predicate: predicate)
        let models = try modelContext.fetch(descriptor)
        return models.first
    }
    
    private func fetchSwiftDataVirtualKey(id: String) async throws -> SDVirtualKey? {
        let predicate = #Predicate<SDVirtualKey> { $0.id == id }
        let descriptor = FetchDescriptor<SDVirtualKey>(predicate: predicate)
        let models = try modelContext.fetch(descriptor)
        return models.first
    }
    
    private func getDatabasePath() -> String {
        // SwiftData database path (simplified for now)
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let databaseURL = appSupport?.appendingPathComponent(configuration.databaseName)
        return databaseURL?.path ?? "Unknown"
    }
    
    private func getDatabaseSize(path: String) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
} 
