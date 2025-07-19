// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation

/// Storage backend type information
public enum StorageBackendType: String, Codable, Sendable {
    case swiftData = "SwiftData"
    case coreData = "CoreData"
    case mock = "Mock"
}

/// Storage information for diagnostics
public struct StorageInfo: Codable, Sendable {
    public let backendType: StorageBackendType
    public let databasePath: String
    public let databaseSize: Int64
    public let credentialCount: Int
    public let serverCredentialCount: Int
    public let virtualKeyCount: Int
    public let schemaVersion: String
    
    public init(
        backendType: StorageBackendType,
        databasePath: String,
        databaseSize: Int64,
        credentialCount: Int,
        serverCredentialCount: Int,
        virtualKeyCount: Int,
        schemaVersion: String
    ) {
        self.backendType = backendType
        self.databasePath = databasePath
        self.databaseSize = databaseSize
        self.credentialCount = credentialCount
        self.serverCredentialCount = serverCredentialCount
        self.virtualKeyCount = virtualKeyCount
        self.schemaVersion = schemaVersion
    }
}

/// Schema validation result
public struct SchemaValidationResult: Codable, Sendable {
    public let isValid: Bool
    public let issues: [String]
    public let recommendedActions: [String]
    
    public init(isValid: Bool, issues: [String] = [], recommendedActions: [String] = []) {
        self.isValid = isValid
        self.issues = issues
        self.recommendedActions = recommendedActions
    }
}

/// Main storage protocol that all storage implementations must conform to
/// This protocol abstracts away the underlying storage technology (SwiftData vs Core Data)
public protocol StorageManager: Actor, Sendable {
    
    // MARK: - Credential Operations
    
    /// Save a new credential or update an existing one
    func saveCredential(_ credential: CredentialData) async throws
    
    /// Fetch all credentials
    func fetchCredentials() async throws -> [CredentialData]
    
    /// Fetch a specific credential by ID
    func fetchCredential(id: String) async throws -> CredentialData?
    
    /// Fetch all credentials for a specific relying party
    func fetchCredentials(for rpId: String) async throws -> [CredentialData]
    
    /// Delete a credential by ID
    func deleteCredential(id: String) async throws
    
    /// Update an existing credential
    func updateCredential(_ credential: CredentialData) async throws
    
    /// Update just the sign count for a credential (optimized operation)
    func updateSignCount(credentialId: String, newCount: Int) async throws
    
    // MARK: - Server Credential Operations
    
    /// Save a new server credential or update an existing one
    func saveServerCredential(_ serverCredential: ServerCredentialData) async throws
    
    /// Fetch all server credentials
    func fetchServerCredentials() async throws -> [ServerCredentialData]
    
    /// Fetch a specific server credential by ID
    func fetchServerCredential(id: String) async throws -> ServerCredentialData?
    
    /// Fetch a server credential by credential ID
    func fetchServerCredential(credentialId: String) async throws -> ServerCredentialData?
    
    /// Delete a server credential by ID
    func deleteServerCredential(id: String) async throws
    
    /// Update an existing server credential
    func updateServerCredential(_ serverCredential: ServerCredentialData) async throws
    
    // MARK: - Virtual Key Operations
    
    /// Save a new virtual key or update an existing one
    func saveVirtualKey(_ virtualKey: VirtualKeyData) async throws
    
    /// Fetch all virtual keys
    func fetchVirtualKeys() async throws -> [VirtualKeyData]
    
    /// Fetch a specific virtual key by ID
    func fetchVirtualKey(id: String) async throws -> VirtualKeyData?
    
    /// Fetch only active virtual keys
    func fetchActiveVirtualKeys() async throws -> [VirtualKeyData]
    
    /// Delete a virtual key by ID
    func deleteVirtualKey(id: String) async throws
    
    /// Update an existing virtual key
    func updateVirtualKey(_ virtualKey: VirtualKeyData) async throws
    
    // MARK: - Bulk Operations
    
    /// Delete all credentials (use with caution)
    func deleteAllCredentials() async throws
    
    /// Delete all server credentials (use with caution)
    func deleteAllServerCredentials() async throws
    
    /// Delete all virtual keys (use with caution)
    func deleteAllVirtualKeys() async throws
    
    // MARK: - Diagnostics and Maintenance
    
    /// Get information about the storage backend and database
    func getStorageInfo() async throws -> StorageInfo
    
    /// Validate the database schema
    func validateSchema() async throws -> SchemaValidationResult
} 
