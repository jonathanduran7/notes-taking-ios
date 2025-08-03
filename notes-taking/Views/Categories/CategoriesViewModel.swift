//
//  CategoriesViewModel.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

@Observable
class CategoriesViewModel {
    
    // MARK: - Dependencies
    private var repository: DataRepositoryProtocol?
    private var router: AppRouter?
    
    // MARK: - Loading States
    let loadingManager = LoadingManager()
    
    // MARK: - Data Queries
    private var _categories: [Category] = []
    
    var categories: [Category] { _categories }
    
    // MARK: - Form State
    var newCategoryName: String = ""
    var editCategoryName: String = ""
    
    // MARK: - Edit/Delete State
    var categoryToEdit: Category?
    var categoryToDelete: Category?
    
    // MARK: - Computed Properties
    var isEmpty: Bool {
        categories.isEmpty
    }
    
    var isNewCategoryFormValid: Bool {
        !newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isEditCategoryFormValid: Bool {
        !editCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
        
        let result = await loadingManager.performOperation(.fetch) {
            try await repository.fetchCategories()
        }
        
        _categories = result ?? []
    }
    
    func refreshData() async {
        await fetchData()
    }
    
    // MARK: - Form Management
    func clearNewCategoryForm() {
        newCategoryName = ""
    }
    
    func clearEditCategoryForm() {
        editCategoryName = ""
    }
    
    func prepareForEdit(_ category: Category) {
        categoryToEdit = category
        editCategoryName = category.name
    }
    
    func prepareForDelete(_ category: Category) {
        categoryToDelete = category
    }
    
    func cancelEdit() {
        categoryToEdit = nil
        clearEditCategoryForm()
    }
    
    func cancelDelete() {
        categoryToDelete = nil
    }
    
    // MARK: - CRUD Operations
    
    func createCategory() {
        guard let repository = repository else {
            print("Repository no configurado para createCategory")
            return
        }
        
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            print("⚠️ Cannot create category: name is empty")
            return
        }
        
        Task {
            let result = await loadingManager.performOperation(.create) {
                try await repository.createCategory(name: trimmedName)
            }
            
            if result != nil {
                await fetchData()
                clearNewCategoryForm()
            }
        }
    }
    
    func updateCategory() {
        guard let repository = repository else {
            print("Repository no configurado para updateCategory")
            return
        }
        
        guard let category = categoryToEdit else {
            print("⚠️ Cannot update: no category selected for editing")
            return
        }
        
        let trimmedName = editCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            print("⚠️ Cannot update category: name is empty")
            return
        }
        
        Task {
            let success = await loadingManager.performOperation(.update) {
                try await repository.updateCategory(category, newName: trimmedName)
                return true
            }
            
            if success != nil {
                await fetchData()
                cancelEdit()
            }
        }
    }
    
    func deleteCategory() {
        guard let repository = repository else {
            print("Repository no configurado para deleteCategory")
            return
        }
        
        guard let category = categoryToDelete else {
            print("⚠️ Cannot delete: no category selected for deletion")
            return
        }
        
        Task {
            let success = await loadingManager.performOperation(.delete) {
                try await repository.deleteCategory(category)
                return true
            }
            
            if success != nil {
                await fetchData()
                cancelDelete()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func getCategoriesCountText() -> String {
        let count = categories.count
        return "\(count) categoría\(count == 1 ? "" : "s")"
    }
    
    func hasCategories() -> Bool {
        !categories.isEmpty
    }
}