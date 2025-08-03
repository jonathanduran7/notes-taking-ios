//
//  CategoriesView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.createdAt, order: .reverse) private var categories: [Category]
    
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var categoryToEdit: Category?
    @State private var categoryToDelete: Category?
    @State private var newCategoryName = ""
    @State private var editCategoryName = ""
    

    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TopBar(title: "Categorías")
                
                if categories.isEmpty {
                    emptyStateView
                } else {
                    categoriesListView
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            print("📁 Pestaña Categorías cargada")
        }
        // Sheets y Alerts
        .sheet(isPresented: $showingAddSheet) {
            addCategorySheet
        }
        .sheet(isPresented: $showingEditSheet) {
            editCategorySheet
        }
        .alert("Eliminar Categoría", isPresented: $showingDeleteAlert) {
            deleteAlert
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.sageGreen.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No hay categorías")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Crea tu primera categoría para organizar tus notas")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                PrimaryButton(title: "Crear Primera Categoría") {
                    showingAddSheet = true
                }
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)
        }
        .padding()
    }
    
    // MARK: - Categories List
    private var categoriesListView: some View {
        VStack(spacing: 0) {
            // Contador y botón agregar
            HStack {
                Text("\(categories.count) categoría\(categories.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: { showingAddSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Agregar")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.sageGreen)
                }
            }
            .padding()
            
            // Lista de categorías
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(categories) { category in
                        CategoryItem(
                            category: category,
                            onEdit: {
                                categoryToEdit = category
                                editCategoryName = category.name
                                showingEditSheet = true
                            },
                            onDelete: {
                                categoryToDelete = category
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Add Category Sheet
    private var addCategorySheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre de la categoría")
                        .font(.headline)
                    
                    TextField("Ej: Trabajo, Personal, Ideas...", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addCategory()
                        }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Crear Categoría",
                        isEnabled: !newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ) {
                        addCategory()
                    }
                    
                    SecondaryButton(title: "Cancelar") {
                        showingAddSheet = false
                        newCategoryName = ""
                    }
                }
            }
            .padding()
            .navigationTitle("Nueva Categoría")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
        }
    }
    
    // MARK: - Edit Category Sheet
    private var editCategorySheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre de la categoría")
                        .font(.headline)
                    
                    TextField("Nombre de la categoría", text: $editCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            updateCategory()
                        }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Guardar Cambios",
                        isEnabled: !editCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ) {
                        updateCategory()
                    }
                    
                    SecondaryButton(title: "Cancelar") {
                        showingEditSheet = false
                        categoryToEdit = nil
                        editCategoryName = ""
                    }
                }
            }
            .padding()
            .navigationTitle("Editar Categoría")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
        }
    }
    
    // MARK: - Delete Alert
    private var deleteAlert: some View {
        Group {
            Button("Eliminar", role: .destructive) {
                deleteCategory()
            }
            Button("Cancelar", role: .cancel) {
                categoryToDelete = nil
            }
        }
    }
    
    // MARK: - CRUD Functions
    private func addCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newCategory = Category(name: trimmedName)
        modelContext.insert(newCategory)
        
        do {
            try modelContext.save()
            print("✅ Categoría '\(trimmedName)' creada exitosamente")
        } catch {
            print("❌ Error al crear categoría: \(error)")
        }
        
        showingAddSheet = false
        newCategoryName = ""
    }
    
    private func updateCategory() {
        guard let category = categoryToEdit else { return }
        let trimmedName = editCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        category.updateName(trimmedName)
        
        do {
            try modelContext.save()
            print("✅ Categoría actualizada a '\(trimmedName)'")
        } catch {
            print("❌ Error al actualizar categoría: \(error)")
        }
        
        showingEditSheet = false
        categoryToEdit = nil
        editCategoryName = ""
    }
    
    private func deleteCategory() {
        guard let category = categoryToDelete else { return }
        
        modelContext.delete(category)
        
        do {
            try modelContext.save()
            print("✅ Categoría '\(category.name)' eliminada")
        } catch {
            print("❌ Error al eliminar categoría: \(error)")
        }
        
        categoryToDelete = nil
    }
}