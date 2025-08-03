//
//  DataRepositoryProtocol.swift
//  notes-taking
//
//  Created by Jonathan Duran on 03/08/2025.
//

import Foundation
import SwiftData

protocol DataRepositoryProtocol {
    
    // MARK: - Category Operations
    
    func fetchCategories() async throws -> [Category]
    
    func createCategory(name: String) async throws -> Category

    func updateCategory(_ category: Category, newName: String) async throws
    
    func deleteCategory(_ category: Category) async throws
    
    func deleteAllCategories() async throws -> Int
    
    // MARK: - Notes Operations
    
    func fetchNotes() async throws -> [Notes]
    
    func createNote(title: String, content: String, category: Category?) async throws -> Notes

    func updateNote(_ note: Notes, title: String, content: String, category: Category?) async throws
    
    func deleteNote(_ note: Notes) async throws
    
    func deleteAllNotes() async throws -> Int
    
    // MARK: - Bulk Operations
    
    func deleteAllData() async throws -> (categoriesDeleted: Int, notesDeleted: Int)
    
    // MARK: - Search Operations
    
    func searchNotes(containing searchText: String) async throws -> [Notes]
    
    func fetchNotes(for category: Category) async throws -> [Notes]
}

// MARK: - Repository Errors

enum RepositoryError: LocalizedError {
    case invalidData(String)
    case notFound(String)
    case saveFailed(String)
    case deleteFailed(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidData(let message):
            return "Datos inválidos: \(message)"
        case .notFound(let message):
            return "No encontrado: \(message)"
        case .saveFailed(let message):
            return "Error al guardar: \(message)"
        case .deleteFailed(let message):
            return "Error al eliminar: \(message)"
        case .unknownError(let message):
            return "Error desconocido: \(message)"
        }
    }
}

// MARK: - Repository Configuration

struct RepositoryConfiguration {
    let enableLogging: Bool
    
    let operationTimeout: TimeInterval
    
    static let `default` = RepositoryConfiguration(
        enableLogging: true,
        operationTimeout: 10.0
    )
}