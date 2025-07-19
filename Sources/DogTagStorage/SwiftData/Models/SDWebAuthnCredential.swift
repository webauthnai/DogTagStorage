// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import SwiftData

/// SwiftData model for WebAuthn credentials
/// This mirrors the public CredentialData struct but with @Model annotation
@available(macOS 14.0, iOS 17.0, *)
@Model
internal final class SDWebAuthnCredential {
    @Attribute(.unique) var id: String
    var rpId: String
    var userHandle: Data
    var publicKey: Data
    var privateKeyRef: String?
    var createdAt: Date
    var lastUsed: Date?
    var signCount: Int
    var isResident: Bool
    var userDisplayName: String?
    var credentialType: String
    
    init(
        id: String,
        rpId: String,
        userHandle: Data,
        publicKey: Data,
        privateKeyRef: String? = nil,
        createdAt: Date = Date(),
        lastUsed: Date? = nil,
        signCount: Int = 0,
        isResident: Bool = false,
        userDisplayName: String? = nil,
        credentialType: String = "public-key"
    ) {
        self.id = id
        self.rpId = rpId
        self.userHandle = userHandle
        self.publicKey = publicKey
        self.privateKeyRef = privateKeyRef
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.signCount = signCount
        self.isResident = isResident
        self.userDisplayName = userDisplayName
        self.credentialType = credentialType
    }
} 
