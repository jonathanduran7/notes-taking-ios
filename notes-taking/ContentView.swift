//
//  ContentView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Pestaña Home
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Pestaña Notas
            NotesView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notas")
                }
                .tag(1)
            
            // Pestaña Categorías
            CategoriesView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Categorías")
                }
                .tag(2)
            
            // Pestaña Settings
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Ajustes")
                }
                .tag(3)
        }
        .accentColor(.appAccent)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToNotesTab"))) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = 1
            }
            print("🔄 Cambiando a la pestaña de Notas")
        }
    }
}

#Preview {
    ContentView()
}