// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation

// MARK: - Public API Exports

// Re-export all public types so consumers can import DogTagStorage and get everything
// The actual implementations are in separate files within this module

/// DogTagStorage - A unified storage abstraction layer
/// 
/// This package provides automatic backend selection between SwiftData (macOS 14+)
/// and Core Data (macOS 12-13) while maintaining complete forward and backward 
/// compatibility. All consuming code works with value-type structs, completely
/// abstracted from the underlying storage implementation.
///
/// ## Key Features:
/// - **Zero Breaking Changes**: Existing code only changes imports
/// - **Automatic Backend Selection**: Runtime OS detection
/// - **Schema Compatibility**: Identical SQLite database structure
/// - **Future Proof**: Easy to add CloudKit, remote storage, etc.
/// - **Testable**: Complete abstraction enables easy mocking
/// - **Type Safe**: Compile-time checking with structs
/// - **Performance**: No overhead, direct storage access
///
/// ## Basic Usage:
/// ```swift
/// import DogTagStorage
///
/// // Automatically selects SwiftData on macOS 14+ or Core Data on macOS 12-13
/// let storage = await StorageFactory.createStorageManager()
///
/// // Save a credential
/// let credential = CredentialData(
///     id: UUID().uuidString,
///     rpId: "example.com",
///     userHandle: Data(),
///     publicKey: Data()
/// )
/// try await storage.saveCredential(credential)
///
/// // Fetch credentials
/// let credentials = try await storage.fetchCredentials(for: "example.com")
/// ```
///
/// ## Testing:
/// ```swift
/// // Use mock storage for testing
/// let mockStorage = StorageFactory.createMockStorageManager()
/// ```
public enum DogTagStorage {
    /// Current version of the DogTagStorage package
    public static let version = "1.0.0"
    
    /// Check which storage backend would be selected on the current platform
    public static var availableBackend: StorageBackendType {
        return StorageFactory.getAvailableBackendType()
    }
    
    /// Check if SwiftData is available on the current platform
    public static var isSwiftDataAvailable: Bool {
        return StorageFactory.isSwiftDataAvailable()
    }
} 
