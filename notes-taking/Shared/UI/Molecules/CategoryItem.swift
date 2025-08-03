//
//  CategoryItem.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct CategoryItem: View {
    let category: Category
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    private let sageLight = Color(red: 0.82, green: 0.85, blue: 0.75) // #D1D8BE
    private let cream = Color(red: 0.93, green: 0.94, blue: 0.88) // #EEEFE0
    private let sageGreen = Color(red: 0.51, green: 0.60, blue: 0.57) // #819A91
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(sageGreen)
                        .font(.title2)
                    
                    Text(category.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Text("Creada: \(category.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundColor(sageGreen)
                        .frame(width: 32, height: 32)
                        .background(cream)
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
        .padding()
        .frame(maxWidth: .infinity)
        .background(cream)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        CategoryItem(
            category: Category(name: "Trabajo"),
            onEdit: { print("Editar Trabajo") },
            onDelete: { print("Eliminar Trabajo") }
        )
        
        CategoryItem(
            category: Category(name: "Personal"),
            onEdit: { print("Editar Personal") },
            onDelete: { print("Eliminar Personal") }
        )
    }
    .padding()
}