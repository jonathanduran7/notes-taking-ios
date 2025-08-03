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
    private var modelContext: ModelContext?
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
    func configure(with context: ModelContext, router: AppRouter) {
        self.modelContext = context
        self.router = router
        fetchData()
    }
    
    // MARK: - Data Management
    func fetchData() {
        guard let modelContext = modelContext else {
            print("ModelContext no configurado para fetchData")
            return
        }

        let notesDescriptor = FetchDescriptor<Notes>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        do {
            _notes = try modelContext.fetch(notesDescriptor)
        } catch {
            print("❌ Error fetching notes: \(error)")
            _notes = []
        }
        
        let categoriesDescriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            _categories = try modelContext.fetch(categoriesDescriptor)
        } catch {
            print("❌ Error fetching categories: \(error)")
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
        guard let modelContext = modelContext else {
            print("ModelContext no configurado para createNote")
            return
        }
        
        let trimmedTitle = formTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            print("⚠️ Cannot create note: title is empty")
            return
        }
        
        let newNote = Notes(
            title: trimmedTitle,
            content: formContent,
            category: selectedCategory
        )
        
        modelContext.insert(newNote)
        
        do {
            try modelContext.save()
            print("✅ Nota '\(trimmedTitle)' creada exitosamente")
            fetchData()
            clearForm()
        } catch {
            print("❌ Error al crear nota: \(error)")
        }
    }
    
    func updateNote() {
        guard let modelContext = modelContext else {
            print("ModelContext no configurado para updateNote")
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
        
        note.update(
            title: trimmedTitle,
            content: formContent,
            category: selectedCategory
        )
        
        do {
            try modelContext.save()
            print("✅ Nota '\(trimmedTitle)' actualizada exitosamente")
            fetchData()
            cancelEdit()
        } catch {
            print("❌ Error al actualizar nota: \(error)")
        }
    }
    
    func deleteNote() {
        guard let modelContext = modelContext else {
            print("ModelContext no configurado para deleteNote")
            return
        }
        
        guard let note = noteToDelete else {
            print("⚠️ Cannot delete: no note selected for deletion")
            return
        }
        
        let noteTitle = note.title
        modelContext.delete(note)
        
        do {
            try modelContext.save()
            print("✅ Nota '\(noteTitle)' eliminada exitosamente")
            fetchData()
            cancelDelete()
        } catch {
            print("❌ Error al eliminar nota: \(error)")
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