//
//  ContentView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var router = AppRouter()
    
    var body: some View {
        TabView(selection: Binding(
            get: { router.selectedTab.rawValue },
            set: { router.selectedTab = AppRouter.AppTab(rawValue: $0) ?? .home }
        )) {
            // Pestaña Home
            HomeView(router: router)
                .tabItem {
                    Image(systemName: AppRouter.AppTab.home.icon)
                    Text(AppRouter.AppTab.home.title)
                }
                .tag(AppRouter.AppTab.home.rawValue)
            
            // Pestaña Notas
            NotesView(router: router)
                .tabItem {
                    Image(systemName: AppRouter.AppTab.notes.icon)
                    Text(AppRouter.AppTab.notes.title)
                }
                .tag(AppRouter.AppTab.notes.rawValue)
            
            // Pestaña Categorías
            CategoriesView(router: router)
                .tabItem {
                    Image(systemName: AppRouter.AppTab.categories.icon)
                    Text(AppRouter.AppTab.categories.title)
                }
                .tag(AppRouter.AppTab.categories.rawValue)
            
            // Pestaña Settings
            SettingsView(router: router)
                .tabItem {
                    Image(systemName: AppRouter.AppTab.settings.icon)
                    Text(AppRouter.AppTab.settings.title)
                }
                .tag(AppRouter.AppTab.settings.rawValue)
        }
        .accentColor(.appAccent)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}