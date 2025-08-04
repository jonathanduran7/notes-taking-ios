//
//  TopBar.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct TopBar: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Main header content
            HStack(spacing: 16) {
                // Leading content
                HStack(spacing: 12) {
                    // Decorative accent dot
                    Circle()
                        .fill(Color.sageGreen)
                        .frame(width: 8, height: 8)
                    
                    // Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        // Subtle subtitle
                        Text(getCurrentGreeting())
                            .font(.caption)
                            .foregroundColor(.sageGreen)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.cream, location: 0.0),
                        .init(color: Color.cream.opacity(0.95), location: 0.7),
                        .init(color: Color.sageLight.opacity(0.1), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.sageLight.opacity(0.5),
                            Color.sageMedium.opacity(0.3),
                            Color.sageLight.opacity(0.5)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
        .shadow(
            color: Color.sageGreen.opacity(0.08),
            radius: 8,
            x: 0,
            y: 2
        )
    }
    
    private func getCurrentGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Buenos días"
        case 12..<18:
            return "Buenas tardes"
        default:
            return "Buenas noches"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TopBar(title: "Mis Notas")
        TopBar(title: "Categorías")
        TopBar(title: "Configuración")
        
        Spacer()
    }
    .background(Color.gray.opacity(0.1))
}