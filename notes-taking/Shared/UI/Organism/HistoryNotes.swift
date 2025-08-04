//
//  HistoryNotes.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct HistoryNotes: View {
    @Query(sort: \Notes.updatedAt, order: .reverse) private var notes: [Notes]
    
    // MARK: - Dependencies
    let router: AppRouter
    
    var body: some View {
        VStack {
            HStack {
                Text("Últimas notas")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }

            if notes.isEmpty {
                emptyStateView
            } else {
                listNotes
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)
            
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.sageGreen.opacity(0.6))

            VStack(spacing: 8) {
                Text("No hay notas")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("Crea una nota para empezar a escribir")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                router.navigateFromQuickAction(.createNote)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Crear primera nota")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.cream)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.sageGreen)
                .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding(.vertical, 20)
    }

    private var listNotes: some View {
        VStack(spacing: 12) {
            ForEach(notes.prefix(3)) { note in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        if !note.content.isEmpty {
                            Text(note.content)
                                .font(.caption)
                                .lineLimit(2)
                                .foregroundColor(AppTheme.Colors.textSecondary(for: ThemeManager.shared.isDarkMode))
                        }
                        
                        Text(note.updatedAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        router.navigateFromSearch(to: note)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.sageGreen)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.cream)
                .cornerRadius(8)
                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            // Botón "Ver todas las notas" si hay más de 3
            if notes.count > 3 {
                Button(action: {
                    router.navigateFromViewAll(section: "notas")
                }) {
                    HStack {
                        Text("Ver todas las notas (\(notes.count))")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.sageGreen)
                    .padding()
                    .background(Color.sageLight.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding(.top, 8)
            }
        }
    }
}