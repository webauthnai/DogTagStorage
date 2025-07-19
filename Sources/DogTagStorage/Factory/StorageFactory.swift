// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
#if canImport(SwiftData)
import SwiftData
#endif

/// Factory for creating storage managers with automatic backend selection
public actor StorageFactory {
    private static var cachedManager: (any StorageManager)?
    private static var cachedConfiguration: StorageConfiguration?
    
    /// Create a storage manager with automatic backend selection
    /// - Parameter configuration: Storage configuration to use
    /// - Returns: A storage manager appropriate for the current OS version
    public static func createStorageManager(configuration: StorageConfiguration = .default) async throws -> any StorageManager {
        // Return cached manager if configuration hasn't changed
        if let cached = cachedManager, 
           let cachedConfig = cachedConfiguration,
           areConfigurationsEqual(cachedConfig, configuration) {
            return cached
        }
        
        let manager: any StorageManager
        
        // Select backend based on OS version
        if #available(macOS 14.0, iOS 17.0, *) {
            // Use SwiftData on macOS 14+ and iOS 17+
            do {
                manager = try await SwiftDataStorageManager(configuration: configuration)
            } catch {
                throw StorageError.configurationError("Failed to create SwiftData storage manager: \(error.localizedDescription)")
            }
        } else {
            // Use Core Data on older OS versions
            do {
                manager = try await CoreDataStorageManager(configuration: configuration)
            } catch {
                throw StorageError.configurationError("Failed to create Core Data storage manager: \(error.localizedDescription)")
            }
        }
        
        cachedManager = manager
        cachedConfiguration = configuration
        
        return manager
    }
    
        /// Create a mock storage manager for testing
    /// - Returns: A mock storage manager that doesn't persist data
    public static func createMockStorageManager() -> any StorageManager {
        return MockStorageManager()
    }

    /// Create a storage manager with a specific backend type (for testing)
    /// - Parameters:
    ///   - backendType: The specific backend type to create
    ///   - configuration: Storage configuration to use
    /// - Returns: A storage manager of the specified type
    public static func createStorageManager(
        backendType: StorageBackendType,
        configuration: StorageConfiguration = .default
    ) async throws -> any StorageManager {
        switch backendType {
        case .swiftData:
            if #available(macOS 14.0, iOS 17.0, *) {
                return try await SwiftDataStorageManager(configuration: configuration)
            } else {
                throw StorageError.configurationError("SwiftData is not available on this OS version")
            }
        case .coreData:
            return try await CoreDataStorageManager(configuration: configuration)
        case .mock:
            return MockStorageManager()
        }
    }
    
    /// Reset the cached manager (useful for testing or configuration changes)
    public static func resetCachedManager() {
        cachedManager = nil
        cachedConfiguration = nil
    }
    
    /// Get information about which backend would be selected
    /// - Returns: The backend type that would be selected for the current OS
    public static func getAvailableBackendType() -> StorageBackendType {
        if #available(macOS 14.0, iOS 17.0, *) {
            return .swiftData
        } else {
            return .coreData
        }
    }
    
    /// Check if SwiftData is available on the current platform
    /// - Returns: True if SwiftData is available, false otherwise
    public static func isSwiftDataAvailable() -> Bool {
        if #available(macOS 14.0, iOS 17.0, *) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Private Helpers
    
    private static func areConfigurationsEqual(_ lhs: StorageConfiguration, _ rhs: StorageConfiguration) -> Bool {
        return lhs.databaseName == rhs.databaseName &&
               lhs.enableLogging == rhs.enableLogging &&
               lhs.enableCloudSync == rhs.enableCloudSync &&
               lhs.customDatabasePath == rhs.customDatabasePath &&
               lhs.schemaVersion == rhs.schemaVersion &&
               lhs.maxRetryAttempts == rhs.maxRetryAttempts &&
               lhs.timeoutInterval == rhs.timeoutInterval
    }
}



/// Mock storage manager for testing
internal actor MockStorageManager: StorageManager {
    private var credentials: [String: CredentialData] = [:]
    private var serverCredentials: [String: ServerCredentialData] = [:]
    private var virtualKeys: [String: VirtualKeyData] = [:]
    
    func saveCredential(_ credential: CredentialData) async throws {
        credentials[credential.id] = credential
    }
    
    func fetchCredentials() async throws -> [CredentialData] {
        return Array(credentials.values)
    }
    
    func fetchCredential(id: String) async throws -> CredentialData? {
        return credentials[id]
    }
    
    func fetchCredentials(for rpId: String) async throws -> [CredentialData] {
        return credentials.values.filter { $0.rpId == rpId }
    }
    
    func deleteCredential(id: String) async throws {
        credentials.removeValue(forKey: id)
    }
    
    func updateCredential(_ credential: CredentialData) async throws {
        credentials[credential.id] = credential
    }
    
    func updateSignCount(credentialId: String, newCount: Int) async throws {
        if let credential = credentials[credentialId] {
            credentials[credentialId] = credential.withUpdatedSignCount(newCount)
        }
    }
    
    func saveServerCredential(_ serverCredential: ServerCredentialData) async throws {
        serverCredentials[serverCredential.id] = serverCredential
    }
    
    func fetchServerCredentials() async throws -> [ServerCredentialData] {
        return Array(serverCredentials.values)
    }
    
    func fetchServerCredential(id: String) async throws -> ServerCredentialData? {
        return serverCredentials[id]
    }
    
    func fetchServerCredential(credentialId: String) async throws -> ServerCredentialData? {
        return serverCredentials.values.first { $0.credentialId == credentialId }
    }
    
    func deleteServerCredential(id: String) async throws {
        serverCredentials.removeValue(forKey: id)
    }
    
    func updateServerCredential(_ serverCredential: ServerCredentialData) async throws {
        serverCredentials[serverCredential.id] = serverCredential
    }
    
    func saveVirtualKey(_ virtualKey: VirtualKeyData) async throws {
        virtualKeys[virtualKey.id] = virtualKey
    }
    
    func fetchVirtualKeys() async throws -> [VirtualKeyData] {
        return Array(virtualKeys.values)
    }
    
    func fetchVirtualKey(id: String) async throws -> VirtualKeyData? {
        return virtualKeys[id]
    }
    
    func fetchActiveVirtualKeys() async throws -> [VirtualKeyData] {
        return virtualKeys.values.filter { $0.isActive }
    }
    
    func deleteVirtualKey(id: String) async throws {
        virtualKeys.removeValue(forKey: id)
    }
    
    func updateVirtualKey(_ virtualKey: VirtualKeyData) async throws {
        virtualKeys[virtualKey.id] = virtualKey
    }
    
    func deleteAllCredentials() async throws {
        credentials.removeAll()
    }
    
    func deleteAllServerCredentials() async throws {
        serverCredentials.removeAll()
    }
    
    func deleteAllVirtualKeys() async throws {
        virtualKeys.removeAll()
    }
    
    func getStorageInfo() async throws -> StorageInfo {
        return StorageInfo(
            backendType: .mock,
            databasePath: "in-memory",
            databaseSize: 0,
            credentialCount: credentials.count,
            serverCredentialCount: serverCredentials.count,
            virtualKeyCount: virtualKeys.count,
            schemaVersion: "1.0"
        )
    }
    
    func validateSchema() async throws -> SchemaValidationResult {
        return SchemaValidationResult(isValid: true)
    }
} 
