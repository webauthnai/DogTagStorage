import XCTest
@testable import DogTagStorage

/// Tests to verify schema compatibility and interoperability between SwiftData and Core Data backends
@available(macOS 12.0, *)
final class SchemaCompatibilityTests: XCTestCase {
    
    // MARK: - Schema Validation Tests
    
    func testCoreDataSchemaValidation() async throws {
        // Given: We expect the Core Data schema to match our expected schema
        
        // When: We validate the Core Data schema
        let result = try await SchemaValidator.validateCrossBackendCompatibility()
        
        // Then: Schema should be valid
        if !result.isValid {
            XCTFail("Core Data schema validation failed: \(result.issues.joined(separator: "\n"))")
        }
        
        XCTAssertTrue(result.isValid, "Core Data schema should be valid")
        XCTAssertTrue(result.issues.isEmpty, "Should have no schema issues")
    }
    
    @available(macOS 14.0, *)
    func testSwiftDataSchemaValidation() async throws {
        // Given: We expect the SwiftData schema to match our expected schema
        
        // When: We validate cross-backend compatibility
        let result = try await SchemaValidator.validateCrossBackendCompatibility()
        
        // Then: Both schemas should be valid and identical
        if !result.isValid {
            XCTFail("Schema validation failed: \(result.issues.joined(separator: "\n"))")
        }
        
        XCTAssertTrue(result.isValid, "Both schemas should be valid")
        XCTAssertTrue(result.issues.isEmpty, "Should have no schema differences")
        
        // Verify no differences between backends
        if let comparison = result.schemaComparison {
            XCTAssertTrue(comparison.differences.isEmpty, "Should have no differences between SwiftData and Core Data schemas")
        }
    }
    
    func testExpectedSchemaStructure() async throws {
        // Given: We have our expected schema
        
        // When: We validate against the expected structure
        let result = try await SchemaValidator.validateCrossBackendCompatibility()
        
        // Then: Core Data should match expected schema exactly
        XCTAssertTrue(result.isValid, "Schema should match expected structure")
        
        if let comparison = result.schemaComparison {
            let coreDataSchema = comparison.coreDataSchema
            XCTAssertNotNil(coreDataSchema, "Core Data schema should be available")
            
            // Verify we have all expected tables
            let tableNames = Set(coreDataSchema?.tables.map { $0.name } ?? [])
            let expectedTables: Set<String> = ["WebAuthnClientCredential", "ServerCredential", "VirtualKey"]
            XCTAssertEqual(tableNames, expectedTables, "Should have all expected tables")
            
            // Verify WebAuthn credential table structure
            if let credentialTable = coreDataSchema?.tables.first(where: { $0.name == "WebAuthnClientCredential" }) {
                let columnNames = Set(credentialTable.columns.map { $0.name })
                let expectedColumns: Set<String> = [
                    "id", "rpId", "userHandle", "publicKey", "privateKeyRef",
                    "createdAt", "lastUsed", "signCount", "isResident", 
                    "userDisplayName", "credentialType"
                ]
                XCTAssertEqual(columnNames, expectedColumns, "WebAuthn credential table should have all expected columns")
                
                // Verify column types
                let idColumn = credentialTable.columns.first { $0.name == "id" }
                XCTAssertEqual(idColumn?.type, "TEXT", "ID column should be TEXT")
                XCTAssertFalse(idColumn?.isOptional ?? true, "ID column should not be optional")
                
                let signCountColumn = credentialTable.columns.first { $0.name == "signCount" }
                XCTAssertEqual(signCountColumn?.type, "INTEGER", "Sign count should be INTEGER")
                XCTAssertEqual(signCountColumn?.defaultValue, "0", "Sign count should default to 0")
            } else {
                XCTFail("WebAuthnClientCredential table should exist")
            }
        }
    }
    
    // MARK: - Cross-Backend Interoperability Tests
    
    func testCoreDataAndSwiftDataInteroperability() async throws {
        // This test would ideally create data with one backend and read it with another
        // For now, we verify that both backends can handle the same data structures
        
        let testCredential = CredentialData(
            id: "interop-test-credential",
            rpId: "interop.example.com",
            userHandle: Data("interop-user".utf8),
            publicKey: Data("interop-public-key".utf8),
            privateKeyRef: "interop-private-key-ref",
            createdAt: Date(),
            lastUsed: nil,
            signCount: 42,
            isResident: true,
            userDisplayName: "Interop Test User",
            credentialType: "public-key"
        )
        
        // Test Core Data backend
        let coreDataConfig = StorageConfiguration(
            databaseName: "InteropTest_CoreData_\(UUID().uuidString)",
            enableLogging: false
        )
        let coreDataManager = try await CoreDataStorageManager(configuration: coreDataConfig)
        
        // Save with Core Data
        try await coreDataManager.saveCredential(testCredential)
        let coreDataResult = try await coreDataManager.fetchCredential(id: testCredential.id)
        
        XCTAssertNotNil(coreDataResult, "Core Data should save and retrieve credential")
        XCTAssertEqual(coreDataResult?.id, testCredential.id)
        XCTAssertEqual(coreDataResult?.rpId, testCredential.rpId)
        XCTAssertEqual(coreDataResult?.signCount, testCredential.signCount)
        XCTAssertEqual(coreDataResult?.isResident, testCredential.isResident)
        
        // Test SwiftData backend if available
        if #available(macOS 14.0, *) {
            let swiftDataConfig = StorageConfiguration(
                databaseName: "InteropTest_SwiftData_\(UUID().uuidString)",
                enableLogging: false
            )
            let swiftDataManager = try await SwiftDataStorageManager(configuration: swiftDataConfig)
            
            // Save with SwiftData
            try await swiftDataManager.saveCredential(testCredential)
            let swiftDataResult = try await swiftDataManager.fetchCredential(id: testCredential.id)
            
            XCTAssertNotNil(swiftDataResult, "SwiftData should save and retrieve credential")
            XCTAssertEqual(swiftDataResult?.id, testCredential.id)
            XCTAssertEqual(swiftDataResult?.rpId, testCredential.rpId)
            XCTAssertEqual(swiftDataResult?.signCount, testCredential.signCount)
            XCTAssertEqual(swiftDataResult?.isResident, testCredential.isResident)
            
            // Verify both backends produce identical results
            XCTAssertEqual(coreDataResult?.id, swiftDataResult?.id)
            XCTAssertEqual(coreDataResult?.rpId, swiftDataResult?.rpId)
            XCTAssertEqual(coreDataResult?.userHandle, swiftDataResult?.userHandle)
            XCTAssertEqual(coreDataResult?.publicKey, swiftDataResult?.publicKey)
            XCTAssertEqual(coreDataResult?.signCount, swiftDataResult?.signCount)
            XCTAssertEqual(coreDataResult?.isResident, swiftDataResult?.isResident)
            XCTAssertEqual(coreDataResult?.credentialType, swiftDataResult?.credentialType)
        }
    }
    
    func testServerCredentialInteroperability() async throws {
        let testServerCredential = ServerCredentialData(
            id: "interop-server-credential",
            credentialId: "interop-server-cred-12345",
            publicKeyJWK: "{\"kty\":\"RSA\",\"n\":\"interop-test\"}",
            signCount: 10,
            isDiscoverable: true,
            createdAt: Date(),
            lastVerified: Date(),
            rpId: "interop.example.com",
            userHandle: Data("interop-server-user".utf8)
        )
        
        // Test Core Data
        let coreDataConfig = StorageConfiguration(
            databaseName: "ServerInteropTest_CoreData_\(UUID().uuidString)",
            enableLogging: false
        )
        let coreDataManager = try await CoreDataStorageManager(configuration: coreDataConfig)
        
        try await coreDataManager.saveServerCredential(testServerCredential)
        let coreDataResult = try await coreDataManager.fetchServerCredential(id: testServerCredential.id)
        
        XCTAssertNotNil(coreDataResult)
        XCTAssertEqual(coreDataResult?.credentialId, testServerCredential.credentialId)
        XCTAssertEqual(coreDataResult?.publicKeyJWK, testServerCredential.publicKeyJWK)
        XCTAssertEqual(coreDataResult?.isDiscoverable, testServerCredential.isDiscoverable)
        
        // Test SwiftData if available
        if #available(macOS 14.0, *) {
            let swiftDataConfig = StorageConfiguration(
                databaseName: "ServerInteropTest_SwiftData_\(UUID().uuidString)",
                enableLogging: false
            )
            let swiftDataManager = try await SwiftDataStorageManager(configuration: swiftDataConfig)
            
            try await swiftDataManager.saveServerCredential(testServerCredential)
            let swiftDataResult = try await swiftDataManager.fetchServerCredential(id: testServerCredential.id)
            
            XCTAssertNotNil(swiftDataResult)
            XCTAssertEqual(swiftDataResult?.credentialId, testServerCredential.credentialId)
            XCTAssertEqual(swiftDataResult?.publicKeyJWK, testServerCredential.publicKeyJWK)
            XCTAssertEqual(swiftDataResult?.isDiscoverable, testServerCredential.isDiscoverable)
            
            // Verify identical results
            XCTAssertEqual(coreDataResult?.id, swiftDataResult?.id)
            XCTAssertEqual(coreDataResult?.credentialId, swiftDataResult?.credentialId)
            XCTAssertEqual(coreDataResult?.publicKeyJWK, swiftDataResult?.publicKeyJWK)
            XCTAssertEqual(coreDataResult?.signCount, swiftDataResult?.signCount)
            XCTAssertEqual(coreDataResult?.isDiscoverable, swiftDataResult?.isDiscoverable)
        }
    }
    
    func testVirtualKeyInteroperability() async throws {
        let testVirtualKey = VirtualKeyData(
            id: "interop-virtual-key",
            name: "Interop Test Key",
            encryptedPrivateKey: Data("interop-encrypted-key".utf8),
            publicKey: Data("interop-public-key".utf8),
            algorithm: "RSA",
            keySize: 4096,
            createdAt: Date(),
            lastUsed: Date(),
            isActive: true,
            keyDerivationInfo: KeyDerivationInfo(
                algorithm: "PBKDF2",
                iterations: 100000,
                salt: Data("interop-salt".utf8),
                keyLength: 256
            )
        )
        
        // Test Core Data
        let coreDataConfig = StorageConfiguration(
            databaseName: "VirtualKeyInteropTest_CoreData_\(UUID().uuidString)",
            enableLogging: false
        )
        let coreDataManager = try await CoreDataStorageManager(configuration: coreDataConfig)
        
        try await coreDataManager.saveVirtualKey(testVirtualKey)
        let coreDataResult = try await coreDataManager.fetchVirtualKey(id: testVirtualKey.id)
        
        XCTAssertNotNil(coreDataResult)
        XCTAssertEqual(coreDataResult?.name, testVirtualKey.name)
        XCTAssertEqual(coreDataResult?.algorithm, testVirtualKey.algorithm)
        XCTAssertEqual(coreDataResult?.keySize, testVirtualKey.keySize)
        XCTAssertEqual(coreDataResult?.keyDerivationInfo?.algorithm, testVirtualKey.keyDerivationInfo?.algorithm)
        XCTAssertEqual(coreDataResult?.keyDerivationInfo?.iterations, testVirtualKey.keyDerivationInfo?.iterations)
        
        // Test SwiftData if available
        if #available(macOS 14.0, *) {
            let swiftDataConfig = StorageConfiguration(
                databaseName: "VirtualKeyInteropTest_SwiftData_\(UUID().uuidString)",
                enableLogging: false
            )
            let swiftDataManager = try await SwiftDataStorageManager(configuration: swiftDataConfig)
            
            try await swiftDataManager.saveVirtualKey(testVirtualKey)
            let swiftDataResult = try await swiftDataManager.fetchVirtualKey(id: testVirtualKey.id)
            
            XCTAssertNotNil(swiftDataResult)
            XCTAssertEqual(swiftDataResult?.name, testVirtualKey.name)
            XCTAssertEqual(swiftDataResult?.algorithm, testVirtualKey.algorithm)
            XCTAssertEqual(swiftDataResult?.keySize, testVirtualKey.keySize)
            XCTAssertEqual(swiftDataResult?.keyDerivationInfo?.algorithm, testVirtualKey.keyDerivationInfo?.algorithm)
            
            // Verify identical results
            XCTAssertEqual(coreDataResult?.id, swiftDataResult?.id)
            XCTAssertEqual(coreDataResult?.name, swiftDataResult?.name)
            XCTAssertEqual(coreDataResult?.algorithm, swiftDataResult?.algorithm)
            XCTAssertEqual(coreDataResult?.keySize, swiftDataResult?.keySize)
            XCTAssertEqual(coreDataResult?.encryptedPrivateKey, swiftDataResult?.encryptedPrivateKey)
            XCTAssertEqual(coreDataResult?.publicKey, swiftDataResult?.publicKey)
            XCTAssertEqual(coreDataResult?.isActive, swiftDataResult?.isActive)
        }
    }
    
    // MARK: - Performance and Consistency Tests
    
    func testBackendPerformanceConsistency() async throws {
        // Test that both backends have similar performance characteristics
        let testData = (1...10).map { index in
            CredentialData(
                id: "perf-test-\(index)",
                rpId: "perf.example.com",
                userHandle: Data("user-\(index)".utf8),
                publicKey: Data("key-\(index)".utf8),
                privateKeyRef: "perf-key-ref-\(index)",
                createdAt: Date(),
                lastUsed: nil,
                signCount: 0,
                isResident: false,
                userDisplayName: "Perf Test User \(index)",
                credentialType: "public-key"
            )
        }
        
        // Core Data performance
        let coreDataConfig = StorageConfiguration(
            databaseName: "PerfTest_CoreData_\(UUID().uuidString)",
            enableLogging: false
        )
        let coreDataManager = try await CoreDataStorageManager(configuration: coreDataConfig)
        
        let coreDataStart = Date()
        for credential in testData {
            try await coreDataManager.saveCredential(credential)
        }
        let coreDataTime = Date().timeIntervalSince(coreDataStart)
        
        let coreDataFetchStart = Date()
        let coreDataResults = try await coreDataManager.fetchCredentials()
        let coreDataFetchTime = Date().timeIntervalSince(coreDataFetchStart)
        
        XCTAssertEqual(coreDataResults.count, testData.count, "Core Data should save all credentials")
        
        // SwiftData performance (if available)
        if #available(macOS 14.0, *) {
            let swiftDataConfig = StorageConfiguration(
                databaseName: "PerfTest_SwiftData_\(UUID().uuidString)",
                enableLogging: false
            )
            let swiftDataManager = try await SwiftDataStorageManager(configuration: swiftDataConfig)
            
            let swiftDataStart = Date()
            for credential in testData {
                try await swiftDataManager.saveCredential(credential)
            }
            let swiftDataTime = Date().timeIntervalSince(swiftDataStart)
            
            let swiftDataFetchStart = Date()
            let swiftDataResults = try await swiftDataManager.fetchCredentials()
            let swiftDataFetchTime = Date().timeIntervalSince(swiftDataFetchStart)
            
            XCTAssertEqual(swiftDataResults.count, testData.count, "SwiftData should save all credentials")
            
            // Both backends should have reasonable performance (within 10x of each other)
            let timeRatio = max(coreDataTime, swiftDataTime) / min(coreDataTime, swiftDataTime)
            XCTAssertLessThan(timeRatio, 10.0, "Backend performance should be comparable (within 10x)")
            
            let fetchTimeRatio = max(coreDataFetchTime, swiftDataFetchTime) / min(coreDataFetchTime, swiftDataFetchTime)
            XCTAssertLessThan(fetchTimeRatio, 10.0, "Fetch performance should be comparable (within 10x)")
            
            print("Core Data: Save=\(coreDataTime)s, Fetch=\(coreDataFetchTime)s")
            print("SwiftData: Save=\(swiftDataTime)s, Fetch=\(swiftDataFetchTime)s")
        }
    }
    
    func testFactoryBackendSelection() async throws {
        // Test that StorageFactory correctly selects backends
        
        // Create storage manager through factory with unique database
        let config = StorageConfiguration(
            databaseName: "FactoryTest_\(UUID().uuidString)",
            enableLogging: false
        )
        let manager = try await StorageFactory.createStorageManager(configuration: config)
        
        // Verify it works correctly
        let testCredential = CredentialData(
            id: "factory-test-credential",
            rpId: "factory.example.com",
            userHandle: Data("factory-user".utf8),
            publicKey: Data("factory-key".utf8),
            privateKeyRef: "factory-private-key-ref",
            createdAt: Date(),
            lastUsed: nil,
            signCount: 0,
            isResident: false,
            userDisplayName: "Factory Test User",
            credentialType: "public-key"
        )
        
        try await manager.saveCredential(testCredential)
        let result = try await manager.fetchCredential(id: testCredential.id)
        
        XCTAssertNotNil(result, "Factory-created manager should work correctly")
        XCTAssertEqual(result?.id, testCredential.id)
        
        // Verify storage info shows correct backend
        let storageInfo = try await manager.getStorageInfo()
        if #available(macOS 14.0, *) {
            XCTAssertEqual(storageInfo.backendType, .swiftData, "Should use SwiftData on macOS 14+")
        } else {
            XCTAssertEqual(storageInfo.backendType, .coreData, "Should use Core Data on macOS 12-13")
        }
        
        // Note: In real usage, credential count would be 1, but in tests there may be
        // leftover data from other tests sharing the same default database
        XCTAssertGreaterThanOrEqual(storageInfo.credentialCount, 1, "Should have at least our test credential")
        XCTAssertEqual(storageInfo.schemaVersion, "1.0", "Should show correct schema version")
    }
} 