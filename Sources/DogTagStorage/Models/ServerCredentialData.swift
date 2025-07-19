// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation

/// Public struct representing server-side credential metadata
/// Used for storing credential information on the server side
public struct ServerCredentialData: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let credentialId: String
    public let publicKeyJWK: String
    public let signCount: Int
    public let isDiscoverable: Bool
    public let createdAt: Date
    public let lastVerified: Date?
    public let rpId: String
    public let userHandle: Data
    
    // Additional fields to preserve 100% of WebAuthnCredential data
    public let algorithm: Int
    public let protocolVersion: String
    public let attestationFormat: String?
    public let aaguid: String?
    public let backupEligible: Bool?
    public let backupState: Bool?
    public let emoji: String
    public let lastLoginIP: String?
    public let isEnabled: Bool
    public let isAdmin: Bool
    public let userNumber: Int?
    
    /// Initialize a new server credential
    public init(
        id: String,
        credentialId: String,
        publicKeyJWK: String,
        signCount: Int = 0,
        isDiscoverable: Bool = false,
        createdAt: Date = Date(),
        lastVerified: Date? = nil,
        rpId: String,
        userHandle: Data,
        algorithm: Int = -7,
        protocolVersion: String = "fido2",
        attestationFormat: String? = nil,
        aaguid: String? = nil,
        backupEligible: Bool? = nil,
        backupState: Bool? = nil,
        emoji: String = "🔑",
        lastLoginIP: String? = nil,
        isEnabled: Bool = true,
        isAdmin: Bool = false,
        userNumber: Int? = nil
    ) {
        self.id = id
        self.credentialId = credentialId
        self.publicKeyJWK = publicKeyJWK
        self.signCount = signCount
        self.isDiscoverable = isDiscoverable
        self.createdAt = createdAt
        self.lastVerified = lastVerified
        self.rpId = rpId
        self.userHandle = userHandle
        self.algorithm = algorithm
        self.protocolVersion = protocolVersion
        self.attestationFormat = attestationFormat
        self.aaguid = aaguid
        self.backupEligible = backupEligible
        self.backupState = backupState
        self.emoji = emoji
        self.lastLoginIP = lastLoginIP
        self.isEnabled = isEnabled
        self.isAdmin = isAdmin
        self.userNumber = userNumber
    }
}

// MARK: - Extensions

public extension ServerCredentialData {
    /// Create a copy with updated sign count
    func withUpdatedSignCount(_ newCount: Int) -> ServerCredentialData {
        return ServerCredentialData(
            id: id,
            credentialId: credentialId,
            publicKeyJWK: publicKeyJWK,
            signCount: newCount,
            isDiscoverable: isDiscoverable,
            createdAt: createdAt,
            lastVerified: Date(),
            rpId: rpId,
            userHandle: userHandle,
            algorithm: algorithm,
            protocolVersion: protocolVersion,
            attestationFormat: attestationFormat,
            aaguid: aaguid,
            backupEligible: backupEligible,
            backupState: backupState,
            emoji: emoji,
            lastLoginIP: lastLoginIP,
            isEnabled: isEnabled,
            isAdmin: isAdmin,
            userNumber: userNumber
        )
    }
    
    /// Create a copy with updated verification date
    func withUpdatedVerification(_ date: Date = Date()) -> ServerCredentialData {
        return ServerCredentialData(
            id: id,
            credentialId: credentialId,
            publicKeyJWK: publicKeyJWK,
            signCount: signCount,
            isDiscoverable: isDiscoverable,
            createdAt: createdAt,
            lastVerified: date,
            rpId: rpId,
            userHandle: userHandle,
            algorithm: algorithm,
            protocolVersion: protocolVersion,
            attestationFormat: attestationFormat,
            aaguid: aaguid,
            backupEligible: backupEligible,
            backupState: backupState,
            emoji: emoji,
            lastLoginIP: lastLoginIP,
            isEnabled: isEnabled,
            isAdmin: isAdmin,
            userNumber: userNumber
        )
    }
} 
