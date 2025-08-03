//
//  AppRouter.swift
//  notes-taking
//
//  Created by Jonathan Duran on 03/08/2025.
//

import SwiftUI

@Observable
class AppRouter {
    
    // MARK: - Tab Navigation
    var selectedTab: AppTab = .home
    
    // MARK: - Navigation State
    var navigationPath = NavigationPath()
    
    // MARK: - App Tabs Definition
    enum AppTab: Int, CaseIterable {
        case home = 0
        case notes = 1
        case categories = 2
        case settings = 3
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .notes: return "Notas"
            case .categories: return "Categorías"
            case .settings: return "Ajustes"
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .notes: return "note.text"
            case .categories: return "folder.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    func switchTo(_ tab: AppTab) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedTab = tab
        }
        
        print("Router: Navegando a \(tab.title)")
    }
    
    func navigateToNotes() {
        switchTo(.notes)
        print("Router: Navegando a Notas desde acción externa")
    }
    
    func navigateToNotes(withContext context: String) {
        switchTo(.notes)
        print("Router: Navegando a Notas - Contexto: \(context)")
    }
    
    func navigateToNote(withId noteId: UUID) {
        switchTo(.notes)
        print("Router: Navegando a nota específica: \(noteId)")
    }
    
    func navigateToHome() {
        switchTo(.home)
    }
    
    func navigateToCategories() {
        switchTo(.categories)
    }
    
    func navigateToSettings() {
        switchTo(.settings)
    }
    
    // MARK: - Helper Methods
    
    func resetNavigation() {
        navigationPath = NavigationPath()
        selectedTab = .home
        print("🧭 Router: Navegación reseteada")
    }
    
    func isCurrentTab(_ tab: AppTab) -> Bool {
        selectedTab == tab
    }
}

// MARK: - Router Extensions para casos específicos

extension AppRouter {
    
    func navigateFromSearch(to note: Any) {
        navigateToNotes(withContext: "Resultado de búsqueda")
    }
    
    func navigateFromViewAll(section: String) {
        switch section.lowercased() {
        case "notas":
            navigateToNotes(withContext: "Ver todas las notas")
        case "categorías", "categorias":
            navigateToCategories()
        default:
            navigateToNotes(withContext: "Navegación general")
        }
    }
    
    func navigateFromQuickAction(_ action: QuickAction) {
        switch action {
        case .createNote:
            navigateToNotes(withContext: "Crear nueva nota")
        case .viewCategories:
            navigateToCategories()
        case .settings:
            navigateToSettings()
        }
    }
}

// MARK: - Quick Actions Definition
enum QuickAction {
    case createNote
    case viewCategories
    case settings
}

// MARK: - Preview Support
#if DEBUG
extension AppRouter {
    static let preview = AppRouter()
}
#endif