//
//  SettingsViewModel.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

@Observable
class SettingsViewModel {
    
    // MARK: - Dependencies
    private var modelContext: ModelContext?
    private var router: AppRouter?
    
    // MARK: - Data Queries
    private var _categories: [Category] = []
    private var _notes: [Notes] = []
    
    var categories: [Category] { _categories }
    var notes: [Notes] { _notes }
    
    // MARK: - Computed Properties
    var categoriesCount: Int {
        categories.count
    }
    
    var notesCount: Int {
        notes.count
    }
    
    var hasCategories: Bool {
        !categories.isEmpty
    }
    
    var hasNotes: Bool {
        !notes.isEmpty
    }
    
    var hasAnyData: Bool {
        hasCategories || hasNotes
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
        fetchCategories()
        fetchNotes()
    }
    
    private func fetchCategories() {
        guard let modelContext = modelContext else {
            print("ModelContext no configurado para fetchCategories")
            return
        }
        
        let categoriesDescriptor = FetchDescriptor<Category>()
        
        do {
            _categories = try modelContext.fetch(categoriesDescriptor)
        } catch {
            print("❌ Error fetching categories: \(error)")
            _categories = []
        }
    }
    
    private func fetchNotes() {
        guard let modelContext = modelContext else {
            print("ModelContext no configurado para fetchNotes")
            return
        }
        
        let notesDescriptor = FetchDescriptor<Notes>()
        
        do {
            _notes = try modelContext.fetch(notesDescriptor)
        } catch {
            print("❌ Error fetching notes: \(error)")
            _notes = []
        }
    }
    
    // MARK: - Delete Operations
    
    func deleteAllCategories() {
        guard let modelContext = modelContext else {
            print("ModelContext no configurado para deleteAllCategories")
            return
        }
        
        let count = categories.count
        
        for category in categories {
            modelContext.delete(category)
        }
        
        do {
            try modelContext.save()
            print("✅ Se eliminaron \(count) categorías exitosamente")
            fetchData() // Refresh data
        } catch {
            print("❌ Error al eliminar categorías: \(error)")
        }
    }
    
    func deleteAllNotes() {
        guard let modelContext = modelContext else {
            print("ModelContext no configurado para deleteAllNotes")
            return
        }
        
        let count = notes.count
        
        for note in notes {
            modelContext.delete(note)
        }
        
        do {
            try modelContext.save()
            print("✅ Se eliminaron \(count) notas exitosamente")
            fetchData() // Refresh data
        } catch {
            print("❌ Error al eliminar notas: \(error)")
        }
    }
    
    func deleteEverything() {
        guard let modelContext = modelContext else {
            print("ModelContext no configurado para deleteEverything")
            return
        }
        
        let categoryCount = categories.count
        let noteCount = notes.count
        
        // Eliminar todas las notas
        for note in notes {
            modelContext.delete(note)
        }
        
        // Eliminar todas las categorías
        for category in categories {
            modelContext.delete(category)
        }
        
        do {
            try modelContext.save()
            print("🧹 TODO ELIMINADO: \(noteCount) notas y \(categoryCount) categorías")
            fetchData() // Refresh data
        } catch {
            print("❌ Error al eliminar todo: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    func getCategoriesSubtitle() -> String {
        "\(categoriesCount) categoría\(categoriesCount == 1 ? "" : "s")"
    }
    
    func getNotesSubtitle() -> String {
        "\(notesCount) nota\(notesCount == 1 ? "" : "s")"
    }
    
    func getDeleteCategoriesAlertTitle() -> String {
        "Eliminar \(categoriesCount) categoría\(categoriesCount == 1 ? "" : "s")"
    }
    
    func getDeleteNotesAlertTitle() -> String {
        "Eliminar \(notesCount) nota\(notesCount == 1 ? "" : "s")"
    }
    
    func getAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    func getAppName() -> String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Notes App"
    }
}