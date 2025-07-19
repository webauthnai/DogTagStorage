// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import SwiftData

/// SwiftData model for virtual keys
/// This mirrors the public VirtualKeyData struct but with @Model annotation
@available(macOS 14.0, iOS 17.0, *)
@Model
internal final class SDVirtualKey {
    @Attribute(.unique) var id: String
    var name: String
    var encryptedPrivateKey: Data
    var publicKey: Data
    var algorithm: String
    var keySize: Int
    var createdAt: Date
    var lastUsed: Date?
    var isActive: Bool
    
    // Key derivation information stored as separate properties
    var kdfAlgorithm: String?
    var kdfIterations: Int?
    var kdfSalt: Data?
    var kdfKeyLength: Int?
    
    init(
        id: String,
        name: String,
        encryptedPrivateKey: Data,
        publicKey: Data,
        algorithm: String,
        keySize: Int,
        createdAt: Date = Date(),
        lastUsed: Date? = nil,
        isActive: Bool = true,
        kdfAlgorithm: String? = nil,
        kdfIterations: Int? = nil,
        kdfSalt: Data? = nil,
        kdfKeyLength: Int? = nil
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
        self.kdfAlgorithm = kdfAlgorithm
        self.kdfIterations = kdfIterations
        self.kdfSalt = kdfSalt
        self.kdfKeyLength = kdfKeyLength
    }
} 
