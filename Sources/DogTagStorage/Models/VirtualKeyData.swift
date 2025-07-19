// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation

/// Key derivation information for virtual keys
public struct KeyDerivationInfo: Codable, Equatable, Sendable {
    public let algorithm: String
    public let iterations: Int
    public let salt: Data
    public let keyLength: Int
    
    public init(algorithm: String, iterations: Int, salt: Data, keyLength: Int) {
        self.algorithm = algorithm
        self.iterations = iterations
        self.salt = salt
        self.keyLength = keyLength
    }
}

/// Public struct representing a virtual hardware key
/// Used for encrypted private key storage in virtual hardware key containers
public struct VirtualKeyData: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let encryptedPrivateKey: Data
    public let publicKey: Data
    public let algorithm: String
    public let keySize: Int
    public let createdAt: Date
    public let lastUsed: Date?
    public let isActive: Bool
    public let keyDerivationInfo: KeyDerivationInfo?
    
    /// Initialize a new virtual key
    public init(
        id: String,
        name: String,
        encryptedPrivateKey: Data,
        publicKey: Data,
        algorithm: String,
        keySize: Int,
        createdAt: Date = Date(),
        lastUsed: Date? = nil,
        isActive: Bool = true,
        keyDerivationInfo: KeyDerivationInfo? = nil
    ) {
        self.id = id
        self.name = name
        self.encryptedPrivateKey = encryptedPrivateKey
        self.publicKey = publicKey
        self.algorithm = algorithm
        self.keySize = keySize
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.isActive = isActive
        self.keyDerivationInfo = keyDerivationInfo
    }
}

// MARK: - Extensions

public extension VirtualKeyData {
    /// Create a copy with updated last used date
    func withUpdatedLastUsed(_ date: Date = Date()) -> VirtualKeyData {
        return VirtualKeyData(
            id: id,
            name: name,
            encryptedPrivateKey: encryptedPrivateKey,
            publicKey: publicKey,
            algorithm: algorithm,
            keySize: keySize,
            createdAt: createdAt,
            lastUsed: date,
            isActive: isActive,
            keyDerivationInfo: keyDerivationInfo
        )
    }
    
    /// Create a copy with updated active status
    func withActiveStatus(_ isActive: Bool) -> VirtualKeyData {
        return VirtualKeyData(
            id: id,
            name: name,
            encryptedPrivateKey: encryptedPrivateKey,
            publicKey: publicKey,
            algorithm: algorithm,
            keySize: keySize,
            createdAt: createdAt,
            lastUsed: lastUsed,
            isActive: isActive,
            keyDerivationInfo: keyDerivationInfo
        )
    }
    
    /// Create a copy with updated encrypted private key
    func withUpdatedEncryptedKey(_ newEncryptedKey: Data, keyDerivationInfo: KeyDerivationInfo? = nil) -> VirtualKeyData {
        return VirtualKeyData(
            id: id,
            name: name,
            encryptedPrivateKey: newEncryptedKey,
            publicKey: publicKey,
            algorithm: algorithm,
            keySize: keySize,
            createdAt: createdAt,
            lastUsed: lastUsed,
            isActive: isActive,
            keyDerivationInfo: keyDerivationInfo ?? self.keyDerivationInfo
        )
    }
} 
