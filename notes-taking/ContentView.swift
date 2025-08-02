//
//  ContentView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        VStack{
            TopBar(title: "Mis Notas")

            SearchBar()
            
            Spacer()
        }

    }
}

#Preview {
    ContentView()
}
