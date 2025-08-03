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
                .foregroundColor(searchText.isEmpty ? .gray : .sageGreen)
                .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
            
            // Campo de texto
            TextField(placeholder, text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isSearchFocused)
                .onChange(of: searchText) { oldValue, newValue in
                    onSearchChanged(newValue)
                }
                .onSubmit {
                    isSearchFocused = false
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
                        .foregroundColor(.gray)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSearchFocused ? Color.sageGreen : Color.sageLight,
                            lineWidth: isSearchFocused ? 2 : 1
                        )
                        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                )
        )
        .shadow(
            color: isSearchFocused ? Color.sageGreen.opacity(0.1) : Color.gray.opacity(0.05),
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
}