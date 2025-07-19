// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import CoreData

/// Mapper for converting between Core Data server credentials and value types
internal struct CDServerCredentialMapper {
    
    /// Convert Core Data server credential to value type
    static func toServerCredentialData(_ cdCredential: CDServerCredential) -> ServerCredentialData {
        return ServerCredentialData(
            id: cdCredential.id,
            credentialId: cdCredential.credentialId,
            publicKeyJWK: cdCredential.publicKeyJWK,
            signCount: Int(cdCredential.signCount),
            isDiscoverable: cdCredential.isDiscoverable,
            createdAt: cdCredential.createdAt,
            lastVerified: cdCredential.lastVerified,
            rpId: cdCredential.rpId,
            userHandle: cdCredential.userHandle,
            algorithm: Int(cdCredential.algorithm),
            protocolVersion: cdCredential.protocolVersion,
            attestationFormat: cdCredential.attestationFormat,
            aaguid: cdCredential.aaguid,
            backupEligible: cdCredential.backupEligible,
            backupState: cdCredential.backupState,
            emoji: cdCredential.emoji,
            lastLoginIP: cdCredential.lastLoginIP,
            isEnabled: cdCredential.isEnabled,
            isAdmin: cdCredential.isAdmin,
            userNumber: cdCredential.userNumber == 0 ? nil : Int(cdCredential.userNumber)
        )
    }
    
    /// Create Core Data server credential from value type
    static func fromServerCredentialData(_ credentialData: ServerCredentialData, context: NSManagedObjectContext) -> CDServerCredential {
        return CDServerCredential(
            context: context,
            id: credentialData.id,
            credentialId: credentialData.credentialId,
            publicKeyJWK: credentialData.publicKeyJWK,
            signCount: credentialData.signCount,
            isDiscoverable: credentialData.isDiscoverable,
            createdAt: credentialData.createdAt,
            lastVerified: credentialData.lastVerified,
            rpId: credentialData.rpId,
            userHandle: credentialData.userHandle,
            algorithm: credentialData.algorithm,
            protocolVersion: credentialData.protocolVersion,
            attestationFormat: credentialData.attestationFormat,
            aaguid: credentialData.aaguid,
            backupEligible: credentialData.backupEligible,
            backupState: credentialData.backupState,
            emoji: credentialData.emoji,
            lastLoginIP: credentialData.lastLoginIP,
            isEnabled: credentialData.isEnabled,
            isAdmin: credentialData.isAdmin,
            userNumber: credentialData.userNumber
        )
    }
    
    /// Update existing Core Data server credential from value type
    static func updateCDServerCredential(_ cdCredential: CDServerCredential, with credentialData: ServerCredentialData) {
        cdCredential.credentialId = credentialData.credentialId
        cdCredential.publicKeyJWK = credentialData.publicKeyJWK
        cdCredential.signCount = Int32(credentialData.signCount)
        cdCredential.isDiscoverable = credentialData.isDiscoverable
        cdCredential.lastVerified = credentialData.lastVerified
        cdCredential.rpId = credentialData.rpId
        cdCredential.userHandle = credentialData.userHandle
        cdCredential.algorithm = Int32(credentialData.algorithm)
        cdCredential.protocolVersion = credentialData.protocolVersion
        cdCredential.attestationFormat = credentialData.attestationFormat
        cdCredential.aaguid = credentialData.aaguid
        cdCredential.backupEligible = credentialData.backupEligible ?? false
        cdCredential.backupState = credentialData.backupState ?? false
        cdCredential.emoji = credentialData.emoji
        cdCredential.lastLoginIP = credentialData.lastLoginIP
        cdCredential.isEnabled = credentialData.isEnabled
        cdCredential.isAdmin = credentialData.isAdmin
        cdCredential.userNumber = Int32(credentialData.userNumber ?? 0)
    }
    
    /// Convert array of Core Data server credentials to value types
    static func toServerCredentialDataArray(_ cdCredentials: [CDServerCredential]) -> [ServerCredentialData] {
        return cdCredentials.map { toServerCredentialData($0) }
    }
} 
