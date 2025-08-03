//
//  CategoriesView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.dependencies) private var dependencies
    
    // MARK: - ViewModel
    @State private var viewModel = CategoriesViewModel()
    
    // MARK: - UI State
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TopBar(title: "Categorías")
                
                if viewModel.isEmpty {
                    emptyStateView
                } else {
                    categoriesListView
                }
            }
            .navigationBarHidden(true)
        }
        .loadingOverlay(viewModel.loadingManager, operation: .fetch)
        .onAppear {
            print("📁 Pestaña Categorías cargada")
            viewModel.configure(with: dependencies.repository, router: dependencies.router)
        }
        .refreshable {
            await viewModel.refreshData()
        }
        // Sheets y Alerts
        .sheet(isPresented: $showingAddSheet) {
            addCategorySheet
        }
        .sheet(isPresented: $showingEditSheet) {
            editCategorySheet
        }
        .alert("⚠️ Eliminar Categoría", isPresented: $showingDeleteAlert) {
            deleteAlert
        } message: {
            Text("Esta acción también eliminará todas las notas relacionadas con esta categoría. No se puede deshacer.")
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
                Text(viewModel.getCategoriesCountText())
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
                    ForEach(viewModel.categories) { category in
                        CategoryItem(
                            category: category,
                            onEdit: {
                                viewModel.prepareForEdit(category)
                                showingEditSheet = true
                            },
                            onDelete: {
                                viewModel.prepareForDelete(category)
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
                    
                    TextField("Ej: Trabajo, Personal, Ideas...", text: $viewModel.newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            viewModel.createCategory()
                            showingAddSheet = false
                        }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Crear Categoría",
                        action: {
                            viewModel.createCategory()
                            showingAddSheet = false
                        },
                        isEnabled: viewModel.isNewCategoryFormValid && !viewModel.loadingManager.isAnyLoading()
                    )
                    
                    SecondaryButton(title: "Cancelar") {
                        showingAddSheet = false
                        viewModel.clearNewCategoryForm()
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
                    
                    TextField("Nombre de la categoría", text: $viewModel.editCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            viewModel.updateCategory()
                            showingEditSheet = false
                        }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Guardar Cambios",
                        action: {
                            viewModel.updateCategory()
                            showingEditSheet = false
                        },
                        isEnabled: viewModel.isEditCategoryFormValid && !viewModel.loadingManager.isAnyLoading()
                    )
                    
                    SecondaryButton(title: "Cancelar") {
                        showingEditSheet = false
                        viewModel.cancelEdit()
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
                viewModel.deleteCategory()
            }
            Button("Cancelar", role: .cancel) {
                viewModel.cancelDelete()
            }
        }
    }
}

#Preview {
    CategoriesView()
        .dependencies(DependencyContainer.preview)
}