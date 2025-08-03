//
//  NotesView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct NotesView: View {
    var body: some View {
        VStack {
            Text("📝 Vista de Notas")
                .font(.title)
                .padding()
            
            Text("Aquí irán todas las notas")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .onAppear {
            print("📝 Pestaña Notas cargada")
        }
    }
}