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
    private var modelContext: ModelContext
    
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
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }
    
    // MARK: - Data Management
    func fetchData() {
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
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            print("⚠️ Cannot create category: name is empty")
            return
        }
        
        let newCategory = Category(name: trimmedName)
        modelContext.insert(newCategory)
        
        do {
            try modelContext.save()
            print("✅ Categoría '\(trimmedName)' creada exitosamente")
            fetchData()
            clearNewCategoryForm()
        } catch {
            print("❌ Error al crear categoría: \(error)")
        }
    }
    
    func updateCategory() {
        guard let category = categoryToEdit else {
            print("⚠️ Cannot update: no category selected for editing")
            return
        }
        
        let trimmedName = editCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            print("⚠️ Cannot update category: name is empty")
            return
        }
        
        category.updateName(trimmedName)
        
        do {
            try modelContext.save()
            print("✅ Categoría actualizada a '\(trimmedName)'")
            fetchData()
            cancelEdit()
        } catch {
            print("❌ Error al actualizar categoría: \(error)")
        }
    }
    
    func deleteCategory() {
        guard let category = categoryToDelete else {
            print("⚠️ Cannot delete: no category selected for deletion")
            return
        }
        
        let categoryName = category.name
        modelContext.delete(category)
        
        do {
            try modelContext.save()
            print("✅ Categoría '\(categoryName)' eliminada exitosamente")
            fetchData()
            cancelDelete()
        } catch {
            print("❌ Error al eliminar categoría: \(error)")
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