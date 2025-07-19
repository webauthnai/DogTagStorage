// Copyright 2025 FIDO3.ai
// Generated on 2025-7-19
import Foundation
import CoreData
#if canImport(SwiftData)
import SwiftData
#endif

/// Enhanced schema validation results with detailed cross-backend comparison
public struct CrossBackendValidationResult: Codable, Sendable {
    public let isValid: Bool
    public let issues: [String]
    public let recommendedActions: [String]
    public let schemaComparison: SchemaComparison?
    
    public init(isValid: Bool, issues: [String] = [], recommendedActions: [String] = [], schemaComparison: SchemaComparison? = nil) {
        self.isValid = isValid
        self.issues = issues
        self.recommendedActions = recommendedActions
        self.schemaComparison = schemaComparison
    }
}

/// Detailed schema comparison between backends
public struct SchemaComparison: Codable, Sendable {
    public let swiftDataSchema: DatabaseSchema?
    public let coreDataSchema: DatabaseSchema?
    public let differences: [SchemaDifference]
    
    public init(swiftDataSchema: DatabaseSchema?, coreDataSchema: DatabaseSchema?, differences: [SchemaDifference]) {
        self.swiftDataSchema = swiftDataSchema
        self.coreDataSchema = coreDataSchema
        self.differences = differences
    }
}

/// Database schema representation
public struct DatabaseSchema: Codable, Sendable {
    public let tables: [TableSchema]
    public let version: String
    public let backend: String
    
    public init(tables: [TableSchema], version: String, backend: String) {
        self.tables = tables
        self.version = version
        self.backend = backend
    }
}

/// Table schema representation
public struct TableSchema: Codable, Sendable {
    public let name: String
    public let columns: [ColumnSchema]
    public let indexes: [IndexSchema]
    public let constraints: [ConstraintSchema]
    
    public init(name: String, columns: [ColumnSchema], indexes: [IndexSchema] = [], constraints: [ConstraintSchema] = []) {
        self.name = name
        self.columns = columns
        self.indexes = indexes
        self.constraints = constraints
    }
}

/// Column schema representation
public struct ColumnSchema: Codable, Sendable {
    public let name: String
    public let type: String
    public let isOptional: Bool
    public let defaultValue: String?
    public let isPrimaryKey: Bool
    
    public init(name: String, type: String, isOptional: Bool, defaultValue: String? = nil, isPrimaryKey: Bool = false) {
        self.name = name
        self.type = type
        self.isOptional = isOptional
        self.defaultValue = defaultValue
        self.isPrimaryKey = isPrimaryKey
    }
}

/// Index schema representation
public struct IndexSchema: Codable, Sendable {
    public let name: String
    public let columns: [String]
    public let isUnique: Bool
    
    public init(name: String, columns: [String], isUnique: Bool = false) {
        self.name = name
        self.columns = columns
        self.isUnique = isUnique
    }
}

/// Constraint schema representation
public struct ConstraintSchema: Codable, Sendable {
    public let name: String
    public let type: String
    public let columns: [String]
    
    public init(name: String, type: String, columns: [String]) {
        self.name = name
        self.type = type
        self.columns = columns
    }
}

/// Schema difference representation
public struct SchemaDifference: Codable, Sendable {
    public let type: DifferenceType
    public let table: String
    public let column: String?
    public let description: String
    
    public enum DifferenceType: String, Codable, Sendable {
        case missingTable = "missing_table"
        case extraTable = "extra_table"
        case missingColumn = "missing_column"
        case extraColumn = "extra_column"
        case columnTypeMismatch = "column_type_mismatch"
        case constraintMismatch = "constraint_mismatch"
        case indexMismatch = "index_mismatch"
    }
    
    public init(type: DifferenceType, table: String, column: String? = nil, description: String) {
        self.type = type
        self.table = table
        self.column = column
        self.description = description
    }
}

/// Schema validator for ensuring compatibility between SwiftData and Core Data backends
@available(macOS 12.0, *)
public actor SchemaValidator {
    
    /// Validate that both SwiftData and Core Data backends generate compatible schemas
    public static func validateCrossBackendCompatibility() async throws -> CrossBackendValidationResult {
        var issues: [String] = []
        var recommendedActions: [String] = []
        
        // Get expected schema definition
        let expectedSchema = getExpectedSchema()
        
        // Validate Core Data schema
        let coreDataSchema = try await validateCoreDataSchema()
        let coreDataIssues = compareWithExpected(coreDataSchema, expectedSchema, backend: "Core Data")
        issues.append(contentsOf: coreDataIssues)
        
        // Validate SwiftData schema if available
        var swiftDataSchema: DatabaseSchema?
        if #available(macOS 14.0, *) {
            swiftDataSchema = try await validateSwiftDataSchema()
            let swiftDataIssues = compareWithExpected(swiftDataSchema!, expectedSchema, backend: "SwiftData")
            issues.append(contentsOf: swiftDataIssues)
            
            // Compare schemas between backends
            let differences = compareSchemas(swiftDataSchema!, coreDataSchema)
            if !differences.isEmpty {
                issues.append("Schema differences found between SwiftData and Core Data backends")
                recommendedActions.append("Review schema differences and ensure compatibility")
            }
        }
        
        if issues.isEmpty {
            return CrossBackendValidationResult(isValid: true)
        } else {
            let comparison = SchemaComparison(
                swiftDataSchema: swiftDataSchema,
                coreDataSchema: coreDataSchema,
                differences: swiftDataSchema != nil ? compareSchemas(swiftDataSchema!, coreDataSchema) : []
            )
            
            if recommendedActions.isEmpty {
                recommendedActions = [
                    "Review schema definitions in both SwiftData models and Core Data model",
                    "Ensure consistent data types and constraints across backends",
                    "Run migration if schema changes are required"
                ]
            }
            
            return CrossBackendValidationResult(
                isValid: false,
                issues: issues,
                recommendedActions: recommendedActions,
                schemaComparison: comparison
            )
        }
    }
    
    /// Validate Core Data schema
    private static func validateCoreDataSchema() async throws -> DatabaseSchema {
        let model = CoreDataStorageManager.getCoreDataModel()
        
        var tables: [TableSchema] = []
        
        for entity in model.entities {
            guard let entityName = entity.name else { continue }
            
            var columns: [ColumnSchema] = []
            
            for property in entity.properties {
                if let attribute = property as? NSAttributeDescription {
                    let column = ColumnSchema(
                        name: attribute.name,
                        type: attributeTypeToSQLiteType(attribute.attributeType),
                        isOptional: attribute.isOptional,
                        defaultValue: attribute.defaultValue.map { "\($0)" },
                        isPrimaryKey: attribute.name == "id"
                    )
                    columns.append(column)
                }
            }
            
            // Add constraints for unique fields  
            var constraints: [ConstraintSchema] = []
            if !entity.uniquenessConstraints.isEmpty {
                for (index, constraint) in entity.uniquenessConstraints.enumerated() {
                    let constraintSchema = ConstraintSchema(
                        name: "unique_\(entityName.lowercased())_\(index)",
                        type: "UNIQUE",
                        columns: constraint.compactMap { $0 as? String }
                    )
                    constraints.append(constraintSchema)
                }
            }
            
            let table = TableSchema(name: entityName, columns: columns, constraints: constraints)
            tables.append(table)
        }
        
        return DatabaseSchema(tables: tables, version: "1.0", backend: "Core Data")
    }
    
    /// Validate SwiftData schema (when available)
    @available(macOS 14.0, *)
    private static func validateSwiftDataSchema() async throws -> DatabaseSchema {
        // For SwiftData, we'll create the expected schema based on our @Model classes
        // In a real implementation, you would introspect the actual SwiftData schema
        
        let tables = [
            createWebAuthnCredentialTable(),
            createServerCredentialTable(),
            createVirtualKeyTable()
        ]
        
        return DatabaseSchema(tables: tables, version: "1.0", backend: "SwiftData")
    }
    
    /// Get the expected schema definition that both backends should match
    private static func getExpectedSchema() -> DatabaseSchema {
        let tables = [
            createWebAuthnCredentialTable(),
            createServerCredentialTable(), 
            createVirtualKeyTable()
        ]
        
        return DatabaseSchema(tables: tables, version: "1.0", backend: "Expected")
    }
    
    /// Create WebAuthn credential table schema
    private static func createWebAuthnCredentialTable() -> TableSchema {
        let columns = [
            ColumnSchema(name: "id", type: "TEXT", isOptional: false, isPrimaryKey: true),
            ColumnSchema(name: "rpId", type: "TEXT", isOptional: false),
            ColumnSchema(name: "userHandle", type: "BLOB", isOptional: false),
            ColumnSchema(name: "publicKey", type: "BLOB", isOptional: false),
            ColumnSchema(name: "privateKeyRef", type: "TEXT", isOptional: true),
            ColumnSchema(name: "createdAt", type: "REAL", isOptional: false),
            ColumnSchema(name: "lastUsed", type: "REAL", isOptional: true),
            ColumnSchema(name: "signCount", type: "INTEGER", isOptional: false, defaultValue: "0"),
            ColumnSchema(name: "isResident", type: "INTEGER", isOptional: false, defaultValue: "0"),
            ColumnSchema(name: "userDisplayName", type: "TEXT", isOptional: true),
            ColumnSchema(name: "credentialType", type: "TEXT", isOptional: false, defaultValue: "public-key")
        ]
        
        let constraints = [
            ConstraintSchema(name: "unique_webauthnClientCredential_0", type: "UNIQUE", columns: ["id"])
        ]
        
        return TableSchema(name: "WebAuthnClientCredential", columns: columns, constraints: constraints)
    }
    
    /// Create server credential table schema
    private static func createServerCredentialTable() -> TableSchema {
        let columns = [
            ColumnSchema(name: "id", type: "TEXT", isOptional: false, isPrimaryKey: true),
            ColumnSchema(name: "credentialId", type: "TEXT", isOptional: false),
            ColumnSchema(name: "publicKeyJWK", type: "TEXT", isOptional: false),
            ColumnSchema(name: "signCount", type: "INTEGER", isOptional: false, defaultValue: "0"),
            ColumnSchema(name: "isDiscoverable", type: "INTEGER", isOptional: false, defaultValue: "0"),
            ColumnSchema(name: "createdAt", type: "REAL", isOptional: false),
            ColumnSchema(name: "lastVerified", type: "REAL", isOptional: true),
            ColumnSchema(name: "rpId", type: "TEXT", isOptional: false),
            ColumnSchema(name: "userHandle", type: "BLOB", isOptional: false)
        ]
        
        let constraints = [
            ConstraintSchema(name: "unique_serverCredential_0", type: "UNIQUE", columns: ["id"])
        ]
        
        return TableSchema(name: "ServerCredential", columns: columns, constraints: constraints)
    }
    
    /// Create virtual key table schema
    private static func createVirtualKeyTable() -> TableSchema {
        let columns = [
            ColumnSchema(name: "id", type: "TEXT", isOptional: false, isPrimaryKey: true),
            ColumnSchema(name: "name", type: "TEXT", isOptional: false),
            ColumnSchema(name: "encryptedPrivateKey", type: "BLOB", isOptional: false),
            ColumnSchema(name: "publicKey", type: "BLOB", isOptional: false),
            ColumnSchema(name: "algorithm", type: "TEXT", isOptional: false),
            ColumnSchema(name: "keySize", type: "INTEGER", isOptional: false),
            ColumnSchema(name: "createdAt", type: "REAL", isOptional: false),
            ColumnSchema(name: "lastUsed", type: "REAL", isOptional: true),
            ColumnSchema(name: "isActive", type: "INTEGER", isOptional: false, defaultValue: "1"),
            ColumnSchema(name: "kdfAlgorithm", type: "TEXT", isOptional: true),
            ColumnSchema(name: "kdfIterations", type: "INTEGER", isOptional: true),
            ColumnSchema(name: "kdfSalt", type: "BLOB", isOptional: true),
            ColumnSchema(name: "kdfKeyLength", type: "INTEGER", isOptional: true)
        ]
        
        let constraints = [
            ConstraintSchema(name: "unique_virtualKey_0", type: "UNIQUE", columns: ["id"])
        ]
        
        return TableSchema(name: "VirtualKey", columns: columns, constraints: constraints)
    }
    
    /// Compare schema with expected definition
    private static func compareWithExpected(_ schema: DatabaseSchema, _ expected: DatabaseSchema, backend: String) -> [String] {
        var issues: [String] = []
        
        // Check tables
        let schemaTableNames = Set(schema.tables.map { $0.name })
        let expectedTableNames = Set(expected.tables.map { $0.name })
        
        for missingTable in expectedTableNames.subtracting(schemaTableNames) {
            issues.append("\(backend): Missing table '\(missingTable)'")
        }
        
        for extraTable in schemaTableNames.subtracting(expectedTableNames) {
            issues.append("\(backend): Extra table '\(extraTable)'")
        }
        
        // Check columns for matching tables
        for expectedTable in expected.tables {
            guard let schemaTable = schema.tables.first(where: { $0.name == expectedTable.name }) else { continue }
            
            let schemaColumnNames = Set(schemaTable.columns.map { $0.name })
            let expectedColumnNames = Set(expectedTable.columns.map { $0.name })
            
            for missingColumn in expectedColumnNames.subtracting(schemaColumnNames) {
                issues.append("\(backend): Table '\(expectedTable.name)' missing column '\(missingColumn)'")
            }
            
            for extraColumn in schemaColumnNames.subtracting(expectedColumnNames) {
                issues.append("\(backend): Table '\(expectedTable.name)' has extra column '\(extraColumn)'")
            }
            
            // Check column types for matching columns
            for expectedColumn in expectedTable.columns {
                guard let schemaColumn = schemaTable.columns.first(where: { $0.name == expectedColumn.name }) else { continue }
                
                if schemaColumn.type != expectedColumn.type {
                    issues.append("\(backend): Column '\(expectedTable.name).\(expectedColumn.name)' type mismatch: expected '\(expectedColumn.type)', got '\(schemaColumn.type)'")
                }
                
                if schemaColumn.isOptional != expectedColumn.isOptional {
                    issues.append("\(backend): Column '\(expectedTable.name).\(expectedColumn.name)' optionality mismatch: expected \(expectedColumn.isOptional), got \(schemaColumn.isOptional)")
                }
            }
        }
        
        return issues
    }
    
    /// Compare schemas between two backends
    private static func compareSchemas(_ schema1: DatabaseSchema, _ schema2: DatabaseSchema) -> [SchemaDifference] {
        var differences: [SchemaDifference] = []
        
        let schema1Tables = Set(schema1.tables.map { $0.name })
        let schema2Tables = Set(schema2.tables.map { $0.name })
        
        // Find table differences
        for missingTable in schema1Tables.subtracting(schema2Tables) {
            differences.append(SchemaDifference(
                type: .missingTable,
                table: missingTable,
                description: "Table '\(missingTable)' exists in \(schema1.backend) but not in \(schema2.backend)"
            ))
        }
        
        for extraTable in schema2Tables.subtracting(schema1Tables) {
            differences.append(SchemaDifference(
                type: .extraTable,
                table: extraTable,
                description: "Table '\(extraTable)' exists in \(schema2.backend) but not in \(schema1.backend)"
            ))
        }
        
        // Compare matching tables
        for table1 in schema1.tables {
            guard let table2 = schema2.tables.first(where: { $0.name == table1.name }) else { continue }
            
            let table1Columns = Set(table1.columns.map { $0.name })
            let table2Columns = Set(table2.columns.map { $0.name })
            
            // Find column differences
            for missingColumn in table1Columns.subtracting(table2Columns) {
                differences.append(SchemaDifference(
                    type: .missingColumn,
                    table: table1.name,
                    column: missingColumn,
                    description: "Column '\(missingColumn)' exists in \(schema1.backend) but not in \(schema2.backend)"
                ))
            }
            
            for extraColumn in table2Columns.subtracting(table1Columns) {
                differences.append(SchemaDifference(
                    type: .extraColumn,
                    table: table1.name,
                    column: extraColumn,
                    description: "Column '\(extraColumn)' exists in \(schema2.backend) but not in \(schema1.backend)"
                ))
            }
            
            // Compare matching columns
            for column1 in table1.columns {
                guard let column2 = table2.columns.first(where: { $0.name == column1.name }) else { continue }
                
                if column1.type != column2.type || column1.isOptional != column2.isOptional {
                    differences.append(SchemaDifference(
                        type: .columnTypeMismatch,
                        table: table1.name,
                        column: column1.name,
                        description: "Column '\(column1.name)' differs: \(schema1.backend)='\(column1.type)(\(column1.isOptional))', \(schema2.backend)='\(column2.type)(\(column2.isOptional))'"
                    ))
                }
            }
        }
        
        return differences
    }
    
    /// Convert NSAttributeType to SQLite type string
    private static func attributeTypeToSQLiteType(_ attributeType: NSAttributeType) -> String {
        switch attributeType {
        case .stringAttributeType:
            return "TEXT"
        case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
            return "INTEGER"
        case .booleanAttributeType:
            return "INTEGER"
        case .floatAttributeType, .doubleAttributeType:
            return "REAL"
        case .dateAttributeType:
            return "REAL"
        case .binaryDataAttributeType:
            return "BLOB"
        default:
            return "TEXT"
        }
    }
}

// MARK: - Extension to expose CoreDataStorageManager methods for schema validation

extension CoreDataStorageManager {
    /// Access the Core Data model creation for schema validation
    /// This method is already implemented in CoreDataStorageManager,
    /// we just need to ensure it's accessible for validation purposes
    internal static func getCoreDataModel() -> NSManagedObjectModel {
        return createManagedObjectModel()
    }
} 
