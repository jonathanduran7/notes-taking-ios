//
//  NoteItem.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct NoteItem: View {
    var body: some View {
        HStack {
            VStack {
                Text("NoteItem").font(.title3).fontWeight(.bold)
                Spacer().frame(height: 10)
                Text("20/07/2025").font(.caption).foregroundColor(.gray)
            }.frame(maxWidth: .infinity, maxHeight: 130, alignment: .leading).padding()

            Spacer()

            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(.gray)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: 130)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}