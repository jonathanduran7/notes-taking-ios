//
//  NotesView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Notes.updatedAt, order: .reverse) private var notes: [Notes]
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var noteToEdit: Notes?
    @State private var noteToDelete: Notes?
    
    @State private var formTitle = ""
    @State private var formContent = ""
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TopBar(title: "Mis Notas")
                
                if categories.isEmpty { 
                    emptyStateViewCategories
                } else if notes.isEmpty {
                    emptyStateView
                } else {
                    notesListView
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            print("📝 Pestaña Notas cargada")
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
        }.padding(.horizontal)
    }
    
    // MARK: - Empty State
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
                Text("\(notes.count) nota\(notes.count == 1 ? "" : "s")")
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
                    ForEach(notes) { note in
                        NoteItem(
                            note: note,
                            onEdit: {
                                noteToEdit = note
                                formTitle = note.title
                                formContent = note.content
                                selectedCategory = note.category
                                showingEditSheet = true
                            },
                            onDelete: {
                                noteToDelete = note
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Add Note Sheet
    private var addNoteSheet: some View {
        NavigationView {
            noteFormView(
                title: "Nueva Nota",
                primaryButtonTitle: "Crear Nota",
                primaryAction: addNote,
                secondaryAction: {
                    showingAddSheet = false
                    clearForm()
                }
            )
        }
    }
    
    // MARK: - Edit Note Sheet
    private var editNoteSheet: some View {
        NavigationView {
            noteFormView(
                title: "Editar Nota",
                primaryButtonTitle: "Guardar Cambios",
                primaryAction: updateNote,
                secondaryAction: {
                    showingEditSheet = false
                    noteToEdit = nil
                    clearForm()
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
                
                TextField("Escribe el título...", text: $formTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Categoría
            VStack(alignment: .leading, spacing: 8) {
                Text("Categoría")
                    .font(.headline)
                
                if categories.isEmpty {
                    Text("No hay categorías. Crea una en la pestaña Categorías.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                } else {
                    Menu {
                        Button("Sin categoría") {
                            selectedCategory = nil
                        }
                        
                        ForEach(categories) { category in
                            Button(category.name) {
                                selectedCategory = category
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory?.name ?? "Seleccionar categoría")
                                .foregroundColor(selectedCategory == nil ? .gray : .primary)
                            
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
                
                TextEditor(text: $formContent)
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
                    isEnabled: !formTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                deleteNote()
            }
            Button("Cancelar", role: .cancel) {
                noteToDelete = nil
            }
        }
    }
    
    // MARK: - CRUD Functions
    private func addNote() {
        let trimmedTitle = formTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newNote = Notes(
            title: trimmedTitle,
            content: formContent,
            category: selectedCategory
        )
        
        modelContext.insert(newNote)
        
        do {
            try modelContext.save()
            print("✅ Nota '\(trimmedTitle)' creada exitosamente")
        } catch {
            print("❌ Error al crear nota: \(error)")
        }
        
        showingAddSheet = false
        clearForm()
    }
    
    private func updateNote() {
        guard let note = noteToEdit else { return }
        let trimmedTitle = formTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        note.update(
            title: trimmedTitle,
            content: formContent,
            category: selectedCategory
        )
        
        do {
            try modelContext.save()
            print("✅ Nota '\(trimmedTitle)' actualizada")
        } catch {
            print("❌ Error al actualizar nota: \(error)")
        }
        
        showingEditSheet = false
        noteToEdit = nil
        clearForm()
    }
    
    private func deleteNote() {
        guard let note = noteToDelete else { return }
        
        modelContext.delete(note)
        
        do {
            try modelContext.save()
            print("✅ Nota '\(note.title)' eliminada")
        } catch {
            print("❌ Error al eliminar nota: \(error)")
        }
        
        noteToDelete = nil
    }
    
    private func clearForm() {
        formTitle = ""
        formContent = ""
        selectedCategory = nil
    }
}