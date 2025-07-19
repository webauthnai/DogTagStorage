// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import SwiftData

/// Mapper for converting between ServerCredentialData struct and SDServerCredential @Model
@available(macOS 14.0, iOS 17.0, *)
internal enum ServerCredentialMapper {
    
    /// Convert from public struct to SwiftData model
    static func toSwiftData(_ serverCredential: ServerCredentialData) -> SDServerCredential {
        return SDServerCredential(
            id: serverCredential.id,
            credentialId: serverCredential.credentialId,
            publicKeyJWK: serverCredential.publicKeyJWK,
            signCount: serverCredential.signCount,
            isDiscoverable: serverCredential.isDiscoverable,
            createdAt: serverCredential.createdAt,
            lastVerified: serverCredential.lastVerified,
            rpId: serverCredential.rpId,
            userHandle: serverCredential.userHandle,
            algorithm: serverCredential.algorithm,
            protocolVersion: serverCredential.protocolVersion,
            attestationFormat: serverCredential.attestationFormat,
            aaguid: serverCredential.aaguid,
            backupEligible: serverCredential.backupEligible,
            backupState: serverCredential.backupState,
            emoji: serverCredential.emoji,
            lastLoginIP: serverCredential.lastLoginIP,
            isEnabled: serverCredential.isEnabled,
            isAdmin: serverCredential.isAdmin,
            userNumber: serverCredential.userNumber
        )
    }
    
    /// Convert from SwiftData model to public struct
    static func fromSwiftData(_ model: SDServerCredential) -> ServerCredentialData {
        return ServerCredentialData(
            id: model.id,
            credentialId: model.credentialId,
            publicKeyJWK: model.publicKeyJWK,
            signCount: model.signCount,
            isDiscoverable: model.isDiscoverable,
            createdAt: model.createdAt,
            lastVerified: model.lastVerified,
            rpId: model.rpId,
            userHandle: model.userHandle,
            algorithm: model.algorithm,
            protocolVersion: model.protocolVersion,
            attestationFormat: model.attestationFormat,
            aaguid: model.aaguid,
            backupEligible: model.backupEligible,
            backupState: model.backupState,
            emoji: model.emoji,
            lastLoginIP: model.lastLoginIP,
            isEnabled: model.isEnabled,
            isAdmin: model.isAdmin,
            userNumber: model.userNumber
        )
    }
    
    /// Update existing SwiftData model with values from struct
    static func updateSwiftData(_ model: SDServerCredential, with serverCredential: ServerCredentialData) {
        model.credentialId = serverCredential.credentialId
        model.publicKeyJWK = serverCredential.publicKeyJWK
        model.signCount = serverCredential.signCount
        model.isDiscoverable = serverCredential.isDiscoverable
        model.createdAt = serverCredential.createdAt
        model.lastVerified = serverCredential.lastVerified
        model.rpId = serverCredential.rpId
        model.userHandle = serverCredential.userHandle
        model.algorithm = serverCredential.algorithm
        model.protocolVersion = serverCredential.protocolVersion
        model.attestationFormat = serverCredential.attestationFormat
        model.aaguid = serverCredential.aaguid
        model.backupEligible = serverCredential.backupEligible
        model.backupState = serverCredential.backupState
        model.emoji = serverCredential.emoji
        model.lastLoginIP = serverCredential.lastLoginIP
        model.isEnabled = serverCredential.isEnabled
        model.isAdmin = serverCredential.isAdmin
        model.userNumber = serverCredential.userNumber
    }
} 
