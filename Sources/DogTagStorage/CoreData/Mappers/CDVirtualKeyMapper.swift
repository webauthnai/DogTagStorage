// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import CoreData

/// Mapper for converting between Core Data virtual keys and value types
internal struct CDVirtualKeyMapper {
    
    /// Convert Core Data virtual key to value type
    static func toVirtualKeyData(_ cdVirtualKey: CDVirtualKey) -> VirtualKeyData {
        // Create KeyDerivationInfo if KDF data is present
        let kdfInfo: KeyDerivationInfo?
        if let kdfAlgorithm = cdVirtualKey.kdfAlgorithm,
           let kdfSalt = cdVirtualKey.kdfSalt,
           cdVirtualKey.kdfIterations > 0,
           cdVirtualKey.kdfKeyLength > 0 {
            kdfInfo = KeyDerivationInfo(
                algorithm: kdfAlgorithm,
                iterations: Int(cdVirtualKey.kdfIterations),
                salt: kdfSalt,
                keyLength: Int(cdVirtualKey.kdfKeyLength)
            )
        } else {
            kdfInfo = nil
        }
        
        return VirtualKeyData(
            id: cdVirtualKey.id,
            name: cdVirtualKey.name,
            encryptedPrivateKey: cdVirtualKey.encryptedPrivateKey,
            publicKey: cdVirtualKey.publicKey,
            algorithm: cdVirtualKey.algorithm,
            keySize: Int(cdVirtualKey.keySize),
            createdAt: cdVirtualKey.createdAt,
            lastUsed: cdVirtualKey.lastUsed,
            isActive: cdVirtualKey.isActive,
            keyDerivationInfo: kdfInfo
        )
    }
    
    /// Create Core Data virtual key from value type
    static func fromVirtualKeyData(_ keyData: VirtualKeyData, context: NSManagedObjectContext) -> CDVirtualKey {
        return CDVirtualKey(
            context: context,
            id: keyData.id,
            name: keyData.name,
            encryptedPrivateKey: keyData.encryptedPrivateKey,
            publicKey: keyData.publicKey,
            algorithm: keyData.algorithm,
            keySize: keyData.keySize,
            createdAt: keyData.createdAt,
            lastUsed: keyData.lastUsed,
            isActive: keyData.isActive,
            kdfAlgorithm: keyData.keyDerivationInfo?.algorithm,
            kdfIterations: keyData.keyDerivationInfo?.iterations ?? 0,
            kdfSalt: keyData.keyDerivationInfo?.salt,
            kdfKeyLength: keyData.keyDerivationInfo?.keyLength ?? 0
        )
    }
    
    /// Update existing Core Data virtual key from value type
    static func updateVirtualKey(_ cdVirtualKey: CDVirtualKey, from keyData: VirtualKeyData) {
        cdVirtualKey.id = keyData.id
        cdVirtualKey.name = keyData.name
        cdVirtualKey.encryptedPrivateKey = keyData.encryptedPrivateKey
        cdVirtualKey.publicKey = keyData.publicKey
        cdVirtualKey.algorithm = keyData.algorithm
        cdVirtualKey.keySize = Int32(keyData.keySize)
        cdVirtualKey.createdAt = keyData.createdAt
        cdVirtualKey.lastUsed = keyData.lastUsed
        cdVirtualKey.isActive = keyData.isActive
        cdVirtualKey.kdfAlgorithm = keyData.keyDerivationInfo?.algorithm
        cdVirtualKey.kdfIterations = Int32(keyData.keyDerivationInfo?.iterations ?? 0)
        cdVirtualKey.kdfSalt = keyData.keyDerivationInfo?.salt
        cdVirtualKey.kdfKeyLength = Int32(keyData.keyDerivationInfo?.keyLength ?? 0)
    }
    
    /// Convert array of Core Data virtual keys to value types
    static func toVirtualKeyDataArray(_ cdVirtualKeys: [CDVirtualKey]) -> [VirtualKeyData] {
        return cdVirtualKeys.map { toVirtualKeyData($0) }
    }
} 
