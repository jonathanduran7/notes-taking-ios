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
    private var repository: DataRepositoryProtocol?
    private var router: AppRouter?
    
    // MARK: - Loading States
    let loadingManager = LoadingManager()
    
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
            // Fetch both categories and notes in parallel
            async let categoriesResult = repository.fetchCategories()
            async let notesResult = repository.fetchNotes()
            
            _categories = try await categoriesResult
            _allNotes = try await notesResult
            
            loadingManager.finishLoading(.fetch, success: true)
        } catch {
            print("❌ Error fetching data: \(error)")
            _categories = []
            _allNotes = []
            loadingManager.handleError(error, for: .fetch)
        }
    }
    
    func refreshData() async {
        await fetchData()
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
    
    func performAsyncSearch(_ searchText: String) async -> [Notes] {
        guard let repository = repository else {
            return []
        }
        
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        let result = await loadingManager.performOperation(.search) {
            try await repository.searchNotes(containing: searchText)
        }
        
        return result ?? []
    }
    
    // MARK: - Navigation
    func navigateToNotesTab() {
        router?.navigateToNotes()
    }
    
    func navigateToNoteDetail(_ note: Notes) {
        router?.navigateToNote(withId: note.id)
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