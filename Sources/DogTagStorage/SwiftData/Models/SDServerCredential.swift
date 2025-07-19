// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import SwiftData

/// SwiftData model for server credentials
/// This mirrors the public ServerCredentialData struct but with @Model annotation
@available(macOS 14.0, iOS 17.0, *)
@Model
internal final class SDServerCredential {
    @Attribute(.unique) var id: String
    @Attribute(.unique) var credentialId: String
    var publicKeyJWK: String
    var signCount: Int
    var isDiscoverable: Bool
    var createdAt: Date
    var lastVerified: Date?
    var rpId: String
    var userHandle: Data
    
    // Additional fields to preserve 100% of WebAuthnCredential data
    var algorithm: Int
    var protocolVersion: String
    var attestationFormat: String?
    var aaguid: String?
    var backupEligible: Bool?
    var backupState: Bool?
    var emoji: String
    var lastLoginIP: String?
    var isEnabled: Bool
    var isAdmin: Bool
    var userNumber: Int?
    
    init(
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
