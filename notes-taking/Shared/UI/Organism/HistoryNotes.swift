//
//  HistoryNotes.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct HistoryNotes: View {
    var body: some View {
        VStack {
            HStack {
                Text("Últimas notas")
                Spacer()
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
            }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(1...4, id: \.self) { card in
                        NoteItem(note: Notes(title: "Note \(card)", content: "Content \(card)"), onEdit: {}, onDelete: {})
                    }
                }
            }
        }
    }
}