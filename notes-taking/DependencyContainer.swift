//
//  DependencyContainer.swift
//  notes-taking
//
//  Created by Jonathan Duran on 03/08/2025.
//

import SwiftUI
import SwiftData

@Observable
final class DependencyContainer {
    
    // MARK: - Dependencies
    
    let router: AppRouter
    
    let repository: DataRepositoryProtocol
    
    let environment: AppEnvironment
    
    // MARK: - Environment Definition
    
    enum AppEnvironment {
        case debug
        case testing
        case production
        
        var enableLogging: Bool {
            switch self {
            case .debug, .testing:
                return true
            case .production:
                return false
            }
        }
        
        var repositoryTimeout: TimeInterval {
            switch self {
            case .debug, .testing:
                return 30.0
            case .production:
                return 10.0
            }
        }
    }
    
    // MARK: - Initialization
    
    init(router: AppRouter, repository: DataRepositoryProtocol, environment: AppEnvironment = .debug) {
        self.router = router
        self.repository = repository
        self.environment = environment
        
        if environment.enableLogging {
            print("🏗️ DependencyContainer: Initialized with \(environment) environment")
        }
    }
    
    // MARK: - Factory Methods
    
    static func production(modelContext: ModelContext) -> DependencyContainer {
        let router = AppRouter()
        let repository = SwiftDataRepository.production(modelContext: modelContext)
        
        return DependencyContainer(
            router: router,
            repository: repository,
            environment: .production
        )
    }
    
    static func debug(modelContext: ModelContext) -> DependencyContainer {
        let router = AppRouter()
        let repository = SwiftDataRepository.debug(modelContext: modelContext)
        
        return DependencyContainer(
            router: router,
            repository: repository,
            environment: .debug
        )
    }
    
    static func testing() -> DependencyContainer {
        let router = AppRouter()
        let repository = MockRepository()
        
        return DependencyContainer(
            router: router,
            repository: repository,
            environment: .testing
        )
    }
    
    // MARK: - Helper Methods
    
    var repositoryConfiguration: RepositoryConfiguration {
        RepositoryConfiguration(
            enableLogging: environment.enableLogging,
            operationTimeout: environment.repositoryTimeout
        )
    }
}

// MARK: - SwiftUI Environment Integration

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.testing()
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

// MARK: - View Modifier for Dependency Injection

/// Modifier para inyectar dependencias en las vistas
struct DependencyInjection: ViewModifier {
    let container: DependencyContainer
    
    func body(content: Content) -> some View {
        content
            .environment(\.dependencies, container)
    }
}

extension View {
    /// Inyecta el contenedor de dependencias en la vista
    /// - Parameter container: Contenedor con las dependencias
    /// - Returns: Vista con dependencias inyectadas
    func dependencies(_ container: DependencyContainer) -> some View {
        modifier(DependencyInjection(container: container))
    }
}

// MARK: - Mock Repository for Testing

/// Repository mock para testing
final class MockRepository: DataRepositoryProtocol {
    
    // MARK: - Mock Data
    
    private var mockCategories: [Category] = []
    private var mockNotes: [Notes] = []
    
    // MARK: - Category Operations
    
    func fetchCategories() async throws -> [Category] {
        return mockCategories.sorted { $0.createdAt > $1.createdAt }
    }
    
    func createCategory(name: String) async throws -> Category {
        let category = Category(name: name)
        mockCategories.append(category)
        return category
    }
    
    func updateCategory(_ category: Category, newName: String) async throws {
        category.updateName(newName)
    }
    
    func deleteCategory(_ category: Category) async throws {
        mockNotes.removeAll { $0.category?.id == category.id }
        mockCategories.removeAll { $0.id == category.id }
    }
    
    func deleteAllCategories() async throws -> Int {
        let count = mockCategories.count
        
        mockNotes.removeAll { $0.category != nil }
        
        mockCategories.removeAll()
        return count
    }
    
    // MARK: - Notes Operations
    
    func fetchNotes() async throws -> [Notes] {
        return mockNotes.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func createNote(title: String, content: String, category: Category?) async throws -> Notes {
        let note = Notes(title: title, content: content, category: category)
        mockNotes.append(note)
        return note
    }
    
    func updateNote(_ note: Notes, title: String, content: String, category: Category?) async throws {
        note.update(title: title, content: content, category: category)
    }
    
    func deleteNote(_ note: Notes) async throws {
        mockNotes.removeAll { $0.id == note.id }
    }
    
    func deleteAllNotes() async throws -> Int {
        let count = mockNotes.count
        mockNotes.removeAll()
        return count
    }
    
    // MARK: - Bulk Operations
    
    func deleteAllData() async throws -> (categoriesDeleted: Int, notesDeleted: Int) {
        let categoriesCount = mockCategories.count
        let notesCount = mockNotes.count
        
        mockCategories.removeAll()
        mockNotes.removeAll()
        
        return (categoriesDeleted: categoriesCount, notesDeleted: notesCount)
    }
    
    // MARK: - Search Operations
    
    func searchNotes(containing searchText: String) async throws -> [Notes] {
        return mockNotes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText) ||
            (note.category?.name.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    func fetchNotes(for category: Category) async throws -> [Notes] {
        return mockNotes.filter { $0.category?.id == category.id }
    }
    
    // MARK: - Test Helpers
    
    /// Configura datos mock para testing
    func setupMockData() {
        let category1 = Category(name: "Trabajo")
        let category2 = Category(name: "Personal")
        
        mockCategories = [category1, category2]
        
        mockNotes = [
            Notes(title: "Nota 1", content: "Contenido 1", category: category1),
            Notes(title: "Nota 2", content: "Contenido 2", category: category2),
            Notes(title: "Nota 3", content: "Contenido 3", category: nil)
        ]
    }
}

// MARK: - Preview Support

#if DEBUG
extension DependencyContainer {
    /// Contenedor para previews con datos mock
    static let preview: DependencyContainer = {
        let container = DependencyContainer.testing()
        (container.repository as? MockRepository)?.setupMockData()
        return container
    }()
}
#endif