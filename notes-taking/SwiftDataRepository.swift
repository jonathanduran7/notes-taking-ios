//
//  SwiftDataRepository.swift
//  notes-taking
//
//  Created by Jonathan Duran on 03/08/2025.
//

import Foundation
import SwiftData

/// Implementación de DataRepositoryProtocol usando SwiftData
final class SwiftDataRepository: DataRepositoryProtocol {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    private let configuration: RepositoryConfiguration
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext, configuration: RepositoryConfiguration = .default) {
        self.modelContext = modelContext
        self.configuration = configuration
    }
    
    // MARK: - Category Operations
    
    func fetchCategories() async throws -> [Category] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let descriptor = FetchDescriptor<Category>(
                    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
                )
                let categories = try modelContext.fetch(descriptor)
                
                if configuration.enableLogging {
                    print("📂 Repository: Fetched \(categories.count) categories")
                }
                
                continuation.resume(returning: categories)
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error fetching categories: \(error)")
                }
                continuation.resume(throwing: RepositoryError.unknownError(error.localizedDescription))
            }
        }
    }
    
    func createCategory(name: String) async throws -> Category {
        return try await withCheckedThrowingContinuation { continuation in
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmedName.isEmpty else {
                continuation.resume(throwing: RepositoryError.invalidData("El nombre de la categoría no puede estar vacío"))
                return
            }
            
            do {
                let newCategory = Category(name: trimmedName)
                modelContext.insert(newCategory)
                try modelContext.save()
                
                if configuration.enableLogging {
                    print("✅ Repository: Created category '\(trimmedName)'")
                }
                
                continuation.resume(returning: newCategory)
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error creating category: \(error)")
                }
                continuation.resume(throwing: RepositoryError.saveFailed(error.localizedDescription))
            }
        }
    }
    
    func updateCategory(_ category: Category, newName: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmedName.isEmpty else {
                continuation.resume(throwing: RepositoryError.invalidData("El nombre de la categoría no puede estar vacío"))
                return
            }
            
            do {
                let oldName = category.name
                category.updateName(trimmedName)
                try modelContext.save()
                
                if configuration.enableLogging {
                    print("✅ Repository: Updated category from '\(oldName)' to '\(trimmedName)'")
                }
                
                continuation.resume()
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error updating category: \(error)")
                }
                continuation.resume(throwing: RepositoryError.saveFailed(error.localizedDescription))
            }
        }
    }
    
    func deleteCategory(_ category: Category) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let categoryName = category.name
                
                let relatedNotes = try fetchNotesSync(for: category)
                let notesCount = relatedNotes.count
                
                for note in relatedNotes {
                    modelContext.delete(note)
                }
                
                modelContext.delete(category)
                try modelContext.save()
                
                if configuration.enableLogging {
                    if notesCount > 0 {
                        print("🗑️ Repository: Cascade delete - Deleted \(notesCount) notes from category '\(categoryName)'")
                    }
                    print("✅ Repository: Deleted category '\(categoryName)' (+ \(notesCount) related notes)")
                }
                
                continuation.resume()
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error deleting category: \(error)")
                }
                continuation.resume(throwing: RepositoryError.deleteFailed(error.localizedDescription))
            }
        }
    }
    
    func deleteAllCategories() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let categories = try fetchCategoriesSync()
                let categoriesCount = categories.count
                var totalNotesDeleted = 0
                
                for category in categories {
                    let relatedNotes = try fetchNotesSync(for: category)
                    totalNotesDeleted += relatedNotes.count
                    
                    for note in relatedNotes {
                        modelContext.delete(note)
                    }
                }
                
                for category in categories {
                    modelContext.delete(category)
                }
                
                try modelContext.save()
                
                if configuration.enableLogging {
                    if totalNotesDeleted > 0 {
                        print("🗑️ Repository: Cascade delete - Deleted \(totalNotesDeleted) notes from \(categoriesCount) categories")
                    }
                    print("🧹 Repository: Deleted all \(categoriesCount) categories (+ \(totalNotesDeleted) related notes)")
                }
                
                continuation.resume(returning: categoriesCount)
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error deleting all categories: \(error)")
                }
                continuation.resume(throwing: RepositoryError.deleteFailed(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Notes Operations
    
    func fetchNotes() async throws -> [Notes] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let descriptor = FetchDescriptor<Notes>(
                    sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
                )
                let notes = try modelContext.fetch(descriptor)
                
                if configuration.enableLogging {
                    print("📝 Repository: Fetched \(notes.count) notes")
                }
                
                continuation.resume(returning: notes)
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error fetching notes: \(error)")
                }
                continuation.resume(throwing: RepositoryError.unknownError(error.localizedDescription))
            }
        }
    }
    
    func createNote(title: String, content: String, category: Category?) async throws -> Notes {
        return try await withCheckedThrowingContinuation { continuation in
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmedTitle.isEmpty else {
                continuation.resume(throwing: RepositoryError.invalidData("El título de la nota no puede estar vacío"))
                return
            }
            
            do {
                let newNote = Notes(title: trimmedTitle, content: content, category: category)
                modelContext.insert(newNote)
                try modelContext.save()
                
                if configuration.enableLogging {
                    print("✅ Repository: Created note '\(trimmedTitle)'")
                }
                
                continuation.resume(returning: newNote)
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error creating note: \(error)")
                }
                continuation.resume(throwing: RepositoryError.saveFailed(error.localizedDescription))
            }
        }
    }
    
    func updateNote(_ note: Notes, title: String, content: String, category: Category?) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmedTitle.isEmpty else {
                continuation.resume(throwing: RepositoryError.invalidData("El título de la nota no puede estar vacío"))
                return
            }
            
            do {
                let oldTitle = note.title
                note.update(title: trimmedTitle, content: content, category: category)
                try modelContext.save()
                
                if configuration.enableLogging {
                    print("✅ Repository: Updated note from '\(oldTitle)' to '\(trimmedTitle)'")
                }
                
                continuation.resume()
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error updating note: \(error)")
                }
                continuation.resume(throwing: RepositoryError.saveFailed(error.localizedDescription))
            }
        }
    }
    
    func deleteNote(_ note: Notes) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let noteTitle = note.title
                modelContext.delete(note)
                try modelContext.save()
                
                if configuration.enableLogging {
                    print("✅ Repository: Deleted note '\(noteTitle)'")
                }
                
                continuation.resume()
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error deleting note: \(error)")
                }
                continuation.resume(throwing: RepositoryError.deleteFailed(error.localizedDescription))
            }
        }
    }
    
    func deleteAllNotes() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let notes = try fetchNotesSync()
                let count = notes.count
                
                for note in notes {
                    modelContext.delete(note)
                }
                
                try modelContext.save()
                
                if configuration.enableLogging {
                    print("🧹 Repository: Deleted all \(count) notes")
                }
                
                continuation.resume(returning: count)
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error deleting all notes: \(error)")
                }
                continuation.resume(throwing: RepositoryError.deleteFailed(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Bulk Operations
    
    func deleteAllData() async throws -> (categoriesDeleted: Int, notesDeleted: Int) {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let notes = try fetchNotesSync()
                let categories = try fetchCategoriesSync()
                
                let notesCount = notes.count
                let categoriesCount = categories.count
                
                // Eliminar notas primero (por las relaciones)
                for note in notes {
                    modelContext.delete(note)
                }
                
                // Luego categorías
                for category in categories {
                    modelContext.delete(category)
                }
                
                try modelContext.save()
                
                if configuration.enableLogging {
                    print("🧹 Repository: Deleted all data - \(notesCount) notes, \(categoriesCount) categories")
                }
                
                continuation.resume(returning: (categoriesDeleted: categoriesCount, notesDeleted: notesCount))
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error deleting all data: \(error)")
                }
                continuation.resume(throwing: RepositoryError.deleteFailed(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Search Operations
    
    func searchNotes(containing searchText: String) async throws -> [Notes] {
        return try await withCheckedThrowingContinuation { continuation in
            guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                continuation.resume(returning: [])
                return
            }
            
            do {
                let notes = try fetchNotesSync()
                
                let filteredNotes = notes.filter { note in
                    note.title.localizedCaseInsensitiveContains(searchText) ||
                    note.content.localizedCaseInsensitiveContains(searchText) ||
                    (note.category?.name.localizedCaseInsensitiveContains(searchText) ?? false)
                }
                
                if configuration.enableLogging {
                    print("🔍 Repository: Found \(filteredNotes.count) notes for search '\(searchText)'")
                }
                
                continuation.resume(returning: filteredNotes)
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error searching notes: \(error)")
                }
                continuation.resume(throwing: RepositoryError.unknownError(error.localizedDescription))
            }
        }
    }
    
    func fetchNotes(for category: Category) async throws -> [Notes] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let allNotes = try fetchNotesSync()
                let categoryNotes = allNotes.filter { $0.category?.id == category.id }
                
                if configuration.enableLogging {
                    print("📝 Repository: Found \(categoryNotes.count) notes for category '\(category.name)'")
                }
                
                continuation.resume(returning: categoryNotes)
            } catch {
                if configuration.enableLogging {
                    print("❌ Repository: Error fetching notes for category: \(error)")
                }
                continuation.resume(throwing: RepositoryError.unknownError(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Private Helpers (Synchronous)
    
    private func fetchCategoriesSync() throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    private func fetchNotesSync() throws -> [Notes] {
        let descriptor = FetchDescriptor<Notes>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    private func fetchNotesSync(for category: Category) throws -> [Notes] {
        let allNotes = try fetchNotesSync()
        return allNotes.filter { $0.category?.id == category.id }
    }
}

// MARK: - Convenience Extensions

extension SwiftDataRepository {
    
    static func debug(modelContext: ModelContext) -> SwiftDataRepository {
        return SwiftDataRepository(
            modelContext: modelContext,
            configuration: RepositoryConfiguration(enableLogging: true, operationTimeout: 30.0)
        )
    }
    
    static func production(modelContext: ModelContext) -> SwiftDataRepository {
        return SwiftDataRepository(
            modelContext: modelContext,
            configuration: RepositoryConfiguration(enableLogging: false, operationTimeout: 10.0)
        )
    }
}