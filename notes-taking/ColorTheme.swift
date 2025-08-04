//
//  ColorTheme.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

// MARK: - Extensión de Color para el tema de la app
extension Color {
    
    // MARK: - Paleta de colores principal (compatibilidad con código existente)
    /// Sage Dark - Color principal de la app (#819A91)
    static let sageGreen = Color(red: 0.51, green: 0.60, blue: 0.57)
    
    /// Sage Medium - Color intermedio (#A7C1A8)
    static let sageMedium = Color(red: 0.65, green: 0.76, blue: 0.66)
    
    /// Sage Light - Color claro (#D1D8BE)
    static let sageLight = Color(red: 0.82, green: 0.85, blue: 0.75)
    
    /// Cream - Color de fondo principal (#EEEFE0)
    static let cream = Color(red: 0.93, green: 0.94, blue: 0.88)
    
    // MARK: - Colores semánticos (ahora dinámicos)
    /// Color de acento principal - ahora dinámico según el tema
    static var appAccent: Color {
        AppTheme.Colors.accent(for: ThemeManager.shared.isDarkMode)
    }
    
    /// Color de fondo primario - ahora dinámico según el tema
    static var appBackground: Color {
        AppTheme.Colors.backgroundPrimary(for: ThemeManager.shared.isDarkMode)
    }
    
    /// Color de superficie para cards - ahora dinámico según el tema
    static var appSurface: Color {
        AppTheme.Colors.surface(for: ThemeManager.shared.isDarkMode)
    }
}

// MARK: - Gradientes del tema (ahora dinámicos)
struct AppGradients {
    /// Gradiente principal - ahora dinámico según el tema
    static var sagePrimary: LinearGradient {
        AppTheme.Gradients.sagePrimary(for: ThemeManager.shared.isDarkMode)
    }
    
    /// Gradiente de fondo - ahora dinámico según el tema
    static var backgroundGradient: LinearGradient {
        AppTheme.Gradients.backgroundGradient(for: ThemeManager.shared.isDarkMode)
    }
    
    /// Gradiente de fondo cream (compatibilidad con código existente)
    static var creamBackground: LinearGradient {
        AppTheme.Gradients.backgroundGradient(for: ThemeManager.shared.isDarkMode)
    }
}