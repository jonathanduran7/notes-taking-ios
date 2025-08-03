//
//  HomeView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.dependencies) private var dependencies
    
    // MARK: - ViewModel
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(title: viewModel.isSearching ? "Buscar" : "Home")
            
            SearchBar(searchText: $viewModel.searchText) { text in
                viewModel.updateSearchText(text)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .disabledWhileLoading(viewModel.loadingManager)
            
            if viewModel.isSearching {
                searchResultsView
            } else {
                homeContentView
            }
        }
        .loadingOverlay(viewModel.loadingManager, operation: .fetch)
        .onAppear {
            print("Pestaña Home cargada")
            viewModel.configure(with: dependencies.repository, router: dependencies.router)
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
    
    // MARK: - Home Content (vista normal)
    private var homeContentView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 16)
            
            // Categorías horizontales
            if viewModel.hasCategories {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Categorías")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(viewModel.getCategoriesCountText())
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
                            ForEach(viewModel.categories) { category in
                                Cards(category: category)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer().frame(height: 24)
            
            // Últimas notas
            HistoryNotes(router: dependencies.router)
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
                
                if viewModel.loadingManager.isLoading(.search) {
                    LoadingIndicator(operation: .search)
                } else if viewModel.hasSearchResults {
                    Text(viewModel.getSearchResultsCountText())
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
            
            // Content based on search state
            if viewModel.loadingManager.isLoading(.search) {
                searchLoadingView
            } else if let errorMessage = viewModel.loadingManager.getState(for: .search).errorMessage {
                searchErrorView(errorMessage)
            } else if !viewModel.hasSearchResults {
                emptySearchView
            } else {
                searchResultsList
            }
        }
    }
    
    // MARK: - Search Loading View
    private var searchLoadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            InlineLoadingView(
                operation: .search,
                message: "Buscando en todas las notas..."
            )
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: - Search Error View
    private func searchErrorView(_ errorMessage: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            ErrorView(
                message: errorMessage
            ) {
                Task {
                    _ = await viewModel.performAsyncSearch(viewModel.searchText)
                }
            }
            .padding()
            
            Spacer()
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
            }
            .frame(maxWidth: .infinity)
            
            // Sugerencias de búsqueda
            if viewModel.hasNotes {
                VStack(spacing: 8) {
                    Text("Sugerencias:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                            Button(action: {
                                viewModel.applySuggestion(suggestion)
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
                ForEach(viewModel.filteredNotes) { note in
                    SearchResultItem(
                        note: note,
                        viewModel: viewModel,
                        onTap: {
                            viewModel.navigateToNoteDetail(note)
                        }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Search Result Item Component
struct SearchResultItem: View {
    let note: Notes
    let viewModel: HomeViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header con título y categoría
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // Título con highlight
                        Text(viewModel.highlightedText(note.title))
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
                                
                                Text(viewModel.highlightedText(category.name))
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
                    Text(viewModel.highlightedText(viewModel.getPreview(for: note.content)))
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
}

#Preview {
    HomeView()
        .dependencies(DependencyContainer.preview)
}