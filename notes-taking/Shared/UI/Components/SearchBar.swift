//
//  SearchBar.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    let onSearchChanged: (String) -> Void
    let placeholder: String
    
    @FocusState private var isSearchFocused: Bool
    @Environment(\.themeManager) private var themeManager
    
    init(searchText: Binding<String>, placeholder: String = "Buscar notas...", onSearchChanged: @escaping (String) -> Void = { _ in }) {
        self._searchText = searchText
        self.placeholder = placeholder
        self.onSearchChanged = onSearchChanged
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Ícono de búsqueda
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundColor(searchText.isEmpty ? 
                    AppTheme.Colors.textSecondary(for: themeManager.isDarkMode) : 
                    AppTheme.Colors.accent(for: themeManager.isDarkMode))
                .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
            
            // Campo de texto con placeholder personalizado
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text(placeholder)
                        .foregroundColor(AppTheme.Colors.textSecondary(for: themeManager.isDarkMode))
                        .allowsHitTesting(false)
                }
                
                TextField("", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isSearchFocused)
                    .foregroundColor(AppTheme.Colors.textPrimary(for: themeManager.isDarkMode))
                    .onChange(of: searchText) { oldValue, newValue in
                        onSearchChanged(newValue)
                    }
                    .onSubmit {
                        isSearchFocused = false
                    }
            }
            
            // Botón para limpiar
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    onSearchChanged("")
                    isSearchFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.textSecondary(for: themeManager.isDarkMode))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.Colors.cardBackground(for: themeManager.isDarkMode))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSearchFocused ? 
                                AppTheme.Colors.accent(for: themeManager.isDarkMode) : 
                                AppTheme.Colors.backgroundSecondary(for: themeManager.isDarkMode),
                            lineWidth: isSearchFocused ? 2 : 1
                        )
                        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                )
        )
        .shadow(
            color: isSearchFocused ? 
                AppTheme.Colors.accent(for: themeManager.isDarkMode).opacity(0.1) : 
                Color.gray.opacity(0.05),
            radius: isSearchFocused ? 6 : 2,
            x: 0,
            y: isSearchFocused ? 3 : 1
        )
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
    }
}

#Preview {
    @Previewable @State var searchText = ""
    
    return VStack(spacing: 20) {
        SearchBar(searchText: $searchText) { text in
            print("Searching for: \(text)")
        }
        
        SearchBar(searchText: .constant("Ejemplo de búsqueda")) { _ in }
    }
    .padding()
    .background(AppTheme.Colors.backgroundPrimary(for: false))
    .environment(\.themeManager, ThemeManager.shared)
}