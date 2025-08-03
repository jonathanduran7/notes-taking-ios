//
//  HistoryNotes.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI
import SwiftData

struct HistoryNotes: View {
    @Query(sort: \Notes.updatedAt, order: .reverse) private var notes: [Notes]
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
                    ForEach(notes.prefix(3)) { note in
                        NoteItem(note: note, onEdit: {}, onDelete: {})
                    }
                }
            }
        }
    }
}