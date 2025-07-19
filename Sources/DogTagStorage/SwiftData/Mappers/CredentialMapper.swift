// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import SwiftData

/// Mapper for converting between CredentialData struct and SDWebAuthnCredential @Model
@available(macOS 14.0, iOS 17.0, *)
internal enum CredentialMapper {
    
    /// Convert from public struct to SwiftData model
    static func toSwiftData(_ credential: CredentialData) -> SDWebAuthnCredential {
        return SDWebAuthnCredential(
            id: credential.id,
            rpId: credential.rpId,
            userHandle: credential.userHandle,
            publicKey: credential.publicKey,
            privateKeyRef: credential.privateKeyRef,
            createdAt: credential.createdAt,
            lastUsed: credential.lastUsed,
            signCount: credential.signCount,
            isResident: credential.isResident,
            userDisplayName: credential.userDisplayName,
            credentialType: credential.credentialType
        )
    }
    
    /// Convert from SwiftData model to public struct
    static func fromSwiftData(_ model: SDWebAuthnCredential) -> CredentialData {
        return CredentialData(
            id: model.id,
            rpId: model.rpId,
            userHandle: model.userHandle,
            publicKey: model.publicKey,
            privateKeyRef: model.privateKeyRef,
            createdAt: model.createdAt,
            lastUsed: model.lastUsed,
            signCount: model.signCount,
            isResident: model.isResident,
            userDisplayName: model.userDisplayName,
            credentialType: model.credentialType
        )
    }
    
    /// Update existing SwiftData model with values from struct
    static func updateSwiftData(_ model: SDWebAuthnCredential, with credential: CredentialData) {
        model.rpId = credential.rpId
        model.userHandle = credential.userHandle
        model.publicKey = credential.publicKey
        model.privateKeyRef = credential.privateKeyRef
        model.createdAt = credential.createdAt
        model.lastUsed = credential.lastUsed
        model.signCount = credential.signCount
        model.isResident = credential.isResident
        model.userDisplayName = credential.userDisplayName
        model.credentialType = credential.credentialType
    }
} 
