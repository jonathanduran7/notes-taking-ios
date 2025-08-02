//
//  SearchBar.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct SearchBar: View {

    @State private var searchText = ""

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Buscar...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}