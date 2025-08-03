//
//  SettingsView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Query private var notes: [Notes]
    
    @State private var showingDeleteCategoriesAlert = false
    @State private var showingDeleteNotesAlert = false
    @State private var showingDeleteAllAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TopBar(title: "Ajustes")
                
                ScrollView {
                    VStack(spacing: 24) {
                        appInfoSection
                        
                        statisticsSection
                        
                        dangerZoneSection
                        
                        Spacer().frame(height: 40)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            print("⚙️ Pestaña Ajustes cargada")
        }
        // Alerts de confirmación
        .alert("Eliminar Categorías", isPresented: $showingDeleteCategoriesAlert) {
            deleteCategoriesAlert
        }
        .alert("Eliminar Notas", isPresented: $showingDeleteNotesAlert) {
            deleteNotesAlert
        }
        .alert("¡Cuidado!", isPresented: $showingDeleteAllAlert) {
            deleteAllAlert
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.sageMedium.opacity(0.3), Color.sageLight.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "note.text")
                    .font(.system(size: 36))
                    .foregroundColor(.sageGreen)
            }
            
            VStack(spacing: 4) {
                Text("Notes App")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Versión 1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.cream)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadísticas")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                // Categorías
                StatCard(
                    icon: "folder.fill",
                    title: "Categorías",
                    count: categories.count,
                    color: .sageGreen
                )
                
                // Notas
                StatCard(
                    icon: "note.text",
                    title: "Notas",
                    count: notes.count,
                    color: .sageMedium
                )
            }
        }
    }
    
    // MARK: - Danger Zone Section
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Zona de Peligro")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.red)
            
            Text("Las siguientes acciones no se pueden deshacer")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                DangerButton(
                    title: "Eliminar todas las categorías",
                    subtitle: "\(categories.count) categoría\(categories.count == 1 ? "" : "s")",
                    icon: "folder.badge.minus",
                    isEnabled: !categories.isEmpty
                ) {
                    showingDeleteCategoriesAlert = true
                }
                
                DangerButton(
                    title: "Eliminar todas las notas",
                    subtitle: "\(notes.count) nota\(notes.count == 1 ? "" : "s")",
                    icon: "note.text.badge.minus",
                    isEnabled: !notes.isEmpty
                ) {
                    showingDeleteNotesAlert = true
                }
                
                DangerButton(
                    title: "Borrar todo",
                    subtitle: "Elimina todas las notas y categorías",
                    icon: "trash.fill",
                    isEnabled: !categories.isEmpty || !notes.isEmpty,
                    isDestructive: true
                ) {
                    showingDeleteAllAlert = true
                }
            }
        }
    }
    
    // MARK: - Alerts
    private var deleteCategoriesAlert: some View {
        Group {
            Button("Eliminar \(categories.count) categoría\(categories.count == 1 ? "" : "s")", role: .destructive) {
                deleteAllCategories()
            }
            Button("Cancelar", role: .cancel) { }
        }
    }
    
    private var deleteNotesAlert: some View {
        Group {
            Button("Eliminar \(notes.count) nota\(notes.count == 1 ? "" : "s")", role: .destructive) {
                deleteAllNotes()
            }
            Button("Cancelar", role: .cancel) { }
        }
    }
    
    private var deleteAllAlert: some View {
        Group {
            Button("¡SÍ, BORRAR TODO!", role: .destructive) {
                deleteEverything()
            }
            Button("Cancelar", role: .cancel) { }
        }
    }
    
    // MARK: - Delete Functions
    private func deleteAllCategories() {
        let count = categories.count
        
        for category in categories {
            modelContext.delete(category)
        }
        
        do {
            try modelContext.save()
            print("✅ Se eliminaron \(count) categorías exitosamente")
        } catch {
            print("❌ Error al eliminar categorías: \(error)")
        }
    }
    
    private func deleteAllNotes() {
        let count = notes.count
        
        for note in notes {
            modelContext.delete(note)
        }
        
        do {
            try modelContext.save()
            print("✅ Se eliminaron \(count) notas exitosamente")
        } catch {
            print("❌ Error al eliminar notas: \(error)")
        }
    }
    
    private func deleteEverything() {
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
        } catch {
            print("❌ Error al eliminar todo: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.cream)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct DangerButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isEnabled: Bool
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isEnabled ? (isDestructive ? .red : .orange) : .gray)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isEnabled ? .primary : .gray)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(isEnabled ? Color.white : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEnabled ? (isDestructive ? Color.red.opacity(0.3) : Color.orange.opacity(0.3)) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    SettingsView()
}