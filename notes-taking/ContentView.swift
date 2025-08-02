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

            Spacer().frame(height: 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(1...4, id: \.self) { card in
                        Cards()
                    }
                }
                .padding()
            }

            Spacer()
        }

    }
}

#Preview {
    ContentView()
}
