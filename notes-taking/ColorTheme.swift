//
//  ColorTheme.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

// MARK: - Extensión de Color para el tema de la app
extension Color {
    
    // MARK: - Paleta de colores principal
    /// Sage Dark - Color principal de la app (#819A91)
    static let sageGreen = Color(red: 0.51, green: 0.60, blue: 0.57)
    
    /// Sage Medium - Color intermedio (#A7C1A8)
    static let sageMedium = Color(red: 0.65, green: 0.76, blue: 0.66)
    
    /// Sage Light - Color claro (#D1D8BE)
    static let sageLight = Color(red: 0.82, green: 0.85, blue: 0.75)
    
    /// Cream - Color de fondo principal (#EEEFE0)
    static let cream = Color(red: 0.93, green: 0.94, blue: 0.88)
    
    // MARK: - Colores semánticos
    /// Color de acento principal
    static let appAccent = sageGreen
    
    /// Color de fondo primario
    static let appBackground = cream
    
    /// Color de superficie para cards
    static let appSurface = cream
}

// MARK: - Gradientes del tema
struct AppGradients {
    /// Gradiente principal de sage medium a sage light
    static let sagePrimary = LinearGradient(
        gradient: Gradient(colors: [Color.sageMedium.opacity(0.3), Color.sageLight.opacity(0.5)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Gradiente de fondo cream
    static let creamBackground = LinearGradient(
        gradient: Gradient(colors: [Color.cream, Color.cream.opacity(0.8)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}