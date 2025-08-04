//
//  ContentView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeManager) private var themeManager
    @State private var dependencies: DependencyContainer?
    
    var body: some View {
        Group {
            if let dependencies = dependencies {
                TabView(selection: Binding(
                    get: { dependencies.router.selectedTab.rawValue },
                    set: { dependencies.router.selectedTab = AppRouter.AppTab(rawValue: $0) ?? .home }
                )) {
                    // Pestaña Home
                    HomeView()
                        .dependencies(dependencies)
                        .tabItem {
                            Image(systemName: AppRouter.AppTab.home.icon)
                            Text(AppRouter.AppTab.home.title)
                        }
                        .tag(AppRouter.AppTab.home.rawValue)
                    
                    // Pestaña Notas
                    NotesView()
                        .dependencies(dependencies)
                        .tabItem {
                            Image(systemName: AppRouter.AppTab.notes.icon)
                            Text(AppRouter.AppTab.notes.title)
                        }
                        .tag(AppRouter.AppTab.notes.rawValue)
                    
                    // Pestaña Categorías
                    CategoriesView()
                        .dependencies(dependencies)
                        .tabItem {
                            Image(systemName: AppRouter.AppTab.categories.icon)
                            Text(AppRouter.AppTab.categories.title)
                        }
                        .tag(AppRouter.AppTab.categories.rawValue)
                    
                    // Pestaña Settings
                    SettingsView()
                        .dependencies(dependencies)
                        .tabItem {
                            Image(systemName: AppRouter.AppTab.settings.icon)
                            Text(AppRouter.AppTab.settings.title)
                        }
                        .tag(AppRouter.AppTab.settings.rawValue)
                }
                .accentColor(AppTheme.Colors.accent(for: themeManager.isDarkMode))
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                .background(AppTheme.Colors.backgroundPrimary(for: themeManager.isDarkMode))
            } else {
                // Loading state while dependencies are being initialized
                ProgressView("Inicializando...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.Colors.backgroundPrimary(for: themeManager.isDarkMode))
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            }
        }
        .onAppear {
            if dependencies == nil {
                dependencies = DependencyContainer.debug(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
}