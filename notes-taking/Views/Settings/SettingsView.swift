//
//  SettingsView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("⚙️ Vista de Ajustes")
                .font(.title)
                .padding()
            
            Text("Aquí irán las configuraciones")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .onAppear {
            print("⚙️ Pestaña Ajustes cargada")
        }
    }
}