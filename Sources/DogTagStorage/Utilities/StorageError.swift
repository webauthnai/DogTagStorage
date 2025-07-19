// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation

/// Errors that can occur during storage operations
public enum StorageError: Error, LocalizedError, Sendable {
    case configurationError(String)
    case connectionError(String)
    case dataCorruption(String)
    case migrationFailed(String)
    case schemaValidationFailed([String])
    case operationFailed(operation: String, reason: String)
    case notFound(String)
    case duplicateKey(String)
    case invalidData(String)
    case unsupportedOperation(String)
    
    public var errorDescription: String? {
        switch self {
        case .configurationError(let message):
            return "Storage configuration error: \(message)"
        case .connectionError(let message):
            return "Storage connection error: \(message)"
        case .dataCorruption(let message):
            return "Data corruption detected: \(message)"
        case .migrationFailed(let message):
            return "Migration failed: \(message)"
        case .schemaValidationFailed(let issues):
            return "Schema validation failed: \(issues.joined(separator: ", "))"
        case .operationFailed(let operation, let reason):
            return "Operation '\(operation)' failed: \(reason)"
        case .notFound(let resource):
            return "Resource not found: \(resource)"
        case .duplicateKey(let key):
            return "Duplicate key error: \(key)"
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        case .unsupportedOperation(let operation):
            return "Unsupported operation: \(operation)"
        }
    }
    
    public var failureReason: String? {
        return errorDescription
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .configurationError:
            return "Check storage configuration settings and ensure they are valid."
        case .connectionError:
            return "Verify database files exist and are accessible."
        case .dataCorruption:
            return "Try running schema validation or consider restoring from backup."
        case .migrationFailed:
            return "Review migration logs and ensure source data is valid."
        case .schemaValidationFailed:
            return "Update to compatible schema version or run migration."
        case .operationFailed:
            return "Retry the operation or check logs for more details."
        case .notFound:
            return "Ensure the resource exists before attempting to access it."
        case .duplicateKey:
            return "Use a unique identifier or update the existing record."
        case .invalidData:
            return "Validate input data format and content."
        case .unsupportedOperation:
            return "Use a supported operation for this storage backend."
        }
    }
}

/// Configuration for storage backends
public struct StorageConfiguration: Sendable {
    public let databaseName: String
    public let enableLogging: Bool
    public let enableCloudSync: Bool
    public let customDatabasePath: String?
    public let schemaVersion: String
    public let maxRetryAttempts: Int
    public let timeoutInterval: TimeInterval
    
    /// Default configuration
    public static let `default` = StorageConfiguration(
        databaseName: "WebManStorage",
        enableLogging: false,
        enableCloudSync: false,
        customDatabasePath: nil,
        schemaVersion: "1.0",
        maxRetryAttempts: 3,
        timeoutInterval: 30.0
    )
    
    /// Test configuration for unit tests
    public static let test = StorageConfiguration(
        databaseName: "WebManStorageTest",
        enableLogging: true,
        enableCloudSync: false,
        customDatabasePath: nil,
        schemaVersion: "1.0",
        maxRetryAttempts: 1,
        timeoutInterval: 5.0
    )
    
    public init(
        databaseName: String,
        enableLogging: Bool = false,
        enableCloudSync: Bool = false,
        customDatabasePath: String? = nil,
        schemaVersion: String = "1.0",
        maxRetryAttempts: Int = 3,
        timeoutInterval: TimeInterval = 30.0
    ) {
        self.databaseName = databaseName
        self.enableLogging = enableLogging
        self.enableCloudSync = enableCloudSync
        self.customDatabasePath = customDatabasePath
        self.schemaVersion = schemaVersion
        self.maxRetryAttempts = maxRetryAttempts
        self.timeoutInterval = timeoutInterval
    }
} 
