//
//  AppTheme.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

// MARK: - Theme Manager
@Observable
class ThemeManager {
    static let shared = ThemeManager()
    
    // MARK: - UserDefaults Key
    private let themeKey = "app_theme_is_dark_mode"
    
    var isDarkMode: Bool = false {
        didSet {
            // Guardar en UserDefaults cada vez que cambie
            UserDefaults.standard.set(isDarkMode, forKey: themeKey)
            print("🎨 Tema cambiado a: \(isDarkMode ? "Oscuro" : "Claro") - Guardado en UserDefaults")
        }
    }
    
    private init() {
        // Cargar el tema guardado al inicializar
        loadSavedTheme()
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    // MARK: - Persistence Methods
    private func loadSavedTheme() {
        if UserDefaults.standard.object(forKey: themeKey) != nil {
            isDarkMode = UserDefaults.standard.bool(forKey: themeKey)
            print("📱 Tema cargado desde UserDefaults: \(isDarkMode ? "Oscuro" : "Claro")")
        } else {
            isDarkMode = false
            print("📱 Primera vez usando la app - Tema por defecto: Claro")
        }
    }
    
    func resetToDefault() {
        UserDefaults.standard.removeObject(forKey: themeKey)
        isDarkMode = false
    }
}

// MARK: - Theme Mode
enum ThemeMode {
    case light
    case dark
}

/// Sistema de tema centralizado para toda la aplicación
struct AppTheme {
    
    // MARK: - Paleta de colores principal
    struct Colors {
        // MARK: - Colores base (sin tema específico)
        /// Sage Dark - Color principal de la app (#819A91)
        static let sageGreen = Color(red: 0.51, green: 0.60, blue: 0.57)
        
        /// Sage Medium - Color intermedio (#A7C1A8)
        static let sageMedium = Color(red: 0.65, green: 0.76, blue: 0.66)
        
        /// Sage Light - Color claro (#D1D8BE)
        static let sageLight = Color(red: 0.82, green: 0.85, blue: 0.75)
        
        /// Cream - Color de fondo principal modo claro (#EEEFE0)
        static let cream = Color(red: 0.93, green: 0.94, blue: 0.88)
        
        // MARK: - Colores modo oscuro
        /// Fondo principal modo oscuro (#1C1C1E)
        static let darkBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
        
        /// Superficie modo oscuro (#2C2C2E)
        static let darkSurface = Color(red: 0.17, green: 0.17, blue: 0.18)
        
        /// Superficie secundaria modo oscuro (#38383A)
        static let darkSurfaceSecondary = Color(red: 0.22, green: 0.22, blue: 0.23)
        
        /// Sage adaptado para modo oscuro
        static let darkSageGreen = Color(red: 0.61, green: 0.70, blue: 0.67)
        
        // MARK: - Colores dinámicos según el tema
        static func accent(for isDarkMode: Bool) -> Color {
            isDarkMode ? darkSageGreen : sageGreen
        }
        
        static func backgroundPrimary(for isDarkMode: Bool) -> Color {
            isDarkMode ? darkBackground : cream
        }
        
        static func backgroundSecondary(for isDarkMode: Bool) -> Color {
            isDarkMode ? darkSurface : sageLight
        }
        
        static func surface(for isDarkMode: Bool) -> Color {
            isDarkMode ? darkSurface : cream
        }
        
        static func cardBackground(for isDarkMode: Bool) -> Color {
            isDarkMode ? darkSurfaceSecondary : Color.white
        }
        
        static func textPrimary(for isDarkMode: Bool) -> Color {
            isDarkMode ? Color.white : Color.black
        }
        
        static func textSecondary(for isDarkMode: Bool) -> Color {
            isDarkMode ? Color.gray.opacity(0.8) : Color.gray
        }
        
        // MARK: - Colores semánticos (sin cambio por tema)
        /// Color para elementos destructivos
        static let destructive = Color.red
    }
    
    // MARK: - Gradientes
    struct Gradients {
        
        static func sagePrimary(for isDarkMode: Bool) -> LinearGradient {
            if isDarkMode {
                return LinearGradient(
                    gradient: Gradient(colors: [Colors.darkSageGreen.opacity(0.3), Colors.darkSurface.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                return LinearGradient(
                    gradient: Gradient(colors: [Colors.sageMedium.opacity(0.3), Colors.sageLight.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        static func backgroundGradient(for isDarkMode: Bool) -> LinearGradient {
            if isDarkMode {
                return LinearGradient(
                    gradient: Gradient(colors: [Colors.darkBackground, Colors.darkBackground.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                return LinearGradient(
                    gradient: Gradient(colors: [Colors.cream, Colors.cream.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
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
                .fill(AppTheme.Gradients.sagePrimary(for: false))
                .frame(height: 50)
                .overlay(Text("Sage Primary Gradient").font(.caption).foregroundColor(.white))
            
            Rectangle()
                .fill(AppTheme.Gradients.backgroundGradient(for: false))
                .frame(height: 50)
                .overlay(Text("Background Gradient").font(.caption))
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

// MARK: - Environment Key para ThemeManager
private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}