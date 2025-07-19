// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import SwiftData

/// Mapper for converting between VirtualKeyData struct and SDVirtualKey @Model
@available(macOS 14.0, iOS 17.0, *)
internal enum VirtualKeyMapper {
    
    /// Convert from public struct to SwiftData model
    static func toSwiftData(_ virtualKey: VirtualKeyData) -> SDVirtualKey {
        return SDVirtualKey(
            id: virtualKey.id,
            name: virtualKey.name,
            encryptedPrivateKey: virtualKey.encryptedPrivateKey,
            publicKey: virtualKey.publicKey,
            algorithm: virtualKey.algorithm,
            keySize: virtualKey.keySize,
            createdAt: virtualKey.createdAt,
            lastUsed: virtualKey.lastUsed,
            isActive: virtualKey.isActive,
            kdfAlgorithm: virtualKey.keyDerivationInfo?.algorithm,
            kdfIterations: virtualKey.keyDerivationInfo?.iterations,
            kdfSalt: virtualKey.keyDerivationInfo?.salt,
            kdfKeyLength: virtualKey.keyDerivationInfo?.keyLength
        )
    }
    
    /// Convert from SwiftData model to public struct
    static func fromSwiftData(_ model: SDVirtualKey) -> VirtualKeyData {
        let keyDerivationInfo: KeyDerivationInfo?
        
        // Reconstruct KeyDerivationInfo if all required fields are present
        if let algorithm = model.kdfAlgorithm,
           let iterations = model.kdfIterations,
           let salt = model.kdfSalt,
           let keyLength = model.kdfKeyLength {
            keyDerivationInfo = KeyDerivationInfo(
                algorithm: algorithm,
                iterations: iterations,
                salt: salt,
                keyLength: keyLength
            )
        } else {
            keyDerivationInfo = nil
        }
        
        return VirtualKeyData(
            id: model.id,
            name: model.name,
            encryptedPrivateKey: model.encryptedPrivateKey,
            publicKey: model.publicKey,
            algorithm: model.algorithm,
            keySize: model.keySize,
            createdAt: model.createdAt,
            lastUsed: model.lastUsed,
            isActive: model.isActive,
            keyDerivationInfo: keyDerivationInfo
        )
    }
    
    /// Update existing SwiftData model with values from struct
    static func updateSwiftData(_ model: SDVirtualKey, with virtualKey: VirtualKeyData) {
        model.name = virtualKey.name
        model.encryptedPrivateKey = virtualKey.encryptedPrivateKey
        model.publicKey = virtualKey.publicKey
        model.algorithm = virtualKey.algorithm
        model.keySize = virtualKey.keySize
        model.createdAt = virtualKey.createdAt
        model.lastUsed = virtualKey.lastUsed
        model.isActive = virtualKey.isActive
        model.kdfAlgorithm = virtualKey.keyDerivationInfo?.algorithm
        model.kdfIterations = virtualKey.keyDerivationInfo?.iterations
        model.kdfSalt = virtualKey.keyDerivationInfo?.salt
        model.kdfKeyLength = virtualKey.keyDerivationInfo?.keyLength
    }
} 
