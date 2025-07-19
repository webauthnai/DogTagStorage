# 🐶🪪 DogTagStorage

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%2012%2B%20%7C%20iOS%2015%2B-blue.svg)](https://developer.apple.com/swift/)
[![SwiftData](https://img.shields.io/badge/SwiftData-macOS%2014%2B-green.svg)](https://developer.apple.com/documentation/swiftdata/)
[![CoreData](https://img.shields.io/badge/CoreData-macOS%2012%2B-yellow.svg)](https://developer.apple.com/documentation/coredata/)

**DogTagStorage** is a unified storage abstraction layer for WebAuthn/FIDO2 credential management with automatic backend selection between SwiftData and Core Data. It provides a type-safe, actor-based API that works seamlessly across different macOS versions while maintaining complete forward and backward compatibility.

## ✨ Features

- **🔄 Automatic Backend Selection** - SwiftData on macOS 14+ / iOS 17+, Core Data on older versions
- **🔒 WebAuthn/FIDO2 Ready** - Purpose-built for credential, server credential, and virtual key storage
- **⚡ Actor-Based API** - Fully async/await with actor isolation for thread safety
- **🛡️ Type Safety** - All data models are value types (structs) with compile-time checking
- **🧪 Testing Support** - Built-in mock storage manager for unit tests
- **📊 Schema Validation** - Automatic schema validation and migration support
- **🚫 Zero Dependencies** - Uses only Foundation, SwiftData, and Core Data
- **📱 Cross-Platform** - Works on macOS 12+ and iOS 15+ (future support)

## 🚀 Installation

### Swift Package Manager

Add DogTagStorage to your project using Xcode or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/DogTagStorage.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["DogTagStorage"]
)
```

## 📖 Quick Start

### Basic Usage

```swift
import DogTagStorage

// Automatically selects the best storage backend for your OS
let storage = try await StorageFactory.createStorageManager()

// Create and save a WebAuthn credential
let credential = CredentialData(
    id: UUID().uuidString,
    rpId: "example.com",
    userHandle: Data("user123".utf8),
    publicKey: Data(/* your public key data */)
)

try await storage.saveCredential(credential)

// Fetch credentials for a specific relying party
let credentials = try await storage.fetchCredentials(for: "example.com")
print("Found \(credentials.count) credentials")
```

### Advanced Configuration

```swift
// Custom storage configuration
let config = StorageConfiguration(
    databaseName: "MyAppStorage",
    enableLogging: true,
    enableCloudSync: false,
    schemaVersion: "1.0"
)

let storage = try await StorageFactory.createStorageManager(configuration: config)
```

## 📚 API Documentation

### Storage Manager

The `StorageManager` protocol provides the main interface for all storage operations:

#### Credential Operations

```swift
// Save a credential
try await storage.saveCredential(credential)

// Fetch all credentials
let allCredentials = try await storage.fetchCredentials()

// Fetch specific credential by ID
let credential = try await storage.fetchCredential(id: "credential-id")

// Fetch credentials for a relying party
let rpCredentials = try await storage.fetchCredentials(for: "example.com")

// Update credential
try await storage.updateCredential(updatedCredential)

// Update just the sign count (optimized)
try await storage.updateSignCount(credentialId: "id", newCount: 42)

// Delete credential
try await storage.deleteCredential(id: "credential-id")
```

#### Server Credential Operations

```swift
// Server-side credential metadata
let serverCredential = ServerCredentialData(
    id: UUID().uuidString,
    credentialId: "client-credential-id",
    publicKeyJWK: jwkString,
    rpId: "example.com",
    userHandle: userData,
    algorithm: -7, // ES256
    emoji: "🔐"
)

try await storage.saveServerCredential(serverCredential)
let serverCredentials = try await storage.fetchServerCredentials()
```

#### Virtual Key Operations

```swift
// Virtual hardware key containers
let virtualKey = VirtualKeyData(
    id: UUID().uuidString,
    name: "My Virtual Key",
    encryptedPrivateKey: encryptedKeyData,
    publicKey: publicKeyData,
    algorithm: "RSA",
    keySize: 2048
)

try await storage.saveVirtualKey(virtualKey)
let activeKeys = try await storage.fetchActiveVirtualKeys()
```

### Data Models

#### CredentialData

Represents a WebAuthn client credential:

```swift
public struct CredentialData: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let rpId: String
    public let userHandle: Data
    public let publicKey: Data
    public let privateKeyRef: String?
    public let createdAt: Date
    public let lastUsed: Date?
    public let signCount: Int
    public let isResident: Bool
    public let userDisplayName: String?
    public let credentialType: String
}
```

**Helper Methods:**
```swift
// Update sign count
let updatedCredential = credential.withUpdatedSignCount(newCount)

// Update last used timestamp
let recentCredential = credential.withUpdatedLastUsed()
```

#### ServerCredentialData

Server-side credential metadata with additional WebAuthn properties:

```swift
public struct ServerCredentialData: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let credentialId: String
    public let publicKeyJWK: String
    public let signCount: Int
    public let isDiscoverable: Bool
    public let rpId: String
    public let userHandle: Data
    public let algorithm: Int
    public let emoji: String
    public let isEnabled: Bool
    // ... additional properties
}
```

#### VirtualKeyData

Virtual hardware key with encrypted private key storage:

```swift
public struct VirtualKeyData: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let encryptedPrivateKey: Data
    public let publicKey: Data
    public let algorithm: String
    public let keySize: Int
    public let isActive: Bool
    public let keyDerivationInfo: KeyDerivationInfo?
}
```

## 🔧 Configuration

### StorageConfiguration

Customize storage behavior with `StorageConfiguration`:

```swift
let config = StorageConfiguration(
    databaseName: "MyDatabase",
    enableLogging: true,
    enableCloudSync: false,
    customDatabasePath: "/custom/path",
    schemaVersion: "1.1",
    maxRetryAttempts: 5,
    timeoutInterval: 60.0
)
```

### Backend Selection

```swift
// Check which backend will be used
let backendType = StorageFactory.getAvailableBackendType()
print("Using backend: \(backendType)") // .swiftData or .coreData

// Check SwiftData availability
if StorageFactory.isSwiftDataAvailable() {
    print("SwiftData is available on this OS version")
}

// Force specific backend (for testing)
let swiftDataStorage = try await StorageFactory.createStorageManager(
    backendType: .swiftData,
    configuration: config
)
```

## 🧪 Testing

DogTagStorage provides a built-in mock storage manager for testing:

```swift
import XCTest
@testable import DogTagStorage

class MyTests: XCTestCase {
    func testCredentialStorage() async throws {
        // Use mock storage for testing
        let storage = StorageFactory.createMockStorageManager()
        
        let credential = CredentialData(
            id: "test-id",
            rpId: "test.com",
            userHandle: Data("user".utf8),
            publicKey: Data("key".utf8)
        )
        
        try await storage.saveCredential(credential)
        let fetched = try await storage.fetchCredential(id: "test-id")
        
        XCTAssertEqual(fetched?.id, "test-id")
    }
}
```

### Test Configuration

Use the pre-configured test settings:

```swift
let testStorage = try await StorageFactory.createStorageManager(
    configuration: .test
)
```

## 🏥 Diagnostics & Maintenance

### Storage Information

```swift
let info = try await storage.getStorageInfo()
print("Backend: \(info.backendType)")
print("Database path: \(info.databasePath)")
print("Database size: \(info.databaseSize) bytes")
print("Credentials: \(info.credentialCount)")
print("Schema version: \(info.schemaVersion)")
```

### Schema Validation

```swift
let validation = try await storage.validateSchema()
if !validation.isValid {
    print("Schema issues: \(validation.issues)")
    print("Recommended actions: \(validation.recommendedActions)")
}
```

### Bulk Operations

```swift
// Clear all data (use with caution!)
try await storage.deleteAllCredentials()
try await storage.deleteAllServerCredentials()  
try await storage.deleteAllVirtualKeys()
```

## ⚠️ Error Handling

DogTagStorage provides comprehensive error handling with `StorageError`:

```swift
do {
    try await storage.saveCredential(credential)
} catch StorageError.duplicateKey(let key) {
    print("Credential with key '\(key)' already exists")
} catch StorageError.configurationError(let message) {
    print("Configuration issue: \(message)")
} catch StorageError.dataCorruption(let message) {
    print("Data corruption detected: \(message)")
    // Consider schema validation or backup restoration
} catch {
    print("Unexpected error: \(error)")
}
```

### Error Types

- `configurationError` - Storage setup issues
- `connectionError` - Database connection problems  
- `dataCorruption` - Data integrity issues
- `migrationFailed` - Schema migration problems
- `operationFailed` - General operation failures
- `notFound` - Resource doesn't exist
- `duplicateKey` - Unique constraint violation
- `invalidData` - Data format/validation errors
- `unsupportedOperation` - Backend doesn't support operation

## 🎯 Use Cases

### WebAuthn Authenticator

```swift
class WebAuthnAuthenticator {
    private let storage = try await StorageFactory.createStorageManager()
    
    func createCredential(rpId: String, userHandle: Data, publicKey: Data) async throws {
        let credential = CredentialData(
            id: UUID().uuidString,
            rpId: rpId,
            userHandle: userHandle,
            publicKey: publicKey,
            isResident: true,
            credentialType: "public-key"
        )
        
        try await storage.saveCredential(credential)
    }
    
    func authenticate(rpId: String, credentialId: String) async throws -> CredentialData? {
        guard let credential = try await storage.fetchCredential(id: credentialId) else {
            return nil
        }
        
        // Update sign count and last used
        let updated = credential
            .withUpdatedSignCount(credential.signCount + 1)
            .withUpdatedLastUsed()
        
        try await storage.updateCredential(updated)
        return updated
    }
}
```

### Virtual Hardware Security Module

```swift
class VirtualHSM {
    private let storage = try await StorageFactory.createStorageManager()
    
    func createVirtualKey(name: String, keyData: Data) async throws -> String {
        let keyId = UUID().uuidString
        
        let virtualKey = VirtualKeyData(
            id: keyId,
            name: name,
            encryptedPrivateKey: keyData,
            publicKey: extractPublicKey(from: keyData),
            algorithm: "RSA",
            keySize: 2048,
            isActive: true
        )
        
        try await storage.saveVirtualKey(virtualKey)
        return keyId
    }
    
    func listActiveKeys() async throws -> [VirtualKeyData] {
        return try await storage.fetchActiveVirtualKeys()
    }
}
```

## 🏗️ Architecture

DogTagStorage uses a layered architecture:

```
┌─────────────────────────────────────────┐
│           Public API Layer              │
│  (StorageFactory, StorageManager)       │
├─────────────────────────────────────────┤
│          Data Model Layer               │
│  (CredentialData, ServerCredentialData) │
├─────────────────────────────────────────┤
│         Storage Abstraction             │
│     (Backend Selection Logic)           │
├─────────────────────────────────────────┤
│        Implementation Layer             │
│   SwiftDataStorageManager │ CoreData... │
└─────────────────────────────────────────┘
```

## 🔮 Roadmap

- ✅ SwiftData backend (macOS 14+)
- 🚧 Core Data backend (macOS 12-13 YMMV)
- 📋 CloudKit integration
- 📋 iOS support
- 📋 Encryption at rest
- 📋 Remote storage backends
- 📋 Migration utilities

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines for more details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Support

- 📖 [Documentation](https://github.com/your-org/DogTagStorage/docs)
- 🐛 [Issue Tracker](https://github.com/your-org/DogTagStorage/issues)
- 💬 [Discussions](https://github.com/your-org/DogTagStorage/discussions)

---

**Made with ❤️ by FIDO3.ai** 
