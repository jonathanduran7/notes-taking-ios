//
//  HomeView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Category.createdAt, order: .reverse)
    private var categories: [Category]
    
    @Query(sort: \Notes.updatedAt, order: .reverse)
    private var allNotes: [Notes]
    
    @State private var searchText = ""
    @State private var isSearching = false
    
    private var filteredNotes: [Notes] {
        if searchText.isEmpty {
            return []
        }
        
        return allNotes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText) ||
            (note.category?.name.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(title: "Home")
            
            SearchBar(searchText: $searchText) { text in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSearching = !text.isEmpty
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            if isSearching {
                searchResultsView
            } else {
                homeContentView
            }
        }
        .onAppear {
            print("Pestaña Home cargada")
        }
    }
    
    // MARK: - Home Content (vista normal)
    private var homeContentView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 16)
            
            // Categorías horizontales
            if !categories.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Categorías")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(categories.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.sageLight.opacity(0.3))
                            .cornerRadius(4)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories) { category in
                                Cards(category: category)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer().frame(height: 24)
            
            // Últimas notas
            HistoryNotes()
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Search Results View
    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header de resultados
            HStack {
                Text("Resultados de búsqueda")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !filteredNotes.isEmpty {
                    Text("\(filteredNotes.count) nota\(filteredNotes.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.sageGreen.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            if filteredNotes.isEmpty {
                emptySearchView
            } else {
                searchResultsList
            }
        }
    }
    
    // MARK: - Empty Search View
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.sageGreen.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No se encontraron notas")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Intenta con otras palabras clave")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }.frame(maxWidth: .infinity)
            
            // Sugerencias de búsqueda
            if !allNotes.isEmpty {
                VStack(spacing: 8) {
                    Text("Sugerencias:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        ForEach(getSearchSuggestions(), id: \.self) { suggestion in
                            Button(action: {
                                searchText = suggestion
                            }) {
                                Text(suggestion)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.sageLight.opacity(0.3))
                                    .foregroundColor(.sageGreen)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(.top, 16)
            }
            
            Spacer()
        }
        .padding()
    }

    // MARK: - Search Results List
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredNotes) { note in
                    SearchResultItem(
                        note: note,
                        searchTerm: searchText,
                        onTap: {
                            // Navegar a la pestaña de notas
                            NotificationCenter.default.post(name: NSNotification.Name("SwitchToNotesTab"), object: nil)
                            print("🔍 Navegando a nota: \(note.title)")
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Functions
    private func getSearchSuggestions() -> [String] {
        let categoryNames = categories.prefix(3).map { $0.name }
        let recentWords = allNotes.prefix(5).compactMap { note in
            note.title.components(separatedBy: " ").first
        }
        
        return Array(Set(categoryNames + recentWords)).prefix(3).map { String($0) }
    }
}

// MARK: - Search Result Item Component
struct SearchResultItem: View {
    let note: Notes
    let searchTerm: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header con título y categoría
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // Título con highlight
                        Text(highlightedText(note.title, searchTerm: searchTerm))
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        // Categoría
                        if let category = note.category {
                            HStack(spacing: 4) {
                                Image(systemName: "folder.fill")
                                    .font(.caption2)
                                    .foregroundColor(.sageGreen)
                                
                                Text(highlightedText(category.name, searchTerm: searchTerm))
                                    .font(.caption)
                                    .foregroundColor(.sageGreen)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.sageGreen)
                }
                
                // Contenido con highlight
                if !note.content.isEmpty {
                    Text(highlightedText(getPreview(note.content), searchTerm: searchTerm))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Footer
                HStack {
                    Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(note.content.count) caracteres")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cream)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.sageGreen.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getPreview(_ text: String) -> String {
        if text.count <= 100 {
            return text
        }
        
        if let range = text.range(of: searchTerm, options: .caseInsensitive) {
            let start = max(text.startIndex, text.index(range.lowerBound, offsetBy: -30, limitedBy: text.startIndex) ?? text.startIndex)
            let end = min(text.endIndex, text.index(range.upperBound, offsetBy: 30, limitedBy: text.endIndex) ?? text.endIndex)
            return "..." + String(text[start..<end]) + "..."
        }
        
        return String(text.prefix(100)) + "..."
    }
    
    private func highlightedText(_ text: String, searchTerm: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        if let range = attributed.range(of: searchTerm, options: .caseInsensitive) {
            attributed[range].backgroundColor = Color.sageGreen.opacity(0.3)
            attributed[range].foregroundColor = Color.sageGreen
        }
        
        return attributed
    }
}

#Preview {
    HomeView()
}