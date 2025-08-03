//
//  CategoriesView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct CategoriesView: View {
    var body: some View {
        VStack {
            Text("📁 Vista de Categorías")
                .font(.title)
                .padding()
            
            Text("Aquí irán las categorías de notas")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .onAppear {
            print("📁 Pestaña Categorías cargada")
        }
    }
}