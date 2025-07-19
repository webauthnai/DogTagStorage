import XCTest
@testable import DogTagStorage

final class DogTagStorageTests: XCTestCase {
    
    func testStorageFactorySelection() async throws {
        // Test that the factory can create a storage manager
        do {
            let storage = try await StorageFactory.createStorageManager()
            XCTAssertNotNil(storage)
        } catch {
            // On macOS 12-13, Core Data backend is not yet implemented
            if case StorageError.unsupportedOperation = error {
                // This is expected for Core Data backend until Phase 3
                print("Expected error for unimplemented Core Data backend: \(error)")
            } else {
                throw error
            }
        }
        
        // Test backend type detection
        let backendType = StorageFactory.getAvailableBackendType()
        XCTAssertTrue(backendType == .swiftData || backendType == .coreData)
    }
    
    func testMockStorageManager() async throws {
        // Create mock storage manager
        let storage = StorageFactory.createMockStorageManager()
        
        // Test basic credential operations
        let credential = CredentialData(
            id: "test-id",
            rpId: "example.com",
            userHandle: Data("testuser".utf8),
            publicKey: Data("publickey".utf8)
        )
        
        // Save credential
        try await storage.saveCredential(credential)
        
        // Fetch credentials
        let fetchedCredentials = try await storage.fetchCredentials()
        XCTAssertEqual(fetchedCredentials.count, 1)
        XCTAssertEqual(fetchedCredentials.first?.id, "test-id")
        
        // Fetch by RP ID
        let rpCredentials = try await storage.fetchCredentials(for: "example.com")
        XCTAssertEqual(rpCredentials.count, 1)
        
        // Fetch specific credential
        let specificCredential = try await storage.fetchCredential(id: "test-id")
        XCTAssertNotNil(specificCredential)
        XCTAssertEqual(specificCredential?.rpId, "example.com")
        
        // Update sign count
        try await storage.updateSignCount(credentialId: "test-id", newCount: 5)
        let updatedCredential = try await storage.fetchCredential(id: "test-id")
        XCTAssertEqual(updatedCredential?.signCount, 5)
        
        // Delete credential
        try await storage.deleteCredential(id: "test-id")
        let deletedCredential = try await storage.fetchCredential(id: "test-id")
        XCTAssertNil(deletedCredential)
    }
    
    func testServerCredentialOperations() async throws {
        let storage = StorageFactory.createMockStorageManager()
        
        let serverCredential = ServerCredentialData(
            id: "server-id",
            credentialId: "cred-id",
            publicKeyJWK: "jwk-data",
            rpId: "example.com",
            userHandle: Data("testuser".utf8)
        )
        
        // Save server credential
        try await storage.saveServerCredential(serverCredential)
        
        // Fetch server credentials
        let fetchedServerCredentials = try await storage.fetchServerCredentials()
        XCTAssertEqual(fetchedServerCredentials.count, 1)
        
        // Fetch by credential ID
        let foundServerCredential = try await storage.fetchServerCredential(credentialId: "cred-id")
        XCTAssertNotNil(foundServerCredential)
        XCTAssertEqual(foundServerCredential?.id, "server-id")
        
        // Delete server credential
        try await storage.deleteServerCredential(id: "server-id")
        let deletedServerCredential = try await storage.fetchServerCredential(id: "server-id")
        XCTAssertNil(deletedServerCredential)
    }
    
    func testVirtualKeyOperations() async throws {
        let storage = StorageFactory.createMockStorageManager()
        
        let virtualKey = VirtualKeyData(
            id: "virtual-id",
            name: "Test Key",
            encryptedPrivateKey: Data("encrypted".utf8),
            publicKey: Data("public".utf8),
            algorithm: "ES256",
            keySize: 256
        )
        
        // Save virtual key
        try await storage.saveVirtualKey(virtualKey)
        
        // Fetch virtual keys
        let fetchedVirtualKeys = try await storage.fetchVirtualKeys()
        XCTAssertEqual(fetchedVirtualKeys.count, 1)
        
        // Fetch active virtual keys
        let activeVirtualKeys = try await storage.fetchActiveVirtualKeys()
        XCTAssertEqual(activeVirtualKeys.count, 1)
        
        // Update virtual key to inactive
        let inactiveKey = virtualKey.withActiveStatus(false)
        try await storage.updateVirtualKey(inactiveKey)
        
        let updatedActiveKeys = try await storage.fetchActiveVirtualKeys()
        XCTAssertEqual(updatedActiveKeys.count, 0)
        
        // Delete virtual key
        try await storage.deleteVirtualKey(id: "virtual-id")
        let deletedVirtualKey = try await storage.fetchVirtualKey(id: "virtual-id")
        XCTAssertNil(deletedVirtualKey)
    }
    
    func testStorageInfo() async throws {
        let storage = StorageFactory.createMockStorageManager()
        
        let info = try await storage.getStorageInfo()
        XCTAssertEqual(info.backendType, .mock)
        XCTAssertEqual(info.databasePath, "in-memory")
        XCTAssertEqual(info.credentialCount, 0)
        XCTAssertEqual(info.serverCredentialCount, 0)
        XCTAssertEqual(info.virtualKeyCount, 0)
    }
    
    func testSchemaValidation() async throws {
        let storage = StorageFactory.createMockStorageManager()
        
        let result = try await storage.validateSchema()
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.issues.count, 0)
    }
    
    func testCredentialDataImmutability() {
        let credential = CredentialData(
            id: "test",
            rpId: "example.com",
            userHandle: Data(),
            publicKey: Data(),
            signCount: 1
        )
        
        // Test immutable copy with updated sign count
        let updatedCredential = credential.withUpdatedSignCount(5)
        XCTAssertEqual(credential.signCount, 1) // Original unchanged
        XCTAssertEqual(updatedCredential.signCount, 5) // New copy updated
        
        // Test immutable copy with updated last used
        let usedCredential = credential.withUpdatedLastUsed()
        XCTAssertNil(credential.lastUsed) // Original unchanged
        XCTAssertNotNil(usedCredential.lastUsed) // New copy updated
    }
    
    func testStorageConfiguration() {
        let defaultConfig = StorageConfiguration.default
        XCTAssertEqual(defaultConfig.databaseName, "WebManStorage")
        XCTAssertFalse(defaultConfig.enableLogging)
        XCTAssertFalse(defaultConfig.enableCloudSync)
        
        let testConfig = StorageConfiguration.test
        XCTAssertEqual(testConfig.databaseName, "WebManStorageTest")
        XCTAssertTrue(testConfig.enableLogging)
        XCTAssertEqual(testConfig.maxRetryAttempts, 1)
        
        let customConfig = StorageConfiguration(
            databaseName: "Custom",
            enableLogging: true,
            enableCloudSync: true
        )
        XCTAssertEqual(customConfig.databaseName, "Custom")
        XCTAssertTrue(customConfig.enableLogging)
        XCTAssertTrue(customConfig.enableCloudSync)
    }
    
    func testStorageErrors() {
        let configError = StorageError.configurationError("Invalid config")
        XCTAssertEqual(configError.errorDescription, "Storage configuration error: Invalid config")
        
        let notFoundError = StorageError.notFound("credential-123")
        XCTAssertEqual(notFoundError.errorDescription, "Resource not found: credential-123")
        
        let operationError = StorageError.operationFailed(operation: "save", reason: "disk full")
        XCTAssertEqual(operationError.errorDescription, "Operation 'save' failed: disk full")
    }
    
    func testPackageVersion() {
        XCTAssertEqual(DogTagStorage.version, "1.0.0")
        
        let backendType = DogTagStorage.availableBackend
        XCTAssertTrue(backendType == .swiftData || backendType == .coreData)
    }
} 