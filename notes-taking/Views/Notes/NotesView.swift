//
//  NotesView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.dependencies) private var dependencies
    
    // MARK: - ViewModel
    @State private var viewModel = NotesViewModel()
    
    // MARK: - UI State
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TopBar(title: "Mis Notas")
                
                if viewModel.categoriesEmpty { 
                    emptyStateViewCategories
                } else if viewModel.isEmpty {
                    emptyStateView
                } else {
                    notesListView
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            print("📝 Pestaña Notas cargada")
            viewModel.configure(with: dependencies.repository, router: dependencies.router)
        }
        // Sheets y Alerts
        .sheet(isPresented: $showingAddSheet) {
            addNoteSheet
        }
        .sheet(isPresented: $showingEditSheet) {
            editNoteSheet
        }
        .alert("Eliminar Nota", isPresented: $showingDeleteAlert) {
            deleteAlert
        }
    }

    // MARK: - Empty States
    private var emptyStateViewCategories: some View {
        VStack(spacing: 20) {     
            Spacer()
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(Color.sageGreen.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No tienes categorías")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Crea tu primera categoría para organizar tus notas")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(Color.sageGreen.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No tienes notas")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Crea tu primera nota para comenzar a escribir")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                PrimaryButton(title: "Crear Primera Nota") {
                    showingAddSheet = true
                }
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)
        }
        .padding()
    }
    
    // MARK: - Notes List
    private var notesListView: some View {
        VStack(spacing: 0) {
            // Header con contador y botón agregar
            HStack {
                Text(viewModel.getNotesCountText())
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: { showingAddSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Nueva Nota")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.sageGreen)
                }
            }
            .padding()
            
            // Lista de notas
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.notes) { note in
                        NoteItem(
                            note: note,
                            onEdit: {
                                viewModel.prepareForEdit(note)
                                showingEditSheet = true
                            },
                            onDelete: {
                                viewModel.prepareForDelete(note)
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Sheets
    private var addNoteSheet: some View {
        NavigationView {
            noteFormView(
                title: "Nueva Nota",
                primaryButtonTitle: "Crear Nota",
                primaryAction: {
                    viewModel.createNote()
                    showingAddSheet = false
                },
                secondaryAction: {
                    showingAddSheet = false
                    viewModel.clearForm()
                }
            )
        }
    }
    
    private var editNoteSheet: some View {
        NavigationView {
            noteFormView(
                title: "Editar Nota",
                primaryButtonTitle: "Guardar Cambios",
                primaryAction: {
                    viewModel.updateNote()
                    showingEditSheet = false
                },
                secondaryAction: {
                    showingEditSheet = false
                    viewModel.cancelEdit()
                }
            )
        }
    }
    
    // MARK: - Note Form View
    private func noteFormView(
        title: String,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        secondaryAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 24) {
            // Título
            VStack(alignment: .leading, spacing: 8) {
                Text("Título de la nota")
                    .font(.headline)
                
                TextField("Escribe el título...", text: $viewModel.formTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Categoría
            VStack(alignment: .leading, spacing: 8) {
                Text("Categoría")
                    .font(.headline)
                
                if !viewModel.hasCategoriesAvailable() {
                    Text("No hay categorías. Crea una en la pestaña Categorías.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                } else {
                    Menu {
                        Button("Sin categoría") {
                            viewModel.selectedCategory = nil
                        }
                        
                        ForEach(viewModel.categories) { category in
                            Button(category.name) {
                                viewModel.selectedCategory = category
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.getCategoryPlaceholderText())
                                .foregroundColor(viewModel.getCategoryTextColor())
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Contenido
            VStack(alignment: .leading, spacing: 8) {
                Text("Contenido")
                    .font(.headline)
                
                TextEditor(text: $viewModel.formContent)
                    .frame(minHeight: 150)
                    .padding(4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // Botones
            VStack(spacing: 12) {
                PrimaryButton(
                    title: primaryButtonTitle,
                    action: primaryAction,
                    isEnabled: viewModel.isFormValid
                )
                
                SecondaryButton(title: "Cancelar") {
                    secondaryAction()
                }
            }
        }
        .padding()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
    }
    
    // MARK: - Delete Alert
    private var deleteAlert: some View {
        Group {
            Button("Eliminar", role: .destructive) {
                viewModel.deleteNote()
            }
            Button("Cancelar", role: .cancel) {
                viewModel.cancelDelete()
            }
        }
    }
}

#Preview {
    NotesView()
        .dependencies(DependencyContainer.preview)
}