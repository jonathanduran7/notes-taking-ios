//
//  LoadingStates.swift
//  notes-taking
//
//  Created by Jonathan Duran on 03/08/2025.
//

import Foundation
import SwiftUI

// MARK: - Loading State Definition

enum LoadingState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var isFailure: Bool {
        if case .failure = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .failure(let message) = self {
            return message
        }
        return nil
    }
}

// MARK: - Operation Types

enum OperationType: String, CaseIterable {
    case fetch = "fetch"
    case create = "create"
    case update = "update"
    case delete = "delete"
    case search = "search"
    case deleteAll = "deleteAll"
    
    var displayName: String {
        switch self {
        case .fetch:
            return "Cargando"
        case .create:
            return "Creando"
        case .update:
            return "Actualizando"
        case .delete:
            return "Eliminando"
        case .search:
            return "Buscando"
        case .deleteAll:
            return "Eliminando todo"
        }
    }
    
    var icon: String {
        switch self {
        case .fetch:
            return "arrow.clockwise"
        case .create:
            return "plus.circle"
        case .update:
            return "pencil.circle"
        case .delete:
            return "trash.circle"
        case .search:
            return "magnifyingglass.circle"
        case .deleteAll:
            return "trash.fill"
        }
    }
}

// MARK: - Loading Manager

/// Manejador centralizado de múltiples estados de loading
@Observable
class LoadingManager {
    
    private var loadingStates: [OperationType: LoadingState] = [:]
    
    // MARK: - State Management
    
    func setState(_ state: LoadingState, for operation: OperationType) {
        loadingStates[operation] = state
    }
    
    func getState(for operation: OperationType) -> LoadingState {
        return loadingStates[operation] ?? .idle
    }
    
    func isLoading(_ operation: OperationType) -> Bool {
        return getState(for: operation).isLoading
    }
    
    func isAnyLoading() -> Bool {
        return loadingStates.values.contains { $0.isLoading }
    }
    
    func clearState(for operation: OperationType) {
        loadingStates[operation] = .idle
    }
    
    func clearAllStates() {
        loadingStates.removeAll()
    }
    
    // MARK: - Convenience Methods
    
    func startLoading(_ operation: OperationType) {
        setState(.loading, for: operation)
    }
    
    func finishLoading(_ operation: OperationType, success: Bool = true, error: String? = nil) {
        if success {
            setState(.success, for: operation)
        } else {
            setState(.failure(error ?? "Error desconocido"), for: operation)
        }
        
        // Auto-clear success/error states after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.clearState(for: operation)
        }
    }
    
    func handleError(_ error: Error, for operation: OperationType) {
        setState(.failure(error.localizedDescription), for: operation)
        
        // Auto-clear error state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.clearState(for: operation)
        }
    }
    
    // MARK: - Async Operation Helper
    
    /// Ejecuta una operación async con loading state automático
    func performOperation<T>(
        _ operation: OperationType,
        task: @escaping () async throws -> T
    ) async -> T? {
        startLoading(operation)
        
        do {
            let result = try await task()
            finishLoading(operation, success: true)
            return result
        } catch {
            handleError(error, for: operation)
            return nil
        }
    }
}

// MARK: - UI Loading Indicators

struct LoadingIndicator: View {
    let operation: OperationType
    let size: CGFloat
    
    init(operation: OperationType, size: CGFloat = 20) {
        self.operation = operation
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            
            Text(operation.displayName)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cream)
                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        )
    }
}

struct LoadingOverlay: View {
    let operation: OperationType
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            ZStack {
                // Background blur
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                // Loading content
                VStack(spacing: 16) {
                    Image(systemName: operation.icon)
                        .font(.system(size: 32))
                        .foregroundColor(.sageGreen)
                    
                    Text(operation.displayName)
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    ProgressView()
                        .scaleEffect(1.2)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .animation(.easeInOut(duration: 0.3), value: isVisible)
        }
    }
}

struct InlineLoadingView: View {
    let operation: OperationType
    let message: String?
    
    init(operation: OperationType, message: String? = nil) {
        self.operation = operation
        self.message = message
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.9)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(operation.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let message = message {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.cream)
        .cornerRadius(12)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Reintentar")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.sageGreen)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.cream)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - View Extensions

extension View {
    /// Aplica una overlay de loading cuando está cargando
    func loadingOverlay(
        _ loadingManager: LoadingManager,
        operation: OperationType
    ) -> some View {
        self.overlay(
            LoadingOverlay(
                operation: operation,
                isVisible: loadingManager.isLoading(operation)
            )
        )
    }
    
    /// Disabled cuando hay operaciones de loading
    func disabledWhileLoading(_ loadingManager: LoadingManager) -> some View {
        self.disabled(loadingManager.isAnyLoading())
    }
}

#if DEBUG
// MARK: - Preview Support

extension LoadingManager {
    static let preview: LoadingManager = {
        let manager = LoadingManager()
        manager.setState(.loading, for: .fetch)
        return manager
    }()
}

struct LoadingStates_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LoadingIndicator(operation: .fetch)
            LoadingIndicator(operation: .create)
            InlineLoadingView(operation: .update, message: "Guardando cambios...")
            ErrorView(message: "No se pudo conectar al servidor", retryAction: {})
        }
        .padding()
    }
}
#endif