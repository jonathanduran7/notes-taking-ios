//
//  NotesViewModel.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

@Observable
class NotesViewModel {
    
    // MARK: - Dependencies
    private var repository: DataRepositoryProtocol?
    private var router: AppRouter?
    
    // MARK: - Data Queries
    private var _notes: [Notes] = []
    private var _categories: [Category] = []
    
    var notes: [Notes] { _notes }
    var categories: [Category] { _categories }
    
    // MARK: - Form State
    var formTitle: String = ""
    var formContent: String = ""
    var selectedCategory: Category?
    
    // MARK: - Edit/Delete State
    var noteToEdit: Notes?
    var noteToDelete: Notes?
    
    // MARK: - Computed Properties
    var isEmpty: Bool {
        notes.isEmpty
    }
    
    var categoriesEmpty: Bool {
        categories.isEmpty
    }
    
    var isFormValid: Bool {
        !formTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Initialization
    init() {}

    // MARK: - Configuration
    func configure(with repository: DataRepositoryProtocol, router: AppRouter) {
        self.repository = repository
        self.router = router
        Task {
            await fetchData()
        }
    }
    
    // MARK: - Data Management
    func fetchData() async {
        guard let repository = repository else {
            print("Repository no configurado para fetchData")
            return
        }
        
        do {
            _notes = try await repository.fetchNotes()
            _categories = try await repository.fetchCategories()
        } catch {
            print("❌ Error fetching data: \(error)")
            _notes = []
            _categories = []
        }
    }
    
    // MARK: - Form Management
    func clearForm() {
        formTitle = ""
        formContent = ""
        selectedCategory = nil
    }
    
    func prepareForEdit(_ note: Notes) {
        noteToEdit = note
        formTitle = note.title
        formContent = note.content
        selectedCategory = note.category
    }
    
    func prepareForDelete(_ note: Notes) {
        noteToDelete = note
    }
    
    func cancelEdit() {
        noteToEdit = nil
        clearForm()
    }
    
    func cancelDelete() {
        noteToDelete = nil
    }
    
    // MARK: - CRUD Operations
    
    func createNote() {
        guard let repository = repository else {
            print("Repository no configurado para createNote")
            return
        }
        
        let trimmedTitle = formTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            print("⚠️ Cannot create note: title is empty")
            return
        }
        
        Task {
            do {
                _ = try await repository.createNote(
                    title: trimmedTitle,
                    content: formContent,
                    category: selectedCategory
                )
                await fetchData()
                clearForm()
            } catch {
                print("❌ Error al crear nota: \(error)")
            }
        }
    }
    
    func updateNote() {
        guard let repository = repository else {
            print("Repository no configurado para updateNote")
            return
        }
        
        guard let note = noteToEdit else {
            print("⚠️ Cannot update: no note selected for editing")
            return
        }
        
        let trimmedTitle = formTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            print("⚠️ Cannot update note: title is empty")
            return
        }
        
        Task {
            do {
                try await repository.updateNote(
                    note,
                    title: trimmedTitle,
                    content: formContent,
                    category: selectedCategory
                )
                await fetchData()
                cancelEdit()
            } catch {
                print("❌ Error al actualizar nota: \(error)")
            }
        }
    }
    
    func deleteNote() {
        guard let repository = repository else {
            print("Repository no configurado para deleteNote")
            return
        }
        
        guard let note = noteToDelete else {
            print("⚠️ Cannot delete: no note selected for deletion")
            return
        }
        
        Task {
            do {
                try await repository.deleteNote(note)
                await fetchData()
                cancelDelete()
            } catch {
                print("❌ Error al eliminar nota: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func getNotesCountText() -> String {
        let count = notes.count
        return "\(count) nota\(count == 1 ? "" : "s")"
    }
    
    func hasCategoriesAvailable() -> Bool {
        !categories.isEmpty
    }
    
    func getCategoryPlaceholderText() -> String {
        selectedCategory?.name ?? "Seleccionar categoría"
    }
    
    func getCategoryTextColor() -> Color {
        selectedCategory == nil ? .gray : .primary
    }
}