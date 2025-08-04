//
//  SettingsView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.themeManager) private var themeManager
    
    // MARK: - ViewModel
    @State private var viewModel = SettingsViewModel()
    
    // MARK: - UI State
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

                        optionsSection
                        
                        dangerZoneSection
                        
                        Spacer().frame(height: 40)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .loadingOverlay(viewModel.loadingManager, operation: .deleteAll)
        .onAppear {
            print("⚙️ Pestaña Ajustes cargada")
            viewModel.configure(with: dependencies.repository, router: dependencies.router)
        }
        .refreshable {
            await viewModel.refreshData()
        }
        // Alerts de confirmación
        .alert("⚠️ Eliminar Categorías", isPresented: $showingDeleteCategoriesAlert) {
            deleteCategoriesAlert
        } message: {
            Text("Esta acción también eliminará todas las notas relacionadas con estas categorías. No se puede deshacer.")
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
                Text(viewModel.getAppName())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Versión \(viewModel.getAppVersion())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.Colors.surface(for: themeManager.isDarkMode))
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
                    count: viewModel.categoriesCount,
                    color: .sageGreen
                )
                
                // Notas
                StatCard(
                    icon: "note.text",
                    title: "Notas",
                    count: viewModel.notesCount,
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
                    subtitle: viewModel.getCategoriesSubtitle(),
                    icon: "folder.badge.minus",
                    isEnabled: viewModel.hasCategories && !viewModel.loadingManager.isAnyLoading()
                ) {
                    showingDeleteCategoriesAlert = true
                }
                
                DangerButton(
                    title: "Eliminar todas las notas",
                    subtitle: viewModel.getNotesSubtitle(),
                    icon: "note.text.badge.minus",
                    isEnabled: viewModel.hasNotes && !viewModel.loadingManager.isAnyLoading()
                ) {
                    showingDeleteNotesAlert = true
                }
                
                DangerButton(
                    title: "Borrar todo",
                    subtitle: "Elimina todas las notas y categorías",
                    icon: "trash.fill",
                    isEnabled: viewModel.hasAnyData && !viewModel.loadingManager.isAnyLoading(),
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
            Button(viewModel.getDeleteCategoriesAlertTitle(), role: .destructive) {
                viewModel.deleteAllCategories()
            }
            Button("Cancelar", role: .cancel) { }
        }
    }
    
    private var deleteNotesAlert: some View {
        Group {
            Button(viewModel.getDeleteNotesAlertTitle(), role: .destructive) {
                viewModel.deleteAllNotes()
            }
            Button("Cancelar", role: .cancel) { }
        }
    }
    
    private var deleteAllAlert: some View {
        Group {
            Button("¡SÍ, BORRAR TODO!", role: .destructive) {
                viewModel.deleteEverything()
            }
            Button("Cancelar", role: .cancel) { }
        }
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Opciones")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                themeToggleRow
            }
        }
    }
    
    private var themeToggleRow: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                .font(.title3)
                .foregroundColor(viewModel.themeManager.isDarkMode ? .blue : .orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Tema oscuro")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.textPrimary(for: viewModel.themeManager.isDarkMode))
                
                Text(viewModel.themeManager.isDarkMode ? "Activado" : "Desactivado")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary(for: viewModel.themeManager.isDarkMode))
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { viewModel.themeManager.isDarkMode },
                set: { _ in viewModel.toggleTheme() }
            ))
                .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.accent(for: viewModel.themeManager.isDarkMode)))
        }
        .padding()
        .background(AppTheme.Colors.cardBackground(for: viewModel.themeManager.isDarkMode))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
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
        .background(AppTheme.Colors.surface(for: ThemeManager.shared.isDarkMode))
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
            .background(isEnabled ? AppTheme.Colors.cardBackground(for: ThemeManager.shared.isDarkMode) : Color.gray.opacity(0.1))
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
        .dependencies(DependencyContainer.preview)
}