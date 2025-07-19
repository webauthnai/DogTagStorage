// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation

/// Public struct representing a WebAuthn client credential
/// This replaces the SwiftData @Model WebAuthnClientCredential class
public struct CredentialData: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let rpId: String
    public let userHandle: Data
    public let publicKey: Data
    public let privateKeyRef: String?
    public let createdAt: Date
    public let lastUsed: Date?
    public let signCount: Int
    public let isResident: Bool
    public let userDisplayName: String?
    public let credentialType: String
    
    /// Initialize a new credential
    public init(
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

// MARK: - Extensions

public extension CredentialData {
    /// Create a copy with updated sign count
    func withUpdatedSignCount(_ newCount: Int) -> CredentialData {
        return CredentialData(
            id: id,
            rpId: rpId,
            userHandle: userHandle,
            publicKey: publicKey,
            privateKeyRef: privateKeyRef,
            createdAt: createdAt,
            lastUsed: Date(),
            signCount: newCount,
            isResident: isResident,
            userDisplayName: userDisplayName,
            credentialType: credentialType
        )
    }
    
    /// Create a copy with updated last used date
    func withUpdatedLastUsed(_ date: Date = Date()) -> CredentialData {
        return CredentialData(
            id: id,
            rpId: rpId,
            userHandle: userHandle,
            publicKey: publicKey,
            privateKeyRef: privateKeyRef,
            createdAt: createdAt,
            lastUsed: date,
            signCount: signCount,
            isResident: isResident,
            userDisplayName: userDisplayName,
            credentialType: credentialType
        )
    }
} 
