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

            if notes.isEmpty {
                emptyStateView
            } else {
                listNotes
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.sageGreen.opacity(0.6))

            Text("No hay notas")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Crea una nota para empezar a tomar notas")
        }
    }

    private var listNotes: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(notes.prefix(3)) { note in
                    NoteItem(note: note, onEdit: {}, onDelete: {})
                }
            }
        }
    }
}