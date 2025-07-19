// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import CoreData

/// Mapper for converting between Core Data WebAuthn credentials and value types
internal struct CDCredentialMapper {
    
    /// Convert Core Data credential to value type
    static func toCredentialData(_ cdCredential: CDWebAuthnCredential) -> CredentialData {
        return CredentialData(
            id: cdCredential.id,
            rpId: cdCredential.rpId,
            userHandle: cdCredential.userHandle,
            publicKey: cdCredential.publicKey,
            privateKeyRef: cdCredential.privateKeyRef,
            createdAt: cdCredential.createdAt,
            lastUsed: cdCredential.lastUsed,
            signCount: Int(cdCredential.signCount),
            isResident: cdCredential.isResident,
            userDisplayName: cdCredential.userDisplayName,
            credentialType: cdCredential.credentialType
        )
    }
    
    /// Create Core Data credential from value type
    static func fromCredentialData(_ credentialData: CredentialData, context: NSManagedObjectContext) -> CDWebAuthnCredential {
        return CDWebAuthnCredential(
            context: context,
            id: credentialData.id,
            rpId: credentialData.rpId,
            userHandle: credentialData.userHandle,  
            publicKey: credentialData.publicKey,
            privateKeyRef: credentialData.privateKeyRef,
            createdAt: credentialData.createdAt,
            lastUsed: credentialData.lastUsed,
            signCount: credentialData.signCount,
            isResident: credentialData.isResident,
            userDisplayName: credentialData.userDisplayName,
            credentialType: credentialData.credentialType
        )
    }
    
    /// Update existing Core Data credential from value type
    static func updateCredential(_ cdCredential: CDWebAuthnCredential, from credentialData: CredentialData) {
        cdCredential.id = credentialData.id
        cdCredential.rpId = credentialData.rpId
        cdCredential.userHandle = credentialData.userHandle
        cdCredential.publicKey = credentialData.publicKey
        cdCredential.privateKeyRef = credentialData.privateKeyRef
        cdCredential.createdAt = credentialData.createdAt
        cdCredential.lastUsed = credentialData.lastUsed
        cdCredential.signCount = Int32(credentialData.signCount)
        cdCredential.isResident = credentialData.isResident
        cdCredential.userDisplayName = credentialData.userDisplayName
        cdCredential.credentialType = credentialData.credentialType
    }
    
    /// Convert array of Core Data credentials to value types
    static func toCredentialDataArray(_ cdCredentials: [CDWebAuthnCredential]) -> [CredentialData] {
        return cdCredentials.map { toCredentialData($0) }
    }
} 
