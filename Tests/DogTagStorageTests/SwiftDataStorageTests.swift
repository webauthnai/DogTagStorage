import XCTest
@testable import DogTagStorage

final class SwiftDataStorageTests: XCTestCase {
    
    @available(macOS 14.0, iOS 17.0, *)
    func testSwiftDataBackendCreation() async throws {
        // This test only runs on macOS 14+ where SwiftData is available
        guard StorageFactory.isSwiftDataAvailable() else {
            throw XCTSkip("SwiftData not available on this platform")
        }
        
        let storage = try await StorageFactory.createStorageManager(
            backendType: .swiftData,
            configuration: .test
        )
        
        // Verify it's actually a SwiftData backend
        let info = try await storage.getStorageInfo()
        XCTAssertEqual(info.backendType, .swiftData)
        XCTAssertEqual(info.schemaVersion, "1.0")
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    func testSwiftDataPersistence() async throws {
        guard StorageFactory.isSwiftDataAvailable() else {
            throw XCTSkip("SwiftData not available on this platform")
        }
        
        let storage = try await StorageFactory.createStorageManager(
            backendType: .swiftData,
            configuration: .test
        )
        
        // Test credential persistence
        let credential = CredentialData(
            id: "swiftdata-test-\(UUID().uuidString)",
            rpId: "swiftdata.example.com",
            userHandle: Data("swiftdata-user".utf8),
            publicKey: Data("swiftdata-key".utf8),
            signCount: 1
        )
        
        // Save credential
        try await storage.saveCredential(credential)
        
        // Fetch and verify
        let fetchedCredential = try await storage.fetchCredential(id: credential.id)
        XCTAssertNotNil(fetchedCredential)
        XCTAssertEqual(fetchedCredential?.id, credential.id)
        XCTAssertEqual(fetchedCredential?.rpId, credential.rpId)
        XCTAssertEqual(fetchedCredential?.signCount, 1)
        
        // Test update
        try await storage.updateSignCount(credentialId: credential.id, newCount: 5)
        let updatedCredential = try await storage.fetchCredential(id: credential.id)
        XCTAssertEqual(updatedCredential?.signCount, 5)
        XCTAssertNotNil(updatedCredential?.lastUsed)
        
        // Test deletion
        try await storage.deleteCredential(id: credential.id)
        let deletedCredential = try await storage.fetchCredential(id: credential.id)
        XCTAssertNil(deletedCredential)
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    func testSwiftDataServerCredentials() async throws {
        guard StorageFactory.isSwiftDataAvailable() else {
            throw XCTSkip("SwiftData not available on this platform")
        }
        
        let storage = try await StorageFactory.createStorageManager(
            backendType: .swiftData,
            configuration: .test
        )
        
        let serverCredential = ServerCredentialData(
            id: "server-\(UUID().uuidString)",
            credentialId: "cred-\(UUID().uuidString)",
            publicKeyJWK: "mock-jwk-data",
            rpId: "server.example.com",
            userHandle: Data("server-user".utf8)
        )
        
        // Save and verify
        try await storage.saveServerCredential(serverCredential)
        
        let fetchedByCredentialId = try await storage.fetchServerCredential(credentialId: serverCredential.credentialId)
        XCTAssertNotNil(fetchedByCredentialId)
        XCTAssertEqual(fetchedByCredentialId?.id, serverCredential.id)
        
        // Clean up
        try await storage.deleteServerCredential(id: serverCredential.id)
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    func testSwiftDataVirtualKeys() async throws {
        guard StorageFactory.isSwiftDataAvailable() else {
            throw XCTSkip("SwiftData not available on this platform")
        }
        
        let storage = try await StorageFactory.createStorageManager(
            backendType: .swiftData,
            configuration: .test
        )
        
        let kdfInfo = KeyDerivationInfo(
            algorithm: "PBKDF2",
            iterations: 10000,
            salt: Data("test-salt".utf8),
            keyLength: 32
        )
        
        let virtualKey = VirtualKeyData(
            id: "vkey-\(UUID().uuidString)",
            name: "Test Virtual Key",
            encryptedPrivateKey: Data("encrypted-key-data".utf8),
            publicKey: Data("public-key-data".utf8),
            algorithm: "ES256",
            keySize: 256,
            keyDerivationInfo: kdfInfo
        )
        
        // Save and verify
        try await storage.saveVirtualKey(virtualKey)
        
        let fetchedKey = try await storage.fetchVirtualKey(id: virtualKey.id)
        XCTAssertNotNil(fetchedKey)
        XCTAssertEqual(fetchedKey?.name, virtualKey.name)
        XCTAssertEqual(fetchedKey?.algorithm, virtualKey.algorithm)
        XCTAssertNotNil(fetchedKey?.keyDerivationInfo)
        XCTAssertEqual(fetchedKey?.keyDerivationInfo?.algorithm, "PBKDF2")
        XCTAssertEqual(fetchedKey?.keyDerivationInfo?.iterations, 10000)
        
        // Test active key filtering
        let activeKeys = try await storage.fetchActiveVirtualKeys()
        XCTAssertTrue(activeKeys.contains { $0.id == virtualKey.id })
        
        // Deactivate key
        let inactiveKey = virtualKey.withActiveStatus(false)
        try await storage.updateVirtualKey(inactiveKey)
        
        let activeKeysAfterUpdate = try await storage.fetchActiveVirtualKeys()
        XCTAssertFalse(activeKeysAfterUpdate.contains { $0.id == virtualKey.id })
        
        // Clean up
        try await storage.deleteVirtualKey(id: virtualKey.id)
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    func testSwiftDataSchemaValidation() async throws {
        guard StorageFactory.isSwiftDataAvailable() else {
            throw XCTSkip("SwiftData not available on this platform")
        }
        
        let storage = try await StorageFactory.createStorageManager(
            backendType: .swiftData,
            configuration: .test
        )
        
        let result = try await storage.validateSchema()
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.issues.isEmpty)
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    func testSwiftDataBulkOperations() async throws {
        guard StorageFactory.isSwiftDataAvailable() else {
            throw XCTSkip("SwiftData not available on this platform")
        }
        
        let storage = try await StorageFactory.createStorageManager(
            backendType: .swiftData,
            configuration: .test
        )
        
        // Create test data
        let credentials = (1...3).map { i in
            CredentialData(
                id: "bulk-test-\(i)",
                rpId: "bulk.example.com",
                userHandle: Data("user-\(i)".utf8),
                publicKey: Data("key-\(i)".utf8)
            )
        }
        
        // Save all credentials
        for credential in credentials {
            try await storage.saveCredential(credential)
        }
        
        // Verify they exist
        let fetchedCredentials = try await storage.fetchCredentials(for: "bulk.example.com")
        XCTAssertEqual(fetchedCredentials.count, 3)
        
        // Test bulk delete
        try await storage.deleteAllCredentials()
        
        let credentialsAfterDelete = try await storage.fetchCredentials()
        XCTAssertTrue(credentialsAfterDelete.isEmpty)
    }
} 
