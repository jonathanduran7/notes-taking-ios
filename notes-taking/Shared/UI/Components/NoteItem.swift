//
//  NoteItem.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct NoteItem: View {
    let note: Notes
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header con título y acciones
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Categoría
                    if let category = note.category {
                        HStack(spacing: 4) {
                            Image(systemName: "folder.fill")
                                .font(.caption2)
                                .foregroundColor(Color.sageGreen)
                            
                            Text(category.name)
                                .font(.caption)
                                .foregroundColor(Color.sageGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.sageLight.opacity(0.3))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                // Botones de acción
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.title3)
                            .foregroundColor(Color.sageGreen)
                            .frame(width: 32, height: 32)
                            .background(Color.cream)
                            .cornerRadius(6)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
            
            // Contenido de la nota (truncado)
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            } else {
                Text("Sin contenido")
                    .font(.body)
                    .foregroundColor(.gray)
                    .italic()
            }
            
            Spacer()
            
            // Footer con fecha
            HStack {
                Text("Actualizada: \(note.updatedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Indicador de longitud del contenido
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Text("\(note.content.count) caracteres")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cream)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}