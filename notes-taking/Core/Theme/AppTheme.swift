//
//  AppTheme.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

/// Sistema de tema centralizado para toda la aplicación
struct AppTheme {
    
    // MARK: - Paleta de colores principal
    struct Colors {
        /// Sage Dark - Color principal de la app (#819A91)
        static let sageGreen = Color(red: 0.51, green: 0.60, blue: 0.57)
        
        /// Sage Medium - Color intermedio (#A7C1A8)
        static let sageMedium = Color(red: 0.65, green: 0.76, blue: 0.66)
        
        /// Sage Light - Color claro (#D1D8BE)
        static let sageLight = Color(red: 0.82, green: 0.85, blue: 0.75)
        
        /// Cream - Color de fondo principal (#EEEFE0)
        static let cream = Color(red: 0.93, green: 0.94, blue: 0.88)
        
        // MARK: - Colores derivados
        /// Color de acento principal para elementos interactivos
        static let accent = sageGreen
        
        /// Color de fondo primario
        static let backgroundPrimary = cream
        
        /// Color de fondo secundario
        static let backgroundSecondary = sageLight
        
        /// Color para elementos de superficie
        static let surface = cream
        
        // MARK: - Colores semánticos
        /// Color para elementos destructivos
        static let destructive = Color.red
        
        /// Color para texto secundario
        static let textSecondary = Color.gray
    }
    
    // MARK: - Gradientes
    struct Gradients {
        /// Gradiente principal de sage medium a sage light
        static let sagePrimary = LinearGradient(
            gradient: Gradient(colors: [Colors.sageMedium.opacity(0.3), Colors.sageLight.opacity(0.5)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        /// Gradiente de fondo cream
        static let creamBackground = LinearGradient(
            gradient: Gradient(colors: [Colors.cream, Colors.cream.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Sombras
    struct Shadows {
        /// Sombra principal con sage green
        static let primary = Shadow(
            color: Colors.sageGreen.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        
        /// Sombra suave para elementos delicados
        static let soft = Shadow(
            color: Color.gray.opacity(0.2),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

// MARK: - Helper para aplicar sombras
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Extensión para aplicar sombras fácilmente
extension View {
    func appShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// MARK: - Preview para visualizar el tema
#Preview {
    VStack(spacing: 20) {
        // Paleta de colores
        HStack(spacing: 10) {
            Rectangle()
                .fill(AppTheme.Colors.sageGreen)
                .frame(width: 60, height: 60)
                .overlay(Text("Sage\nGreen").font(.caption).foregroundColor(.white))
            
            Rectangle()
                .fill(AppTheme.Colors.sageMedium)
                .frame(width: 60, height: 60)
                .overlay(Text("Sage\nMedium").font(.caption).foregroundColor(.white))
            
            Rectangle()
                .fill(AppTheme.Colors.sageLight)
                .frame(width: 60, height: 60)
                .overlay(Text("Sage\nLight").font(.caption))
            
            Rectangle()
                .fill(AppTheme.Colors.cream)
                .frame(width: 60, height: 60)
                .overlay(Text("Cream").font(.caption))
                .border(Color.gray, width: 1)
        }
        
        // Gradientes
        VStack(spacing: 10) {
            Rectangle()
                .fill(AppTheme.Gradients.sagePrimary)
                .frame(height: 50)
                .overlay(Text("Sage Primary Gradient").font(.caption).foregroundColor(.white))
            
            Rectangle()
                .fill(AppTheme.Gradients.creamBackground)
                .frame(height: 50)
                .overlay(Text("Cream Background Gradient").font(.caption))
                .border(Color.gray, width: 1)
        }
        
        // Ejemplo de componente con tema
        VStack {
            Text("Componente de ejemplo")
                .font(.headline)
                .foregroundColor(AppTheme.Colors.sageGreen)
                .padding()
                .background(AppTheme.Colors.cream)
                .cornerRadius(12)
                .appShadow(AppTheme.Shadows.primary)
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}