import XCTest
@testable import DogTagStorage

@available(macOS 12.0, *)
final class CoreDataStorageTests: XCTestCase {
    
    var storageManager: CoreDataStorageManager!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create a test configuration
        let testConfig = StorageConfiguration(
            databaseName: "TestDB_\(UUID().uuidString)",
            enableLogging: false,
            enableCloudSync: false,
            customDatabasePath: nil,
            schemaVersion: "1.0",
            maxRetryAttempts: 3,
            timeoutInterval: 30.0
        )
        
        storageManager = try await CoreDataStorageManager(configuration: testConfig)
    }
    
    override func tearDown() async throws {
        // Clean up test data
        try await storageManager.deleteAllCredentials()
        try await storageManager.deleteAllServerCredentials()
        try await storageManager.deleteAllVirtualKeys()
        
        storageManager = nil
        try await super.tearDown()
    }
    
    // MARK: - Credential Tests
    
    func testSaveAndFetchCredential() async throws {
        // Given
        let testCredential = CredentialData(
            id: "test-credential-id",
            rpId: "example.com",
            userHandle: Data("test-user".utf8),
            publicKey: Data("test-public-key".utf8),
            privateKeyRef: "test-private-key-ref",
            createdAt: Date(),
            lastUsed: nil,
            signCount: 0,
            isResident: false,
            userDisplayName: "Test User",
            credentialType: "public-key"
        )
        
        // When
        try await storageManager.saveCredential(testCredential)
        let fetchedCredential = try await storageManager.fetchCredential(id: testCredential.id)
        
        // Then
        XCTAssertNotNil(fetchedCredential)
        XCTAssertEqual(fetchedCredential?.id, testCredential.id)
        XCTAssertEqual(fetchedCredential?.rpId, testCredential.rpId)
        XCTAssertEqual(fetchedCredential?.userHandle, testCredential.userHandle)
        XCTAssertEqual(fetchedCredential?.publicKey, testCredential.publicKey)
        XCTAssertEqual(fetchedCredential?.userDisplayName, testCredential.userDisplayName)
    }
    
    func testFetchCredentialsByRpId() async throws {
        // Given
        let rpId = "example.com"
        let credential1 = CredentialData(
            id: "cred-1",
            rpId: rpId,
            userHandle: Data("user1".utf8),
            publicKey: Data("key1".utf8)
        )
        let credential2 = CredentialData(
            id: "cred-2",
            rpId: rpId,
            userHandle: Data("user2".utf8),
            publicKey: Data("key2".utf8)
        )
        let credential3 = CredentialData(
            id: "cred-3",
            rpId: "different.com",
            userHandle: Data("user3".utf8),
            publicKey: Data("key3".utf8)
        )
        
        // When
        try await storageManager.saveCredential(credential1)
        try await storageManager.saveCredential(credential2)
        try await storageManager.saveCredential(credential3)
        
        let credentialsForRpId = try await storageManager.fetchCredentials(for: rpId)
        
        // Then
        XCTAssertEqual(credentialsForRpId.count, 2)
        XCTAssertTrue(credentialsForRpId.contains { $0.id == credential1.id })
        XCTAssertTrue(credentialsForRpId.contains { $0.id == credential2.id })
        XCTAssertFalse(credentialsForRpId.contains { $0.id == credential3.id })
    }
    
    func testUpdateCredential() async throws {
        // Given
        let originalCredential = CredentialData(
            id: "test-update-id",
            rpId: "example.com",
            userHandle: Data("user".utf8),
            publicKey: Data("key".utf8),
            signCount: 0
        )
        
        try await storageManager.saveCredential(originalCredential)
        
        // When
        let updatedCredential = originalCredential.withUpdatedSignCount(5)
        try await storageManager.updateCredential(updatedCredential)
        
        let fetchedCredential = try await storageManager.fetchCredential(id: originalCredential.id)
        
        // Then
        XCTAssertNotNil(fetchedCredential)
        XCTAssertEqual(fetchedCredential?.signCount, 5)
    }
    
    func testUpdateSignCount() async throws {
        // Given
        let credential = CredentialData(
            id: "test-sign-count-id",
            rpId: "example.com",
            userHandle: Data("user".utf8),
            publicKey: Data("key".utf8),
            signCount: 0
        )
        
        try await storageManager.saveCredential(credential)
        
        // When
        try await storageManager.updateSignCount(credentialId: credential.id, newCount: 10)
        
        let fetchedCredential = try await storageManager.fetchCredential(id: credential.id)
        
        // Then
        XCTAssertNotNil(fetchedCredential)
        XCTAssertEqual(fetchedCredential?.signCount, 10)
        XCTAssertNotNil(fetchedCredential?.lastUsed)
    }
    
    func testDeleteCredential() async throws {
        // Given
        let credential = CredentialData(
            id: "test-delete-id",
            rpId: "example.com",
            userHandle: Data("user".utf8),
            publicKey: Data("key".utf8)
        )
        
        try await storageManager.saveCredential(credential)
        
        // When
        try await storageManager.deleteCredential(id: credential.id)
        
        let fetchedCredential = try await storageManager.fetchCredential(id: credential.id)
        
        // Then
        XCTAssertNil(fetchedCredential)
    }
    
    // MARK: - Server Credential Tests
    
    func testSaveAndFetchServerCredential() async throws {
        // Given
        let serverCredential = ServerCredentialData(
            id: "server-cred-id",
            credentialId: "server-cred-id-12345",
            publicKeyJWK: "{\"kty\":\"RSA\",\"n\":\"...\"}",
            signCount: 0,
            isDiscoverable: false,
            createdAt: Date(),
            lastVerified: nil,
            rpId: "example.com",
            userHandle: Data("test-user".utf8)
        )
        
        // When
        try await storageManager.saveServerCredential(serverCredential)
        let fetchedCredential = try await storageManager.fetchServerCredential(id: serverCredential.id)
        
        // Then
        XCTAssertNotNil(fetchedCredential)
        XCTAssertEqual(fetchedCredential?.id, serverCredential.id)
        XCTAssertEqual(fetchedCredential?.credentialId, serverCredential.credentialId)
        XCTAssertEqual(fetchedCredential?.publicKeyJWK, serverCredential.publicKeyJWK)
        XCTAssertEqual(fetchedCredential?.rpId, serverCredential.rpId)
        XCTAssertEqual(fetchedCredential?.userHandle, serverCredential.userHandle)
    }
    
    func testFetchServerCredentialByCredentialId() async throws {
        // Given
        let credentialId = "unique-cred-id-12345"
        let serverCredential = ServerCredentialData(
            id: "server-id",
            credentialId: credentialId,
            publicKeyJWK: "{\"kty\":\"RSA\",\"n\":\"...\"}",
            signCount: 0,
            isDiscoverable: false,
            createdAt: Date(),
            lastVerified: nil,
            rpId: "example.com",
            userHandle: Data("test-user".utf8)
        )
        
        // When
        try await storageManager.saveServerCredential(serverCredential)
        let fetchedCredential = try await storageManager.fetchServerCredential(credentialId: credentialId)
        
        // Then
        XCTAssertNotNil(fetchedCredential)
        XCTAssertEqual(fetchedCredential?.id, serverCredential.id)
        XCTAssertEqual(fetchedCredential?.credentialId, credentialId)
    }
    
    // MARK: - Virtual Key Tests
    
    func testSaveAndFetchVirtualKey() async throws {
        // Given
        let virtualKey = VirtualKeyData(
            id: "virtual-key-id",
            name: "Test Virtual Key",
            encryptedPrivateKey: Data("encrypted-private-key".utf8),
            publicKey: Data("public-key-data".utf8),
            algorithm: "RSA",
            keySize: 2048,
            createdAt: Date(),
            lastUsed: nil,
            isActive: true,
            keyDerivationInfo: nil
        )
        
        // When
        try await storageManager.saveVirtualKey(virtualKey)
        let fetchedKey = try await storageManager.fetchVirtualKey(id: virtualKey.id)
        
        // Then
        XCTAssertNotNil(fetchedKey)
        XCTAssertEqual(fetchedKey?.id, virtualKey.id)
        XCTAssertEqual(fetchedKey?.name, virtualKey.name)
        XCTAssertEqual(fetchedKey?.algorithm, virtualKey.algorithm)
        XCTAssertEqual(fetchedKey?.keySize, virtualKey.keySize)
        XCTAssertEqual(fetchedKey?.encryptedPrivateKey, virtualKey.encryptedPrivateKey)
        XCTAssertEqual(fetchedKey?.publicKey, virtualKey.publicKey)
        XCTAssertEqual(fetchedKey?.isActive, virtualKey.isActive)
    }
    
    func testFetchActiveVirtualKeys() async throws {
        // Given
        let activeKey = VirtualKeyData(
            id: "active-key",
            name: "Active Key",
            encryptedPrivateKey: Data("encrypted-active-key".utf8),
            publicKey: Data("public-active-key".utf8),
            algorithm: "RSA",
            keySize: 2048,
            isActive: true
        )
        let inactiveKey = VirtualKeyData(
            id: "inactive-key",
            name: "Inactive Key",
            encryptedPrivateKey: Data("encrypted-inactive-key".utf8),
            publicKey: Data("public-inactive-key".utf8),
            algorithm: "RSA",
            keySize: 2048,
            isActive: false
        )
        
        // When
        try await storageManager.saveVirtualKey(activeKey)
        try await storageManager.saveVirtualKey(inactiveKey)
        
        let activeKeys = try await storageManager.fetchActiveVirtualKeys()
        
        // Then
        XCTAssertEqual(activeKeys.count, 1)
        XCTAssertEqual(activeKeys.first?.id, activeKey.id)
    }
    
    // MARK: - Bulk Operations Tests
    
    func testDeleteAllCredentials() async throws {
        // Given
        let credential1 = CredentialData(id: "cred1", rpId: "example.com", userHandle: Data("user1".utf8), publicKey: Data("key1".utf8))
        let credential2 = CredentialData(id: "cred2", rpId: "example.com", userHandle: Data("user2".utf8), publicKey: Data("key2".utf8))
        
        try await storageManager.saveCredential(credential1)
        try await storageManager.saveCredential(credential2)
        
        // When
        try await storageManager.deleteAllCredentials()
        
        let allCredentials = try await storageManager.fetchCredentials()
        
        // Then
        XCTAssertTrue(allCredentials.isEmpty)
    }
    
    // MARK: - Diagnostics Tests
    
    func testGetStorageInfo() async throws {
        // Given
        let credential = CredentialData(id: "info-test", rpId: "example.com", userHandle: Data("user".utf8), publicKey: Data("key".utf8))
        try await storageManager.saveCredential(credential)
        
        // When
        let storageInfo = try await storageManager.getStorageInfo()
        
        // Then
        XCTAssertEqual(storageInfo.backendType, .coreData)
        XCTAssertEqual(storageInfo.credentialCount, 1)
        XCTAssertEqual(storageInfo.schemaVersion, "1.0")
        XCTAssertFalse(storageInfo.databasePath.isEmpty)
    }
    
    func testValidateSchema() async throws {
        // When
        let validationResult = try await storageManager.validateSchema()
        
        // Then
        XCTAssertTrue(validationResult.isValid)
        XCTAssertTrue(validationResult.issues.isEmpty)
    }
} 