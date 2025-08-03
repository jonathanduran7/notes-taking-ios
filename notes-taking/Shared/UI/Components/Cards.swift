//
//  Cards.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct Cards: View {
    let category: Category
    
    private let sageGreen = Color(red: 0.51, green: 0.60, blue: 0.57) // #819A91
    private let sageMedium = Color(red: 0.65, green: 0.76, blue: 0.66) // #A7C1A8
    private let sageLight = Color(red: 0.82, green: 0.85, blue: 0.75) // #D1D8BE
    private let cream = Color(red: 0.93, green: 0.94, blue: 0.88) // #EEEFE0
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [sageMedium.opacity(0.3), sageLight.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundColor(sageGreen)
            }
            
            Text(category.name)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                //TODO: conectar con notes count
                Text("0")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 140, height: 140)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [cream, cream.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(sageLight, lineWidth: 1)
        )
        .shadow(
            color: sageGreen.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: category.name)
    }
}

#Preview {
    HStack(spacing: 16) {
        Cards(category: Category(name: "Trabajo"))
        Cards(category: Category(name: "Personal"))
        Cards(category: Category(name: "Ideas Creativas"))
    }
    .padding()
}