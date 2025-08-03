//
//  HomeView.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @Query(sort: \Category.createdAt, order: .reverse)
    private var categories: [Category]

    var body: some View {
        VStack{
            TopBar(title: "Mis Notas")

            SearchBar()

            Spacer().frame(height: 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories) { category in
                        Cards(category: category)
                    }
                }
                .padding(.horizontal)
            }

            Spacer().frame(height: 10)

            HistoryNotes()
                .padding(.horizontal)

            Spacer()
        }
        .onAppear {
            print("Pestaña Home cargada")
        }
    }
}