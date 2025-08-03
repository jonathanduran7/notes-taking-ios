//
//  HomeViewModel.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

@Observable
class HomeViewModel {
    
    // MARK: - Dependencies
    private var modelContext: ModelContext?
    
    // MARK: - Data Queries
    private var _categories: [Category] = []
    private var _allNotes: [Notes] = []
    
    var categories: [Category] { _categories }
    var allNotes: [Notes] { _allNotes }
    
    // MARK: - Search State
    var searchText: String = "" {
        didSet {
            updateSearchState()
        }
    }
    var isSearching: Bool = false
    
    // MARK: - Computed Properties
    var hasCategories: Bool {
        !categories.isEmpty
    }
    
    var hasNotes: Bool {
        !allNotes.isEmpty
    }
    
    var filteredNotes: [Notes] {
        guard !searchText.isEmpty else { return [] }
        
        return allNotes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText) ||
            (note.category?.name.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var hasSearchResults: Bool {
        !filteredNotes.isEmpty
    }
    
    var searchResultsCount: Int {
        filteredNotes.count
    }
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Configuration
    func configure(with context: ModelContext) {
        self.modelContext = context
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
        
        let categoriesDescriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
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
        
        let notesDescriptor = FetchDescriptor<Notes>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        do {
            _allNotes = try modelContext.fetch(notesDescriptor)
        } catch {
            print("❌ Error fetching notes: \(error)")
            _allNotes = []
        }
    }
    
    // MARK: - Search Management
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    private func updateSearchState() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSearching = !searchText.isEmpty
        }
    }
    
    func clearSearch() {
        searchText = ""
        isSearching = false
    }
    
    // MARK: - Navigation
    func navigateToNotesTab() {
        NotificationCenter.default.post(name: NSNotification.Name("SwitchToNotesTab"), object: nil)
        print("🔍 Navegando a la pestaña de Notas")
    }
    
    func navigateToNoteDetail(_ note: Notes) {
        NotificationCenter.default.post(name: NSNotification.Name("SwitchToNotesTab"), object: nil)
        print("🔍 Navegando a nota: \(note.title)")
    }
    
    // MARK: - Helper Methods
    
    func getCategoriesCountText() -> String {
        "\(categories.count)"
    }
    
    func getSearchResultsCountText() -> String {
        "\(searchResultsCount) nota\(searchResultsCount == 1 ? "" : "s")"
    }
    
    func getSearchSuggestions() -> [String] {
        let categoryNames = categories.prefix(3).map { $0.name }
        let recentWords = allNotes.prefix(5).compactMap { note in
            note.title.components(separatedBy: " ").first
        }
        
        return Array(Set(categoryNames + recentWords)).prefix(3).map { String($0) }
    }
    
    func applySuggestion(_ suggestion: String) {
        searchText = suggestion
    }
    
    // MARK: - Search Result Helpers
    
    func getPreview(for text: String) -> String {
        if text.count <= 100 {
            return text
        }
        
        if let range = text.range(of: searchText, options: .caseInsensitive) {
            let start = max(text.startIndex, text.index(range.lowerBound, offsetBy: -30, limitedBy: text.startIndex) ?? text.startIndex)
            let end = min(text.endIndex, text.index(range.upperBound, offsetBy: 30, limitedBy: text.endIndex) ?? text.endIndex)
            return "..." + String(text[start..<end]) + "..."
        }
        
        return String(text.prefix(100)) + "..."
    }
    
    func highlightedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        if let range = attributed.range(of: searchText, options: .caseInsensitive) {
            attributed[range].backgroundColor = Color.sageGreen.opacity(0.3)
            attributed[range].foregroundColor = Color.sageGreen
        }
        
        return attributed
    }
}