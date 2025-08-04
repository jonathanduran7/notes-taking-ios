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
    private var repository: DataRepositoryProtocol?
    private var router: AppRouter?

    // MARK: - Loading States
    let loadingManager = LoadingManager()
    
    // MARK: - Theme Manager
    let themeManager = ThemeManager.shared

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
        
        loadingManager.startLoading(.fetch)
        
        do {
            async let categoriesResult = repository.fetchCategories()
            async let notesResult = repository.fetchNotes()
            
            _categories = try await categoriesResult
            _notes = try await notesResult
            
            loadingManager.finishLoading(.fetch, success: true)
        } catch {
            print("❌ Error fetching data: \(error)")
            _categories = []
            _notes = []
            loadingManager.handleError(error, for: .fetch)
        }
    }
    
    func refreshData() async {
        await fetchData()
    }
    
    // MARK: - Delete Operations
    
    func deleteAllCategories() {
        guard let repository = repository else {
            print("Repository no configurado para deleteAllCategories")
            return
        }
        
        Task {
            let result = await loadingManager.performOperation(.deleteAll) {
                try await repository.deleteAllCategories()
            }
            
            if let count = result {
                print("✅ Se eliminaron \(count) categorías exitosamente")
                await fetchData()
            }
        }
    }
    
    func deleteAllNotes() {
        guard let repository = repository else {
            print("Repository no configurado para deleteAllNotes")
            return
        }
        
        Task {
            let result = await loadingManager.performOperation(.deleteAll) {
                try await repository.deleteAllNotes()
            }
            
            if let count = result {
                print("✅ Se eliminaron \(count) notas exitosamente")
                await fetchData()
            }
        }
    }
    
    func deleteEverything() {
        guard let repository = repository else {
            print("Repository no configurado para deleteEverything")
            return
        }
        
        Task {
            let result = await loadingManager.performOperation(.deleteAll) {
                try await repository.deleteAllData()
            }
            
            if let deleteResult = result {
                print("🧹 TODO ELIMINADO: \(deleteResult.notesDeleted) notas y \(deleteResult.categoriesDeleted) categorías")
                await fetchData()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var notesWithCategoriesCount: Int {
        notes.filter { $0.category != nil }.count
    }
    
    func getCategoriesSubtitle() -> String {
        let relatedNotes = notesWithCategoriesCount
        if relatedNotes > 0 {
            return "\(categoriesCount) categoría\(categoriesCount == 1 ? "" : "s") + \(relatedNotes) nota\(relatedNotes == 1 ? "" : "s") relacionada\(relatedNotes == 1 ? "" : "s")"
        }
        return "\(categoriesCount) categoría\(categoriesCount == 1 ? "" : "s")"
    }
    
    func getNotesSubtitle() -> String {
        "\(notesCount) nota\(notesCount == 1 ? "" : "s")"
    }
    
    func getDeleteCategoriesAlertTitle() -> String {
        let relatedNotes = notesWithCategoriesCount
        if relatedNotes > 0 {
            return "⚠️ Eliminar \(categoriesCount) categoría\(categoriesCount == 1 ? "" : "s") + \(relatedNotes) nota\(relatedNotes == 1 ? "" : "s")"
        }
        return "Eliminar \(categoriesCount) categoría\(categoriesCount == 1 ? "" : "s")"
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

    func toggleTheme() {
        themeManager.toggleTheme()
    }
}