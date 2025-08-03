//
//  ContentView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            // Pestaña Home
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            // Pestaña Notas
            NotesView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notas")
                }
            
            // Pestaña Categorías
            CategoriesView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Categorías")
                }
            
            // Pestaña Settings
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Ajustes")
                }
        }
        .accentColor(Color(red: 0.51, green: 0.60, blue: 0.57))
    }
}

#Preview {
    ContentView()
}
